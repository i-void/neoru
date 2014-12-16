World do
  require 'pp'
  require 'rspec'

  require './neo'

  Neo.app_dir = "#{File.dirname(__FILE__)}/../../features_fake_app"
  Neo.dir = '.'

  Neo.run
end