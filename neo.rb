require 'pp'
require 'rack'
require 'hash_deep_merge'

module Neo
	class << self
		attr_accessor :app_dir, :dir, :server_vars, :req, :mail, :conf

		def init
			Dir[Neo.dir+'/helpers/*'].each { |f| require f }

      Neo.server_vars={} if Neo.server_vars.nil?
			@req = Rack::Request.new(Neo.server_vars)

			Neo::Router.build_module_data
      Neo::Event.register(:before_action) {Neo::Asset::Manager.init}
      @mail = Neo::Mail.new
      @conf = Neo::Config.main
		end

		def http_response
			Neo::Router.response
		end

    def asset(file)
      root_dir = Neo::Asset::Manager.media_dir.gsub Neo.app_dir+'/web', ''
      root_dir + file
    end

    def trn(phrase, lang=Neo::Config.main[:lang])
      Neo::I18N::translate(phrase,lang)
    end

    def generate_url(name, parameters=[])
      url = Neo::Config.main[:routes][name][0]
      parameters.reduce(url) do |retval, i|
        "#{retval}/#{i}"
      end
    end

	end
end