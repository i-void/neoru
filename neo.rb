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

		def response
			Neo::Router.response
		end

    def asset(file)
      root_dir = Neo::Asset::Manager.media_dir.gsub Neo.app_dir+'/web', ''
      root_dir + file
    end

		def use(file)
			class_parts = []
			file.split(':').each do |part|
				class_parts << part.camelize
			end
			class_name = 'Neo::' + class_parts.join('::')
			file.gsub! ':', '/'
			require Neo.dir+'/'+file
			return eval(class_name)
		end

		def use_module(file)
			class_parts = []
			file.split(':').each do |part|
				class_parts << part.camelize
			end
			class_name = '::' + class_parts.join('::')
			file.gsub! ':', '/'
			require Neo.app_dir+'/modules/'+file
			return eval(class_name)
		end
	end
end