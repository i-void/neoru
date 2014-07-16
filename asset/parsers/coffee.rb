require 'coffee-script'
class Neo::Asset::Parsers::Coffee
  class << self
    def parse(file)
      content = CoffeeScript.compile File.read(file)
      return {content: content, extension: '.js'}
    end
  end
end