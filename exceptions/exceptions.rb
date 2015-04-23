module Neo
	class Exceptions < StandardError

		def initialize(code,msg)
			@code = code
			@msg = msg
		end

		def raise
			if %w(dev test).any? {|env| env == Neo::Config[:env]}
				Kernel.raise self, "#{@code}: #{@msg}"
			else
				Neo::Response.send("error#{@code}")
			end
		end

	end
end