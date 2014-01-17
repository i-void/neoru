require 'pp'
require 'rack'

module Neo
	class << self
		attr_accessor :env, :app_dir, :dir, :server_vars, :req

		def init
			Dir[Neo.dir+'/helpers/*'].each { |f| require f }
			Neo.use 'router'
			Neo.use 'config'
			Neo.use 'controller'
			Neo.use 'database:model'
			Neo.use 'response'
			@req = Rack::Request.new(env)
			Neo::Router.build_module_data
		end

		def response
			Neo::Router.response
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