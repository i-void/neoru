module Neo
	class Params
		class << self
			attr_accessor :module,:controller,:action
			def take_post(var)
				Neo.req.POST[var]
			end
		end
	end
end