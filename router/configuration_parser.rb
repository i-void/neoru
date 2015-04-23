# Parses the route configuration and generate route classes
class Neo::Router::ConfigurationParser
	implement Neo::Router::ConfigurationParserInterface

	# supported methods for routing
	METHODS = [:get, :post, :put, :delete, :options, :head]

	# sets configuration class
	# @param [Class#[]] conf
	# @param [Neo::Router::Route] route_class
	# @param [Neo::Router::Action] action_class
	def initialize(conf: Neo::Config, route_class: Neo::Router::Route, action_class: Neo::Router::Action)
		@conf = conf
		@route_class = route_class
		@action_class = action_class
	end

	# generate and return route classes from configuration
	# @return [Array<Neo::Router::Route>]
	def generate_routes
		@conf[:routes].map do |name, properties|
			get_route_class name, properties
		end.sort_by { |route|
			route.position || 0
		}
	end

	private

	# generate and return route class with name and properties
	# @param [String] name name of the route
	# @param [Hash] properties properties got from configuration
	def get_route_class(name, properties)
		methods = get_methods_as_key properties
		if methods.nil?
			Neo::Exceptions::SystemError.new(
				Neo.trn('Route methods must be set in configuration for {{route}}', replace:{'{{route}}'=>name})
			).raise
		end
		url = properties[methods]
		path, parameters_url = explode_url url


		@route_class.new(
			name: name,
			path: path,
			parameters_url: parameters_url,
			action: @action_class.new(address: properties[:to]),
			subdomain: properties[:subdomain],
			methods: methods,
			position: properties[:position]
		)
	end

	# Explodes the url from ?/ string. The first part is the path
	#  and the second part is the parameters url
	def explode_url(url)
		url.split '?/', 2
	end

	# detects the hash key of methods(get, post, put etc..) from configuration
	# @param [Hash] properties properties got from configuration
	# @return [Symbol|Array<Symbol>]
	def get_methods_as_key(properties)
		properties.each_key.reduce(nil) do |memo, key|
			if METHODS.any? {|method| method == key}
				break key
			elsif key.kind_of? Array and key.all? {|method| METHODS.include? method}
				break key
			end
			memo
		end
	end

end