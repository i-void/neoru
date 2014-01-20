require 'json'
require 'rest_client'
require 'hash_deep_merge'
require 'pp'
Neo.use 'database:exception'
module Neo
	module Database
		class Query
			attr_accessor :select,:match,:command,:match,:label,:return,:parameters,:create,:set,:param_uid,:limit
			attr_accessor :order,:where,:where_depth
			def initialize(command='')
				if Neo::Config.main[:db][:host].blank?
					@uri = '127.0.0.1'
				else
					@uri = Neo::Config.main[:db][:host]
				end
				@uri +=  ':' + Neo::Config.main[:db][:port].to_s
				@command = command
				@label = []
				@match = []
				@create = []
				@where = []
				@set = []
				@order = []
				@where_depth = 0
				@param_uid = 0
				@parameters = {:query=>''}
			end

			def get
				result = run
				modified_result = []
				if result['data'].blank?
					return nil
				else
					if result['data'].length == 1
						row = result['data'][0]
						if row.length == 1
							if row[0].kind_of?(String) or row[0].kind_of?(Fixnum)
								return row[0]
							else
								return row[0]['data']
							end
						else
							row.each do |cell|
								if defined?(cell['data']).nil?
									modified_result << cell
								else
									modified_result << cell['data']
								end
							end
							return modified_result
						end
					else
						result['data'].each do |row|
							if row.length ==1
								if defined?(row[0]['data']).nil?
									modified_result << row[0]
								else
									modified_result << row[0]['data']
								end
							else
								modified_row = []
								row.each do |cell|
									if defined?(cell['data']).nil?
										modified_row << cell
									else
										modified_row << cell['data']
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
					pp @parameters[:query]
				else
					pp @parameters[:query] + ' --> ' +@parameters['params'].to_s
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
								return Neo::Database::Exception.new(resp['exception'] + ' | ' + resp['message']).raise
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
					@order << node_sign+' '+types[sort_type]
				end
				return self
			end

			def add_match(node_sign,labels='',properties='',suffix='')
				labels = [labels] unless labels.kind_of?(Array)
				if labels.length>0
					labels = ':'+labels.join(':')
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
				@match << '('+node_sign + labels + prop_str+')'+suffix
				return self
			end

			def fill_model(model)
				result = run
				model_arr = []
				methods = model.new.methods
				result['data'].each do |row|
					new_model = model.new
					row[0]['data'].each do |k,v|
						if methods.include?((k+'=').to_sym)
							new_model.send(k+'=',v)
						end
					end
					model_arr << new_model
				end
				return model_arr
			end

			def add_create(node_sign,labels='',properties='',suffix='')
				labels = [labels] unless labels.kind_of?(Array)
				if labels.length>0
					labels = ':'+labels.join(':')
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
				@create << '('+node_sign + labels + prop_str+')'+suffix
				return self
			end

			def add_label(label)
				@label << label
				return self
			end

			def set_limit(limit)
				@limit = limit
				return self
			end

			def add_parameters(params)
				@parameters['params'] = {} if @parameters['params'].blank?
				@parameters['params'].deep_merge!(params)
				return self
			end

			def add_labels(labels)
				@label += labels
				return self
			end

			def set_return(return_str)
				@return = return_str
				return self
			end

			def add_where(params, operator='AND', depth=0)
				prefix = ''
				if depth < @where_depth
					@where[-1] = @where[-1].gsub(/ (and|or)$/i,'')
					prefix = ' )'
				elsif depth > @where_depth
					prefix = '( '
				end
				params.each do |param,op,val|
					@where << prefix+'n.'+param.to_s+op+val+' '+operator
					prefix = ''
				end
				@where_depth = depth
				return self
			end

			def add_set(set_data, params)
				prop_str = ''
				if params.length>0
					param_label = "set_props#{@param_uid}"
					prop_str = ' = {'+param_label+'}'
					add_parameters({param_label.to_sym=>params})
					@param_uid+=1
				end
				@set << 'SET '+ set_data+prop_str
				return self
			end

			def query(q_str,parameters={})
				q_str.gsub!(/:\$/,':'+Neo::Config.main[:db][:name])
				@parameters[:query] = q_str
				add_parameters(parameters)
			end

			def build
				unless @match.blank?
					@parameters[:query] += 'MATCH '+@match.join(',')+' '
				end
				unless @where.blank?
					@where[-1] = @where[-1].gsub(/ (and|or)$/i,'')
					@parameters[:query] += 'WHERE '+@where.join(' ')
					@where_depth.times do
						@parameters[:query] += ')'
					end
					@parameters[:query]+=' '
				end
				unless @create.blank?
					@parameters[:query] += 'CREATE '+@create.join+' '
				end
				unless @set.blank?
					@parameters[:query] += @set.join(' ')+' '
				end
				unless @return.blank?
					@parameters[:query] += 'RETURN '+@return+' '
				end
				unless @limit.blank?
					@parameters[:query] += 'LIMIT '+@limit.to_s+' '
				end
				unless @order.blank?
					@parameters[:query] += 'ORDER BY '+@order.join(',')+' '
				end
				return @parameters['query']
			end
		end
	end
end