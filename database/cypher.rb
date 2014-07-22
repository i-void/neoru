module Neo
  module Database
    class Cypher < Neo::Database::Query
      def initialize
        super('db/data/cypher')
      end
    end
  end
end