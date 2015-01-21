class Neo::Commands::ModelGenerator::AModel
	def initialize(module_name, name, data)
		@module = module_name
		@name = name.to_s
		@properties = data[:HasProperties]
		@has_many = data[:HasMany]
		@has_one = data[:HasOne]
	end

	def make_file(module_path)
		file_path = File.join module_path, "#{@name.underscore}.rb"
		@file = File.open file_path, 'w'
	end

	def write_accessors
		unless @properties.blank?
			@file.puts ''
			@file.puts "  attr_accessor :#{@properties.join ', :'}"
		end
	end

	def write_class
		@file.puts "class #{@module}::Models::#{@name} < Neo::Database::Model"
		@file.puts "  #{@name}Query = #{@module}::Models::#{@name}Query"
		write_accessors
		@file.puts 'end'
	end


	def generate
		write_class
		@file.close
	end
end