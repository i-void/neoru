class Neo::Params
  class << self
    attr_accessor :module,:controller,:action, :env
    def take_post(var)
      Neo.req.POST[var]
    end
    def take_get(var)
      Neo.req.GET[var]
    end
    def take_file(var)
      Neo.req.FILE[var]
    end
  end
end