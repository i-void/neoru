require 'sass'

class Neo::Asset::Parsers::Sass

  @options = {
    :style => :nested,
    :load_paths => %w[
      . /usr/local/share/gems/gems/compass-recipes-0.3.0/stylesheets
      /usr/local/share/gems/gems/compass-0.12.6/frameworks/compass/stylesheets/ ],
    :cache => true,
    :cache_location => './.sass-cache',
    :syntax => :sass,
    :filesystem_importer => Sass::Importers::Filesystem
  }.freeze

  class << self
    def parse(file)
      if File.basename(file, '.sass').start_with?('_')
        return false
      end
      engine = Sass::Engine.for_file(file, @options)
      {content: engine.render, extension: '.css'}
    end
  end
end