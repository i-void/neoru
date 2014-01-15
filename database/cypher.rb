Neo.use 'database:query'
module Neo
	module Database
		class Cypher < Query
			def initialize
				super('db/data/cypher')
			end
		end
	end
end