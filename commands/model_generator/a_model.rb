class Neo::Commands::ModelGenerator::AModel
	def initialize(module_name, name, data)
		@module = module_name
		@name = name.to_s
		@properties = data[:HasProperties]
		@has_many = data[:HasMany] || {}
		@has_one = data[:HasOne] || {}
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

	def write_has_many_relations
		unless @has_many.blank?
			@has_many.each do |relation, model|
				model_name = (model.kind_of? Hash)? model.values[0] : model
				@file.puts ''
				@file.puts "  def get_all_#{relation.to_s.underscore}"
				@file.puts "    #{model_name}Query.new.belongs_to_data(self).find"
				@file.puts '  end'
			end
		end
	end

	def write_constants
		models = [@name] + @has_many.values + @has_one.values
		models.uniq.each do |model|
			_module, _name =
				if model.kind_of?(Hash)
					[model.keys[0], model.values[0]]
				else
					[@module, model]
				end
			@file.puts "  #{_name}Query = #{_module}::Models::#{_name}Query"
		end
	end

	def write_class
		@file.puts "class #{@module}::Models::#{@name} < Neo::Database::Model"
		write_constants
		write_accessors
		write_has_many_relations
		@file.puts 'end'
	end


	def generate
		write_class
		@file.close
	end
end