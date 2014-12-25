module Neo
  module Asset
    module Parsers
      module Scss
        extend Neo::Asset::Parsers::Sass

        def initialize
          @extension = 'scss'
          set_options
        end

        make_modular
      end
    end
  end
end