require 'json'
require 'rest_client'
require 'hash_deep_merge'
require 'pp'
Neo.use 'database:exception'
module Neo
	module Database
		class Query
			attr_accessor :select,:match,:command,:match,:label,:return,:parameters,:create,:set,:param_uid,:limit,:where,:where_depth
			def initialize(command='')
				if Neo::Config.main[:db][:host].blank?
					@uri = 'localhost'
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
				@where_depth = 0
				@param_uid = 0
				@parameters = {:query=>''}
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
					val = "'#{val}'" unless val =~ /\A[+-]?\d+\Z/
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
				return @parameters['query']
			end
		end
	end
end