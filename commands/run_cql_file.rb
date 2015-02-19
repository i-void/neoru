class Neo::Commands::RunCqlFile < Neo::Command
  Cypher = Neo::Database::Cypher
  Transaction = Neo::Database::Transaction

  # Takes the cql/text file and
  #   execute queries in it
  # @param cql_file_path [string]
  #   path of cql/txt file relative to app_dir
  def run(cql_file_path)
    @path = File.join Neo.app_dir, cql_file_path
    Transaction.create do
      execute_queries
    end
  end

  def execute_queries
    File.open(@path,'r').each_line do |line|
      execute(line.chomp)
    end
  end

  def execute(query)
    Cypher.new.query(query).run
  end
end