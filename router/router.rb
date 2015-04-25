require 'mime/types'

# Handles the routing
class Neo::Router

	# construct a new router object
	# @param [Rack::Request] request
	# @param [Array<Neo::Router::Route, #match?>] routes
	def initialize(request:, routes:)
		@request = request
		@routes = routes
	end

	def get_http_response
		file = Neo.app_dir+'/web'+Neo.server_vars['REQUEST_PATH']
		if File.file?(file) and not %w( .ru .rb .scss .sass .coffee ).include? File.extname(file)
			Neo::Response.static(file)
		else
			matching_route = @routes.find {|route| route.match? @request }
			if matching_route
				Neo::Event.trigger :before_action
				response = matching_route.execute_action
				Neo::Event.trigger :after_action
				response
			else
				error_msg = Neo.trn('Path not found or parameter count not match on {{url}}').gsub '{{url}}', Neo.server_vars['REQUEST_PATH']
				Neo::Exceptions.new(404, error_msg).raise
			end
		end
	end
end