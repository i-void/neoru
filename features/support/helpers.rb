World do
  require 'pp'
  require 'rspec'

  require './neo'

  Neo.app_dir = '.'
  Neo.dir = '.'

  module Neo::Config
    extend self

    attr_accessor :main

    @main = {
      :env => 'dev',
      :default_module => 'site',
      :lang => 'TrTr',
      :routes => {}
    }
  end

  Neo.run
end