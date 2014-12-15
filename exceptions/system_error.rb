module Neo
	class Exceptions
		class SystemError < Exceptions
			def initialize(msg)
				super(500, msg)
			end
		end
	end
end