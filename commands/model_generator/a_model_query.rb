class Neo::Commands::ModelGenerator::AModelQuery
	def initialize(module_name, name, data)
		@module = module_name
		@name = name.to_s
		@properties = data[:HasProperties]
		@has_many = data[:HasMany]
		@has_one = data[:HasOne]
	end

	def make_file(module_path)
		file_path = File.join module_path, "#{@name.underscore}_query.rb"
		@file = File.open file_path, 'w'
	end

	def write_class
		@file.puts "class #{@module}::Models::#{@name}Query < Neo::Database::Model"
		@file.puts 'end'
	end


	def generate
		write_class
		@file.close
	end
end