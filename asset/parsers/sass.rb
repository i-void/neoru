require 'sass'

module Neo
  module Asset
    module Parsers
      class Sass

        # init sass parser with these options
        OPTIONS = {
          style: :nested,
          :load_paths => %w[. /usr/local/share/gems/gems/compass-recipes-0.3.0/stylesheets /usr/local/share/gems/gems/compass-0.12.6/frameworks/compass/stylesheets/ ],
          :cache => true,
          :cache_location => './.sass-cache',
          :syntax => :sass,
          :filesystem_importer => ::Sass::Importers::Filesystem
        }

        # Takes a file and parse it with Sass parser
        # @param file [String] path of the file which will be parsed
        # @return [{Symbol=>String}, false] which includes
        #   * :content   => the parsed content
        #   * :extension => converting type of the file
        #   or false if file name starts with '_' because these type of files
        #   must be imported and parsed with its parent file in sass.
        def self.parse(file)
          if ::File.basename(file, '.sass').start_with?('_')
            false
          else
            engine = ::Sass::Engine.for_file(file, OPTIONS)
            {content: engine.render, extension: '.css'}
          end
        end
      end
    end
  end
end