# encoding: utf-8
Neo.use 'exception'
module Neo
	module Database
		class Exception < Neo::Exception
			def initialize(msg)
				super(500,msg)
			end
		end
	end
end