require 'hash_deep_merge'

module Neo::Config
  class << self
    attr_accessor :main
  end

  Dir[Neo.app_dir+'/config/*.rb'].each do |f|
    require f
  end

  App::Conf.make_static

  env_var = "@#{App::Conf.init[:env]}"
  env = App::Conf.instance_variable_get(env_var)
  env[:asset_sets] = App::Conf.asset_sets
  env[:assets] = App::Conf.assets
  Neo::Params.env = App::Conf.init[:env]
  @main = App::Conf.init.deep_merge(env)
end