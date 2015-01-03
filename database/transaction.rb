require 'rest_client'
require 'base64'
require 'json'

class Neo::Database::Transaction
	COMMAND = '/db/data/transaction'
	TransactionHandler = Neo::Database::TransactionHandler

	attr_accessor :statements

	def initialize(host, port='7474')
		@host = host
		@port = port
		@encoded_key = Base64.encode64 ":#{Neo::Config[:db][:auth_key]}"
		@location = @statements = nil
	end

	def self.create
		TransactionHandler.start
		if block_given?
			begin
				yield
			rescue Exception => e
				TransactionHandler.rollback
				e.raise
			else
				TransactionHandler.commit
			end
		end
	end

	def self.commit
		TransactionHandler.commit
	end

	def self.rollback
		TransactionHandler.rollback
	end

	def headers
		{	content_type: 'application/json',
			accept: 'application/json; charset=UTF-8',
			authorization: "Basic realm=\"Neo4j\" #{@encoded_key}" }
	end

	def url
		"http://#{@host}:#{@port}#{COMMAND}"
	end

	def parameters
		{statements: @statements}.to_json
	end

	def handle_errors(response, rollback=true)
		self.rollback if rollback
		response_json = JSON.parse response
		errors = response_json['errors'].map {|error|
			"Code: #{error.code}, Error: #{error.message}"
		}
		Neo::Exceptions::DatabaseError.new(
			errors.join "\n"
		).raise
	end

	def beginned?
		not @location.nil?
	end

	def begin
		if beginned?
			@location
		else
			@statements = []
			response = RestClient.post url, parameters, headers
			@statements = nil
			if response.code == 201
				@location = response.headers[:location]
			else
				handle_errors response
			end
		end
	end

	def raise_transaction_not_started_error(message)
		Neo::Exceptions::DatabaseError.new(
			"'Transaction didn't started. You must firstly begin the transaction to #{message}'"
		).raise
	end

	def can_execute?
		raise_transaction_not_started_error('execute statements') unless beginned?
		unless @statements
			Neo::Exceptions::DatabaseError.new(
				'There isn\'t any executable statements in transaction. You must add some to execute.'
			).raise
		end
	end

	def execute
		can_execute?
		response = RestClient.post @location, parameters, headers
		if response.code == 200
			JSON.parse(response)['results']
		else
			handle_errors response
		end
	end

	def execute_statements(statements)
		@statements = statements
		result = execute
		@statements = nil
		result
	end

	def can_commit?
		raise_transaction_not_started_error('commit') unless beginned?
	end

	def commit
		can_commit?
		@statements = []
		response = RestClient.post "#{@location}/commit", parameters, headers
		@statements = nil
		if response.code == 200
			true
		else
			handle_errors response
		end
	end

	def can_rollback?
		raise_transaction_not_started_error('rollback') unless beginned?
	end

	def rollback
		can_rollback?
		response = RestClient.delete @location, headers
		if response.code == 200
			true
		else
			handle_errors response, false
		end
	end

	def commit_statements(statements)
		@statements = statements
		response = RestClient.post "#{url}/commit", parameters, headers
		@statements = nil
		if response.code == 200
			JSON.parse(response)['results']
		else
			handle_errors response, false
		end
	end
end