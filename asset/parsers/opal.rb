require 'opal'

# Opal parser for the Neo assets
class Neo::Asset::Parsers::Opal

	Opal::Processor.source_map_enabled = false

	def self.new_environment(asset_folder)
		@asset_folder = asset_folder
		@env = Opal::Environment.new
		@env.append_path(asset_folder)
		#@env.use_gem 'opal-jquery'
	end

	# Takes a file and parse it with Opal parser
	# @param file [String] path of the file which will be parsed
	# @return [{Symbol=>String}] which includes
	#   * :content   => the parsed content
	#   * :extension => converting type of the file
	def self.parse(file)
		file = File.realdirpath(file).gsub /^#{@asset_folder}\//, ''
		content = @env[file].to_s
		{content: content, extension: '.js'}
	end

end