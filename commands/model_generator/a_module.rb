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
		@models.each do |name, data|
			model_obj = AModel.new @name, name, data
			model_obj.make_file @path
			model_obj.generate

			query_obj = AModelQuery.new @name, name, data
			query_obj.make_file @path
			query_obj.generate
		end
	end
end