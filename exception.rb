module Neo
  class Exception
    attr_accessor :code,:msg
    def initialize(code, msg)
      @code, @msg = code, msg
    end

    def raise
      if Neo::Config.main[:env] == 'dev'
        Kernel.raise("#{@code} : #{@msg}")
      else
        Neo::Response.send("error#{@code}")
      end
    end
  end
end