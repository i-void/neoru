class Neo::Database::Cypher < Neo::Database::Query
  def initialize
    super('db/data/cypher')
  end
end