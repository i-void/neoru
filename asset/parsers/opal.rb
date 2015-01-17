require 'opal'

# Opal parser for the Neo assets
class Neo::Asset::Parsers::Opal

	Opal::Processor.source_map_enabled = false
	@env = Opal::Environment.new

	# Takes a file and parse it with Opal parser
	# @param file [String] path of the file which will be parsed
	# @return [{Symbol=>String}] which includes
	#   * :content   => the parsed content
	#   * :extension => converting type of the file
	def self.parse(file)
		@env.append_path File.dirname file
		content = @env[File.basename(file,'.rb')].to_s
		{content: content, extension: '.js'}
	end

end