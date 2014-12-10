module App
  class Conf
    @default = {}
    @dev = {}
    @prod = {}

    def self.default(opts=nil)
      opts.nil? ? @default : @default.deep_merge!(opts)
    end

    def self.dev(opts=nil)
      opts.nil? ? @dev : @dev.deep_merge!(opts)
    end

    def self.prod(opts=nil)
      opts.nil? ? @prod : @prod.deep_merge!(opts)
    end
  end
end


module Neo
  class Config
    class << self
      attr_accessor :main
    end

    config_directories = %W(#{Neo.app_dir}/config/*.rb #{Neo.app_dir}/modules/*/config/*.rb)
    config_directories.each do |dir|
      Dir[dir].each do |f|
        require f
      end
    end

    env_var = App::Conf.default[:env]
    env = App::Conf.send(env_var)
    Neo::Params.env = env_var
    @main = App::Conf.default
    @main.deep_merge!(env)
  end
end