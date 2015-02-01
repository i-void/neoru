class Neo::Commands::ModelGenerator::AModel
	attr_accessor :reversed_relations

	def initialize(module_name, name, data)
		@module = module_name
		@name = name.to_s
		@properties = data[:HasProperties]
		@has_many = data[:HasMany] || {}
		@has_one = data[:HasOne] || {}
		@reversed_relations = {}
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

	def get_module_and_model_name(model)
		if model.kind_of?(Hash)
			[model.keys[0], model.values[0]]
		else
			[@module, model]
		end
	end

	def add_reversed_relation(relation, model)
		_module, _name = get_module_and_model_name model
		_module = _module.to_sym
		reversed_relations[_module] ||= {}
		reversed_relations[_module][_name] ||= {}
		reversed_relations[_module][_name][relation] = @name
	end

	def write_has_many_relations
		unless @has_many.blank?
			@has_many.each do |relation, model|
				add_reversed_relation relation, model
				model_name = (model.kind_of? Hash)? model.values[0] : model
				relation_name = relation.to_s.underscore
				@file.puts ''
				@file.puts "  def get_all_#{relation_name}"
				@file.puts "    #{model_name}Query.new.#{relation_name}_of_#{@name.underscore}(self).find"
				@file.puts '  end'
			end
		end
	end

	def write_has_one_relations
		unless @has_one.blank?
			@has_one.each do |relation, model|
				add_reversed_relation relation, model
				model_name = (model.kind_of? Hash)? model.values[0] : model
				relation_name = relation.to_s.underscore
				@file.puts ''
				@file.puts "  def get_#{relation_name}"
				@file.puts "    #{model_name}Query.new.#{relation_name}_of_#{@name.underscore}(self).find_one"
				@file.puts '  end'
			end
		end
	end

	def write_constants
		models = [@name] + @has_many.values + @has_one.values
		models.uniq.each do |model|
			_module, _name = get_module_and_model_name model
			@file.puts "  #{_name}Query = #{_module}::Models::#{_name}Query"
		end
	end

	def write_initializer
		@file.puts ''
		@file.puts '  def initialize'
		@file.puts "    @labels = '#{@name}'"
		@file.puts '  end'
		@file.puts ''
	end

	def write_class
		@file.puts "class #{@module}::Models::#{@name} < Neo::Database::Model"
		write_constants
		write_accessors
		write_initializer
		write_has_many_relations
		write_has_one_relations
		@file.puts 'end'
	end


	def generate
		write_class
		@file.close
	end
end