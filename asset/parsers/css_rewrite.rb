class Neo::Asset::Parsers::CssRewrite
  class << self
    def parse(file)
      {content: File.read(file)}
    end
  end
end