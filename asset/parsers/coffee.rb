require 'coffee-script'

# Coffee parser for the Neo assets
class Neo::Asset::Parsers::Coffee

  # Takes a file and parse it with coffeescript parser
  # @param file [String] path of the file which will be parsed
  # @return [{Symbol=>String}] which includes
  #   * :content   => the parsed content
  #   * :extension => converting type of the file
  def self.parse(file)
    content = CoffeeScript.compile File.read(file)
    {content: content, extension: '.js'}
  end

end