require 'sass'

module Neo
  module Asset
    module Parsers
      class Sass

        # adds compass to load paths
        #   can be added more load paths later
        # @return [Array<String>] sass load paths
        def self.get_load_paths
          paths = ['.']
          compass = Neo.detect_gem_path 'compass-core'
          compass ? paths + ["#{compass}/stylesheets"] : paths
        end

        # init sass parser with these options
        OPTIONS = {
          style: :nested,
          :load_paths => self.get_load_paths,
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