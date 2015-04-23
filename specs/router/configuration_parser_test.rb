require './init_fake_neo'

describe 'Parse Configuration' do
	before do
		conf = Class.new do
			def self.[](key)
				if key == :routes
					{	home: {get:'/', to:'site:site:index', position: 2},
					   api: {subdomain: 'api', get:'/', to:'api:api:index', position: 10},
					   about_us: {get: '/hakkimizda?/\d+', to:'site:site:about_us'},
					   contact: {[:get,:post]=>'/iletisim', to:'site:site:contact' , position: 1}
					}
				end
			end
		end
		@configuration_parser = Neo::Router::ConfigurationParser.new(conf: conf)
	end

	it 'should generate routes' do
		routes = @configuration_parser.generate_routes
		routes.must_equal [
      Neo::Router::Route.new(
        name: :about_us, path:'/hakkimizda', parameters_url:'\d+',
        action: Neo::Router::Action.new(address:'site:site:about_us'),
        subdomain: nil, methods:[:get], position: nil
      ),
      Neo::Router::Route.new(
        name: :contact, path:'/iletisim', parameters_url:nil,
        action: Neo::Router::Action.new(address:'site:site:contact'),
        subdomain: nil, methods:[:get,:post], position: 1
      ),
      Neo::Router::Route.new(
        name: :home, path:'/', parameters_url:nil,
        action: Neo::Router::Action.new(address:'site:site:index'),
        subdomain: nil, methods:[:get], position: 2
      ),
      Neo::Router::Route.new(
        name: :api, path:'/', parameters_url:nil,
        action: Neo::Router::Action.new(address:'api:api:index'),
        subdomain: 'api', methods:[:get], position: 10
      ),
    ]
	end

	it 'get_route_class should get route class' do
		def test_route_conf(name, data)
			route_class = @configuration_parser.send(:get_route_class, name, data)
			route_class.must_equal yield
		end

		test_route_conf 'home', {subdomain:'api', get:'/', to:'site:site:index', position: 10} do
			Neo::Router::Route.new(
	     name: 'home', path:'/', parameters_url:nil,
	     action:Neo::Router::Action.new(address:'site:site:index'),
       subdomain:'api', methods:[:get], position:10
     )
		end

		test_route_conf 'home', {get:'/', to:'site:site:index', position: 10} do
			Neo::Router::Route.new(
				name: 'home', path:'/', parameters_url:nil,
				action:Neo::Router::Action.new(address:'site:site:index'),
				subdomain:nil, methods:[:get], position:10
			)
		end

		test_route_conf 'about_us', {get:'/hakkimizda?/\d+', to:'site:site:about_us', position: 3} do
			Neo::Router::Route.new(
				name: 'about_us', path:'/hakkimizda', parameters_url:'\d+',
				action:Neo::Router::Action.new(address:'site:site:about_us'),
				subdomain:nil, methods:[:get], position:3
			)
		end

		test_route_conf 'contact', {[:get,:post]=>'/hakkimizda?/\d+?/\w', to:'site:main:about_us', position: 3} do
			Neo::Router::Route.new(
				name: 'contact', path:'/hakkimizda', parameters_url:'\d+?/\w',
				action:Neo::Router::Action.new(address:'site:main:about_us'),
				subdomain:nil, methods:[:get,:post], position:3
			)
		end
	end

	it 'must raise exception if methods(get, post..) missing' do
		def test(&block)
			block.must_raise Neo::Exceptions::SystemError
		end
		test { @configuration_parser.send(:get_route_class, 'home', {to:'site:site:index', position: 10})	}
	end

	it 'get_methods_as_key must return methods as parameter array key' do
		def test_methods(hash:, expected:)
			result = @configuration_parser.send(:get_methods_as_key, hash)
			result.must_equal expected
		end

		test_methods hash: {[:get,:post]=>'/'}, expected: [:get,:post]
		test_methods hash: {[:delete]=>'/'}, expected: [:delete]
		test_methods hash: {:put=>'/'}, expected: :put
		test_methods hash: {:unavailable=>'/'}, expected: nil
	end

	it 'explode_url must return path and parameters_url' do
		def test_url(input:, expected:)
			result = @configuration_parser.send(:explode_url, input)
			result.must_equal expected
		end

		test_url input: '/hakkimizda?/\d+', expected:  %w(/hakkimizda \d+)
		test_url input: '/hakkimizda?/\d+?/\d+', expected: %w(/hakkimizda \d+?/\d+)
	end
end