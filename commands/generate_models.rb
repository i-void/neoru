class Neo::Commands::GenerateModels < Neo::Command
	ModelGenerator = Neo::Commands::ModelGenerator

	# Takes the model file and
	#   generate model files from its yml structure
	# @param model_file_path [string]
	#   path of yml file relative to app_dir
	def run(model_file_path)
		path = File.join Neo.app_dir, model_file_path
		mg = ModelGenerator.new(path)
		mg.generate
	end
end