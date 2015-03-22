require 'ostruct'

class Neo::Router::Configuration
	attr_reader :to

	def initialize(name:, options:)
		@name = name
		@options = options
		extract_options
		extract_params
	end

	def extract_options
		verbs = [:get, :post, :put, :delete, :options, :head]
		@options.each do |key, value|
			if [:to, :position].any? {|k| k == key}
				instance_variable_set "@#{key}", value
			elsif verbs.any? {|verb| verb == key}
				@route = value; @verbs = [key]
			elsif key.kind_of? Array and key.all? {|verb| verbs.include? verb}
				@route = value; @verbs = key
			end
		end
	end

	# This method extract the url and parameters from route
	def extract_params
		url, *params = @route.split '?/'
		@param_count = params.length
		params = params.join '/'
		@route = url
		@params = params
	end

	# Mathces the @uri with url and parameters combination
	# @return [true, false]
	def match?(uri)
		reg = Regexp.new "^#{@route}/#{@params}"
		reg === uri
	end

	def has_verb?(verb)
		@verbs.include? verb
	end

	def find_min_max_args(args_array)
		args_array.reduce(OpenStruct.new(min: 0, max: 0)) do |memo, val|
			memo.min += 1 if val[0].to_s.include? 'req'
			memo.max += 1
			memo
		end
	end

	def has_correct_params?
		module_name, controller_name, action_name = @to.split(':')
		controller = Object
			.const_get(module_name.camelize)
			.const_get('Controllers')
			.const_get(controller_name.camelize)
		Neo::Exceptions::SystemError.new("Controller not found with: #{@to}") unless controller
		action_name = "#{action_name}_action"

		if controller.new.respond_to? action_name
			expected_arg_count = find_min_max_args(controller.new.method(action_name).parameters)
			@param_count.between? expected_arg_count.min, expected_arg_count.max
		end
	end

	def get_param_values(path)
		path.gsub(@route, '').split('/')
	end

end