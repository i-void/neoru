# Class for every route in config and autoroutes
class Neo::Router::Route
	implement Neo::Router::RouteInterface

	attr_reader :position

	# Constructs a new Route
	# @param [String] name
 	# @param [String] path
	# @param [String] parameters_url
	# @param [Neo::Router::Action] action
	# @param [String] subdomain
	# @param [Array<Symbol>|Symbol] methods
	def initialize(name:, path:, parameters_url:, action:, subdomain:, methods:[:get], position:0)
		@name = name
		@path = path
		@parameters_url = (parameters_url.nil?) ? '/' : parameters_url
		@action = action
		@subdomain = subdomain
		@methods = (methods.kind_of? Array) ? methods : [methods]
		@position = position
	end

	# detect that is route matches with the sent request
	# @param [Rack::Request] request
	def match?(request)
		match_method?(request.request_method) and
		match_subdomain?(request.host) and
		match_url?(request.path_info) and
		action_valid?
	end

	# detect that is this route matches with url generation with name
	#   and parameters
	def match_for_path_generate?(name, parameters)
		if @name == name
      if "/#{parameters.join('/')}".match /^#{@parameters_url}/
        true
      else
        Neo::Exceptions::SystemError.new("Cannot generate path with this parameters: #{parameters}").raise
      end
    end
	end

  def generate_path(parameters)
    param_string = (parameters.length > 0) ? "/#{parameters.join('/')}" : ''
    "#{@path}#{param_string}"
  end

	def execute_action
		@action.execute with_parameters: @parameters
	end

	# for testing
	def ==(obj)
		same_with? obj
	end

	private

	def match_method?(method)
		@methods.include? method.downcase.to_sym
	end

	def match_subdomain?(host)
		subdomain = extract_subdomain(host)
		subdomain = nil if subdomain.blank?
		@subdomain == subdomain
	end

	def match_url?(path)
		if path.start_with? @path
			parameter_path = path.gsub /^#{Regexp.quote @path}/, ''
			@request_parameter_count = 0
			if parameter_path != ''
				parameter_path.insert 0, '/' unless parameter_path.start_with? '/'
				if parameter_path.match /^#{@parameters_url}/
					@parameters = parameter_path.split('/').reject(&:empty?)
					@request_parameter_count = @parameters.count
					true
				end
			else
				true
			end
		end
	end

	def action_valid?
		@action.valid? param_count: @request_parameter_count
	end

	def extract_subdomain(host, tld_len=1)
		(host.nil? or /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host)) ?
			'' : host.split('.')[0...(1 - tld_len - 2)].join('.')
	end
end