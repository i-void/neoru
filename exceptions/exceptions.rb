module Neo
	class Exceptions < StandardError

		def initialize(code,msg)
			@code = code
			@msg = msg
		end

		def raise
			if Neo::Config.main[:env] == 'dev'
				Kernel.raise self, "#{@code}: #{@msg}"
			else
				Neo::Response.send("error#{@code}")
			end
		end

	end
end