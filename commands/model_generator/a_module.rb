require 'fileutils'

class Neo::Commands::ModelGenerator::AModule
	def initialize(path, name, models)
		@name = name.to_s
		@models = models
		@path = File.join File.dirname(path), @name.underscore
		make_directory
	end

	def make_directory
		FileUtils.rmtree(@path) if File.directory? @path
		FileUtils.mkpath(@path)
	end

	def generate_models
		@models.reduce({}) do |memo, (name, data)|
			model_obj = AModel.new @name, name, data
			model_obj.make_file @path
			model_obj.generate

			memo.deep_merge model_obj.reversed_relations
		end
	end

	def generate_model_queries(reversed_relations)
		@models.each do |name, data|
			query_obj = AModelQuery.new @name, name, data
			query_obj.make_file @path
			query_obj.generate(reversed_relations)
		end
  end

  def get_schema
    @models.reduce('') do |memo, (name, data)|
      schema_obj = ASchema.new @name, name, data
      memo + schema_obj.generate
    end
  end
end