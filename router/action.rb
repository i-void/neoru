require 'ostruct'

# Represents the class version of the action which is written as string
class Neo::Router::Action
	implement Neo::Router::ActionInterface

	# Constructs the action
	# @param [String] address, which must be in format module_name:controller_name:action_name
	def initialize(address:)
		@address = address
	end

	def valid?(param_count:)
		module_name, controller_name, action_name = @address.split(':')

		module_name = (module_name.blank?) ? Neo::Config[:default_module].camelize : module_name.camelize
		controller_name = (controller_name.blank?) ? module_name : controller_name.camelize

		action_name = 'index' if action_name.blank?

		controllers = Object.const_get("#{module_name}::Controllers")
		unless controllers
			Neo::Exceptions::SystemError.new("Module not found or controllers of module empty: #{@address}").raise
		end
		controller = controllers.const_get(controller_name, false)
		unless controller
			Neo::Exceptions::SystemError.new("Controller not found with: #{@address}").raise
		end

		Neo::Params.module = module_name
		Neo::Params.controller = controller_name
		Neo::Params.action = action_name
		action_name = "#{action_name}_action"
		if controller.new.respond_to? action_name
			@controller = controller
			@action = action_name
			expected_arg_count = find_min_max_args(controller.new.method(action_name).parameters)
			param_count.between? expected_arg_count.min, expected_arg_count.max
		end
	end

	def execute(with_parameters:[])
		@controller.new.send @action, *with_parameters
	end

	# for testing
	def ==(obj)
		same_with? obj
	end

	private

	def find_min_max_args(args_array)
		args_array.reduce(OpenStruct.new(min: 0, max: 0)) do |memo, val|
			memo.min += 1 if val[0].to_s.include? 'req'
			memo.max += 1
			memo
		end
	end
end