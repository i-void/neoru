require 'hash_deep_merge'

module Neo::Config
  class << self
    attr_accessor :main
  end
  require Neo.app_dir+'/app_conf.rb'
  env = instance_variable_get("@#{@init[:env]}")
  Neo::Params.env = @init[:env]
  @main = @init.deep_merge(env)
end