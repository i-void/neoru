require 'yaml'

class Neo::Commands::ModelGenerator

	def initialize(path)
		@path = path
		read_configuration
	end

	def read_configuration
		@modules = YAML.load_file(@path).symbolize_keys
	end

	def generate
		@modules.each do |name, models|
			module_obj = AModule.new @path, name, models
			module_obj.generate_models
		end
	end



end