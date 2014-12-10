class Neo::Command::ClearDb
	Cypher = Neo::Database::Cypher
	def run
		Cypher.new.query('OPTIONAL MATCH (n:$)-[r]-(m:$) DELETE n,r,m').run
		Cypher.new.query('MATCH (n:$) DELETE n').run
	end
end