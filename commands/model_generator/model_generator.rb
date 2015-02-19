require 'yaml'

class Neo::Commands::ModelGenerator
	attr_accessor :modules

	def initialize(path)
		@path = path
    @schema_file = File.open File.join(File.dirname(path), 'schema.txt'), 'w'
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
      @schema_file.write module_obj.get_schema
    end
    @schema_file.write 'CREATE CONSTRAINT ON (n:Neo4jUniqueId) ASSERT n.id IS UNIQUE;'
    @schema_file.write "\nCREATE INDEX ON :#{Neo::Config[:db][:name]}(id);"
    @schema_file.close
  end



end