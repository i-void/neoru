require 'ostruct'

# Finds the matching route from @routes
class Neo::Router::ConfigurationChecker

	Configuration = Neo::Router::Configuration

	# @param [String] uri
	# @param [Hash] routes
	#   must be in these format
	# 	{ home: {get:'/', to:'site:site:index', position: 0},
	# 		about_us: {get: '/hakkimizda?/', to:'site:site:about_us'},
	# 		contact: {[:get,:post]=>'/iletisim', to:'site:site:contact'},
	# 		api: {get:'//api.site.com', to:'api:api:index', position: :last} }
	def initialize(host:,uri:,routes:,method:)
		@host = host
		@uri = uri
		@routes = routes
		@verb = method
		@subdomain = extract_subdomain
		@path = extract_path
	end

	def check
		@routes.reduce(nil) do |memo,(name, options)|
			config = Configuration.new(name: name, options: options)
			if config.match? @uri and config.has_verb? @verb and config.has_correct_params?
				@params = config.get_param_values(@path)
				break config
			end
			memo
		end
	end

	def collect_params
		@params
	end

	def extract_subdomain(tld_len=1)
		(@host.nil? or /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(@host)) ?
			'' : @host.split('.')[0...(1 - tld_len - 2)].join('.')
	end

	def extract_path
		path = @uri.split('/').slice_after(@host).to_a
		"/#{path.drop(1).join '/'}"
	end

end