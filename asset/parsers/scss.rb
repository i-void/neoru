require 'sass'

class Neo::Asset::Parsers::Scss

  @options = {
    :style => :nested,
    :load_paths => ['.'],
    :cache => true,
    :cache_location => './.sass-cache',
    :syntax => :scss,
    :filesystem_importer => Sass::Importers::Filesystem
  }.freeze

  class << self
    def parse(file)
      if File.basename(file, '.scss').start_with?('_')
        return false
      end
      engine = Sass::Engine.for_file(file, @options)
      return {content: engine.render, extension: '.css'}
    end
  end
end