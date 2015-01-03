module Neo::Database::TransactionHandler
	Transaction = Neo::Database::Transaction

	def initialize
		@transactions = []
		@host = (Neo::Config[:db][:host].blank?) ? '127.0.0.1' : Neo::Config[:db][:host]
		@port = (Neo::Config[:db][:port].blank?) ? '7474' : Neo::Config[:db][:port]
	end

	def start
		transaction = Transaction.new @host, @port
		transaction.begin
		@transactions << transaction
	end

	def commit
		transaction = @transactions.pop
		transaction.commit
	end

	def rollback
		transaction = @transactions.pop
		transaction.rollback
	end

	def current
		@transactions.last
	end

	# if there is no current open transaction you can use
	#   this method to commit queries
	def commit_statements(statements)
		transaction = Transaction.new @host, @port
		transaction.commit_statements statements
	end

	make_modular
end