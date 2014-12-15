module Neo
	class Exceptions
		class DatabaseError < Exceptions
			def initialize(msg)
				super(500, msg)
			end
		end
	end
end