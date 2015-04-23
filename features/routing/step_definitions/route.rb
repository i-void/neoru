Given(/^mock route class with (.*) (.*) (.*) (.*) (.*) (.*) (.*)$/) do |name, path, parameters_url, action_address, subdomain, method_names, position|
	subdomain = nil if subdomain == '-'
	position = nil if position == '-'
	parameters_url = nil if parameters_url == '-'
	method_names = method_names.split(',').map {|method| method.to_sym}
	@route  = Neo::Router::Route.new(
		name: name.to_sym, path: path, parameters_url: parameters_url,
		action: Neo::Router::Action.new(address: action_address),
		subdomain: subdomain, methods: method_names, position: position
	)
end

Then(/^check the result with (.*), (.*), (.*)$/) do |host, url, result|
	result = nil if result == '-'
	method, nude_url = url.split ':', 2
	request = Rack::Request.new 'HTTP_HOST'=>host, 'PATH_INFO'=>nude_url, 'REQUEST_METHOD'=>method.upcase!
	getting_result = (@route.match? request) ? @route.execute_action : nil
	expect(getting_result).to eq result
end

Given(/^autoload all actions$/) do
	pp Neo::Router::AutoRouteGenerator.new.generate_routes
end