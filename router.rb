require 'mime/types'
Neo.use 'params'
Neo.use 'controller'
module Neo
	class FileStreamer
		def initialize(path)
			@file = File.open(path)
		end

		def each(&blk)
			@file.each(&blk)
		ensure
			@file.close
		end
	end

	class Router
		class << self
			attr_accessor :modules, :default_module, :default_controller, :params

			#builds module hash for matching auto route purposes
			def build_module_data
				module_dir = Neo.app_dir+'/modules'
				@modules = {}
				@params = []
				Dir[module_dir+'/*'].each do |f|
					if File.directory? f
						module_name =File.basename(f)
						@modules[module_name] = []
						Dir[f+'/controllers/*'].each do |c|
							controller_name = File.basename(c).split('_')[0]
							@modules[module_name] << controller_name
						end
					end
				end
			end

	      def require_controller(module_name,controller_name)
	        require Neo.app_dir+'/modules/'+module_name+'/controllers/'+controller_name
	      end

			def action_call(module_name, controller_name=nil, action_name='index')
				controller_name = module_name if controller_name.nil?
				Neo::Params.module = module_name
				Neo::Params.controller = controller_name
				Neo::Params.action = action_name
				action_name += '_action'
				require_controller module_name, controller_name
				begin
					content = Kernel
						.const_get(module_name.camelize).const_get('Controllers').const_get(controller_name.camelize)
					.new.send(action_name, *@params)
				end
				[200, {'Content-Type' => 'text/html'}, [content]]
			end

			def is_module?(part)
				not @modules[part].blank?
			end

			def is_controller?(module_name, part)
				true if is_module?(module_name) and @modules[module_name].include?(part+'.rb')
			end

			def is_action?(module_name, controller_name, part)
				part.gsub!('-','_')
				return false if not is_controller?(module_name, controller_name) or part.blank?
				part += '_action'
				require_controller module_name, controller_name
				eval(module_name.camelize+'::Controllers::'+controller_name.camelize+'.new').respond_to?(part)
			end

			def init_params(uri_parts, param_start)
				@params = uri_parts[param_start..-1]
			end

			def other_route_conditions(uri_parts)
				if is_module? uri_parts[0]
					if is_controller? uri_parts[0], uri_parts[1]
						if is_action? uri_parts[0], uri_parts[1], uri_parts[2]
							init_params uri_parts, 3
							return action_call uri_parts[0], uri_parts[1], uri_parts[2]
						end
						if is_action? uri_parts[0], uri_parts[1], 'index'
							init_params uri_parts, 2
							return action_call uri_parts[0], uri_parts[1]
						end
					end
					if is_action? uri_parts[0], uri_parts[0], uri_parts[1]
						init_params uri_parts, 2
						return action_call uri_parts[0], uri_parts[0], uri_parts[1]
					end
					init_params uri_parts, 1
					return action_call(uri_parts[0])
				end

				if is_controller? @default_module, uri_parts[0]
					if is_action? @default_module, uri_parts[0], uri_parts[1]
						init_params uri_parts, 2
						return action_call @default_module, uri_parts[0], uri_parts[1]
					end
					init_params uri_parts, 1
					return action_call(@default_module, uri_parts[0])
				end

				if is_action? @default_module, @default_controller, uri_parts[0]
					init_params uri_parts, 1
					return action_call(@default_module, @default_controller, uri_parts[0])
				end

				init_params uri_parts, 0
				return action_call(@default_module, @default_controller, 'index')
			end

			def check_from_config
				Neo::Config.main[:routes].each_value do |data|
					data[3]='get' if data[3].blank?
					route_reg, param_reg, action, method = data
					param_reg = '/'+param_reg if param_reg[0]!='/'
					url_reg = route_reg + param_reg
					uri = Neo.server_vars['REQUEST_URI']
					request_method = Neo.server_vars['REQUEST_METHOD'].downcase
					if /^#{url_reg}/.match(uri) && method.split(',').include?(request_method)
						param_string = uri.gsub /^#{route_reg}/, ''
						@params = param_string.split('/')[1..-1]
						return action
					end
				end
				return nil
			end

			def action_call_config(action)
				module_name, controller_name, action_name = action.split(':')
				action_call(module_name, controller_name, action_name)
			end

			#match route with modules hash
			def find_action
				#if static file
				file = Neo.app_dir+'/web'+Neo.server_vars['REQUEST_URI']
				if File.file?(file)
					mime = MIME::Types.type_for(file).first.to_s
					if mime == 'application/x-ruby'
						return Neo::Response.error404
					end
					return ['200', {'Content-Type' => MIME::Types.type_for(file).first.to_s}, FileStreamer.new(file)]
				end

				uri_parts = Neo.server_vars['REQUEST_URI'].split('/')[1..-1]

				@default_module = Neo::Config.main[:default_module] unless Neo::Config.main[:default_module].blank?
				@default_controller = @default_module

				#if the route matches with one of the config param then call action from config
				action = check_from_config
				return action_call_config(action) unless action.nil?

				#if the uri is '/' then go and run default module's same named controller's index action
				if uri_parts.blank?
					return action_call @default_module
				else
					response = other_route_conditions(uri_parts)
					return response unless response.blank?
				end
				return nil
			end

			def response
				find_action
			end
		end
	end
end
