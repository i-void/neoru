require 'opal/compiler'
require 'opal/parser'
class Neo::Asset::Parsers::Opal
	class << self
		def parse(file)
			content = Opal.compile File.read(file)
			{content: content, extension: '.js'}
		end
	end
end