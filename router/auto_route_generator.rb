# Generates the autoroute classes for matching with the visited url
class Neo::Router::AutoRouteGenerator
	# Takes the module dir and scan for routes
	# @param [String] module_dir Directory which include modules
	#   This directory skeleton must be like below
	#   module_dir
	#     -module_1
	#       -controllers
	#         -controller_1
	#         -controller_2
	#     -module_2
	#       -controllers
	#         -another_controller
	def initialize(module_dir:"#{Neo.app_dir}/modules",route_class:Neo::Router::Route, action_class:Neo::Router::Action, conf_class:Neo::Config)
		@module_dir = module_dir
		@route_class = route_class
		@action_class = action_class
		@conf_class = conf_class
	end

	def generate_routes
		for_all_actions(routes:[]) do |routes, module_name, controller_name, action_name|
			routes + generate_routes_of(module_name, controller_name, action_name)
		end
	end

	private

	def generate_routes_of(module_name, controller_name, action_name)
		paths = ["/#{module_name}/#{controller_name}/#{action_name}"]
		if @conf_class[:default_module]==module_name
			if controller_name==module_name
				if action_name == 'index'
					paths << '/'
				else
					paths << "/#{action_name}"
				end
			else
				if action_name == 'index'
					paths << "/#{controller_name}"
				else
					paths << "/#{controller_name}/#{action_name}"
				end
			end
		end
		if controller_name==module_name
			if action_name == 'index'
				paths << "/#{module_name}"
			else
				paths << "/#{module_name}/#{action_name}"
			end
		end

		paths.map do |path|
			@route_class.new(
				name:nil,
				path: path,
				parameters_url: nil,
				action: @action_class.new(address: "#{module_name}:#{controller_name}:#{action_name}"),
				subdomain:nil,
				methods:[:get,:post],
				position:nil
			)
		end
	end

	def require_controller(module_name,controller_name)
		require Neo.app_dir+'/modules/'+module_name+'/controllers/'+controller_name
	end

	def actions_of(controller)
		controller.instance_methods.reduce([]) do |memo, method|
			method = method.to_s
			(method.include? '_action') ? memo << method : memo
		end
	end

	def for_actions_of(controller)
		actions_of(controller).each do |action|
			yield action.gsub /_action$/, ''
		end
	end

	def read_module_dir(module_dir)
		Dir[module_dir+'/*'].each do |module_directory|
			if File.directory? module_directory
				read_controllers module_directory do |controller_name|
					yield File.basename(module_directory), controller_name
				end
			end
		end
	end

	def read_controllers(module_file)
		Dir[module_file+'/controllers/*'].each do |c|
			yield File.basename(c, '.rb')
		end
	end

	def for_all_actions(routes:)
		read_module_dir @module_dir do |module_name, controller_name|
			require_controller module_name, controller_name
			controller = Object
				.const_get(module_name.camelize)
				.const_get('Controllers', false)
				.const_get(controller_name.camelize, false)
			unless controller or controller.is_a? Class
				Neo::Exceptions::SystemError.new(
					"Controller not found with: #{module_name.camelize}::#{controller_name.camelize}"
				).raise
			end
			for_actions_of controller do |action|
				routes = yield routes, module_name, controller_name, action
			end
		end
		routes
	end
end