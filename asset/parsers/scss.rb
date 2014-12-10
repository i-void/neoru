require 'sass'

class Neo::Asset::Parsers::Scss

  @options = {
    :style => :nested,
    :load_paths => %w[
      . /usr/local/share/gems/gems/compass-recipes-0.3.0/stylesheets
      /usr/local/share/gems/gems/compass-0.12.6/frameworks/compass/stylesheets/ ],
    :cache => true,
    :cache_location => './.sass-cache',
    :syntax => :scss,
    :filesystem_importer => ::Sass::Importers::Filesystem
  }.freeze

  class << self
    def parse(file)
      if File.basename(file, '.scss').start_with?('_')
        false
      else
        engine = ::Sass::Engine.for_file(file, @options)
        {content: engine.render, extension: '.css'}
      end
    end
  end
end