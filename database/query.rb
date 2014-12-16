require 'json'
require 'rest_client'
require 'pp'

module Neo
  module Database
    class Query
      attr_accessor :command,:return,:parameters,:param_uid,:limit,:where_depth
      def initialize(command='')

        phrase_struct = Struct.new(:select,:match,:update,:label,:create,:where,:set,:order)
        @phrase = phrase_struct.new([],[],[],[],[],[],[],[])

        if Neo::Config[:db][:host].blank?
          @uri = '127.0.0.1'
        else
          @uri = Neo::Config[:db][:host]
        end
        @uri +=  ':' + Neo::Config[:db][:port].to_s
        @command = command
        @where_depth = 0
        @param_uid = 0
        @parameters = {:query=>''}
      end


      def get_all
        result = run
        modified_result = []
        unless result['data'].blank?
          result['data'].each do |row|
            modified_row = []
            row.each do |cell|
              return nil if cell.nil?
              if cell.kind_of?(String) or cell.kind_of?(Fixnum)
                modified_row << cell
              else
                modified_row << cell['data']
              end
            end
            modified_result << modified_row
          end
          modified_result
        end
      end

      def get
        result = run
        modified_result = []
        unless result['data'].blank?
          if result['data'].length == 1
            row = result['data'][0]
            if row.length == 1
              if row[0].kind_of?(String) or row[0].kind_of?(Fixnum)
                row[0]
              else
                (row[0].nil?) ? nil : row[0]['data']
              end
            else
              row.each do |cell|
                if cell.kind_of?(String) or cell.kind_of?(Fixnum)
                  modified_result << cell
                else
                  if cell.nil?
                    modified_result << nil
                  else
                    modified_result << cell['data']
                  end
                end
              end
              return modified_result
            end
          else
            result['data'].each do |row|
              if row.length ==1
                if row[0].kind_of?(String) or row[0].kind_of?(Fixnum)
                  modified_result << row[0]
                else
                  if row[0].nil?
                    modified_result << nil
                  else
                    modified_result << row[0]['data']
                  end
                end
              else
                modified_row = []
                row.each do |cell|
                  if cell.kind_of?(String) or cell.kind_of?(Fixnum)
                    modified_row << cell
                  else
                    if cell.nil?
                      modified_row << nil
                    else
                      modified_row << cell['data']
                    end
                  end
                end
                modified_result << modified_row
              end
            end
            return modified_result
          end
        end
      end

      def run
        build

        if @parameters['params'].nil?
          pp @parameters[:query] if Neo.conf and Neo.conf[:env] == 'dev'
        else
          pp @parameters[:query] + ' --> ' +@parameters['params'].to_s if Neo.conf and Neo.conf[:env] == 'dev'
        end

        begin
          RestClient.post( 'http://'+@uri+'/'+@command,
                           @parameters.to_json,
                           :content_type => :json,
                           :accept => :json
          ) { |response, request, result, &block|
            case response.code
              when 200
                return JSON.parse(response)
              when 400
                resp = JSON.parse(response)
                return Neo::Exceptions::DatabaseError.new(
                  resp['exception'] + ' | ' + resp['message']
                ).raise
              else
                return nil
            end
          }
        end
      end

      def add_order(node_sign, sort_type=1)
        if node_sign.kind_of?(Array)
          node_sign.each {|sign| add_order(sign)}
        end
        if node_sign.kind_of?(String)
          node_sign = 'n.'+node_sign unless node_sign.include?('.')
          types = {1=>'ASC',-1=>'DESC'}
          @phrase.order << node_sign+' '+types[sort_type]
        end
        self
      end

      def add_match(node_sign,labels='',properties='',suffix='')
        labels = [labels] unless labels.kind_of?(Array)
        if labels.length>0
					labels.unshift Neo::Config[:db][:name] unless labels.include? Neo::Config[:db][:name]
          labels = ":#{labels.join(':')}"
        else
          labels = ''
        end
        prop_str = ''
        if properties.length > 0
          param_label = "properties#{@param_uid}"
          prop_str = ' {'
          properties.each_key do |k|
            prop_str += k.to_s+':{'+param_label+'}.'+k.to_s+','
          end
          prop_str = prop_str[0..-2]
          prop_str += '}'
          add_parameters({param_label.to_sym=>properties})
          @param_uid+=1
        end
        @phrase.match << '('+node_sign + labels + prop_str+')'+suffix
        self
      end

      def fill_model(model)
        result = run
        model_arr = []
        methods = model.new.methods
        unless result.nil?
          result['data'].each do |row|
            new_model = model.new
            row[0]['data'].each do |k,v|
              if methods.include?((k+'=').to_sym)
                new_model.send(k+'=',v)
              end
            end
            model_arr << new_model
          end
        end
        model_arr
      end

      def add_create(node_sign,labels='',properties='',suffix='')
        labels = [labels] unless labels.kind_of?(Array)
        if labels.length>0
	        labels.unshift Neo::Config[:db][:name] unless labels.include? Neo::Config[:db][:name]
	        labels = ":#{labels.join(':')}"
        else
          labels = ''
        end
        prop_str = ''
        if properties.length > 0
          param_label = "properties#{@param_uid}"
          prop_str = ' {'+param_label+'}'
          add_parameters({param_label.to_sym=>properties})
          @param_uid+=1
        end
        @phrase.create << '('+node_sign + labels + prop_str+')'+suffix
        self
      end

      def add_update(id,node_sign,labels='',properties='',suffix='')
        self.add_match(node_sign,labels,{:id=>id})
        prop_str = ''
        if properties.length > 0
          param_label = "properties#{@param_uid}"
          prop_str = ' {'+param_label+'}'
          add_parameters({param_label.to_sym=>properties})
          @param_uid+=1
        end
        @phrase.update << ' '+node_sign + ' = ' + prop_str+' '+suffix
        self
      end

      def add_label(label)
        @phrase.label << label
        self
      end

      def set_limit(limit)
        @limit = limit
        self
      end

      def add_parameters(params)
        @parameters['params'] = {} if @parameters['params'].blank?
        @parameters['params'].deep_merge!(params)
        self
      end

      def add_labels(labels)
        @phrase.label += labels
        self
      end

      def set_return(return_str)
        @return = return_str
        self
      end

      def add_where(params, operator='AND', depth=0)
        prefix = ''
        if depth < @where_depth
          @phrase.where[-1] = @phrase.where[-1].gsub(/ (and|or)$/i,'')
          prefix = ' )'
        elsif depth > @where_depth
          prefix = '( '
        end
        params.each do |param,op,val|
          @phrase.where << prefix+'n.'+param.to_s+' '+op+' '+val+' '+operator
          prefix = ''
        end
        @where_depth = depth
        self
      end

      def add_set(set_data, params)
        prop_str = ''
        if params.length>0
          param_label = "set_props#{@param_uid}"
          prop_str = ' = {'+param_label+'}'
          add_parameters({param_label.to_sym=>params})
          @param_uid+=1
        end
        @phrase.set << 'SET '+ set_data+prop_str
        self
      end

      def query(q_str,parameters={})
        q_str.gsub!(/:\$/,':'+Neo::Config[:db][:name])
        @parameters[:query] = q_str
        add_parameters(parameters)
      end

      def build
        unless @phrase.match.blank?
          @parameters[:query] += 'MATCH '+@phrase.match.join(',')+' '
        end
        unless @phrase.where.blank?
          @phrase.where[-1] = @phrase.where[-1].gsub(/ (and|or)$/i,'')
          @parameters[:query] += 'WHERE '+@phrase.where.join(' ')
          @where_depth.times do
            @parameters[:query] += ')'
          end
          @parameters[:query]+=' '
        end
        unless @phrase.update.blank?
          @parameters[:query] += 'SET '+@phrase.update.join(',')+' '
        end
        unless @phrase.create.blank?
          @parameters[:query] += 'CREATE '+@phrase.create.join+' '
        end
        unless @phrase.set.blank?
          @parameters[:query] += @phrase.set.join(' ')+' '
        end
        unless @return.blank?
          @parameters[:query] += 'RETURN '+@return+' '
        end
        unless @phrase.order.blank?
          @parameters[:query] += 'ORDER BY '+@phrase.order.join(',')+' '
        end
        unless @limit.blank?
          @parameters[:query] += 'LIMIT '+@limit.to_s+' '
        end
        @parameters['query']
      end
    end
  end
end