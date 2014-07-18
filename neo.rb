require 'pp'
require 'rack'

module Neo
	class << self
		attr_accessor :app_dir, :dir, :server_vars, :req

		def init
			Dir[Neo.dir+'/helpers/*'].each { |f| require f }
			@req = Rack::Request.new(Neo.server_vars)
			Neo::Router.build_module_data
      Neo::Event.register(:before_action) {Neo::Asset::Manager.init}
		end

		def http_response
			Neo::Router.response
		end

    def asset(file)
      root_dir = Neo::Asset::Manager.media_dir.gsub Neo.app_dir+'/web', ''
      root_dir + file
    end

    def trn(phrase)
      return Neo::I18N::translate(phrase)
    end
	end
end