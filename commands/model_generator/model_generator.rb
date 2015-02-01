require 'yaml'

class Neo::Commands::ModelGenerator
	attr_accessor :modules

	def initialize(path)
		@path = path
		read_configuration
	end

	def read_configuration
		@modules = YAML.load_file(@path).symbolize_keys
	end

	def generate
		reversed_relations = {}
		module_objs = []
		@modules.each do |name, models|
			module_obj = AModule.new @path, name, models
			reversed_relations.deep_merge! module_obj.generate_models
			module_objs << module_obj
		end

		module_objs.each do |module_obj|
			module_obj.generate_model_queries reversed_relations
		end
	end



end