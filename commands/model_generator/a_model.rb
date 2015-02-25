class Neo::Commands::ModelGenerator::AModel
	attr_accessor :reversed_relations
  attr_reader :name, :uniq_properties

	def initialize(module_name, name, data)
		@module = module_name
		@name = name.to_s
    @uniq_properties = data[:HasProperties].select{|property| property.start_with?('+')}.map{|property| property.gsub(/^[\+]/, '')}
		@properties = data[:HasProperties].map{|property| property.gsub(/^[\+\/]/, '')}
		@has_many = data[:HasMany] || {}
		@has_one = data[:HasOne] || {}
		@reversed_relations ||= {}
	end

	def make_file(module_path)
		file_path = File.join module_path, "#{@name.underscore}.rb"
		@file = File.open file_path, 'w'
	end

  def append_to_file(module_path)
    file_path = File.join module_path, "#{@name.underscore}.rb"
    @file = File.open file_path, 'a'
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
		@reversed_relations[_module] ||= {}
		@reversed_relations[_module][_name] ||= {}
		@reversed_relations[_module][_name][relation] ||= []
    @reversed_relations[_module][_name][relation] << @name
	end

  def generate_reversed_many_relations(module_objs)
    unless @has_many.blank?
      @has_many.each do |relation, model|
        _module, _name = get_module_and_model_name model
        relation_name = relation.to_s.underscore
        module_obj = module_objs[_module.to_sym]
        Neo::Exceptions::SystemError.new(
          "\n#{_module} module cannot be found in \n#{module_objs.map{|obj| obj[0].to_s}}]} \n for #{@module}/#{@name}"
        ).raise unless module_obj
        model_obj = module_obj.model_objs.find{|model_i|
          model_i.name == _name
        }
        uniq_props = model_obj.uniq_properties
        uniq_props.each do |property|
          func_name = (property == uniq_props[0]) ? relation_name : "#{relation_name}_#{property}"
          @file.puts ''
          @file.puts "  def get_#{func_name}(#{relation_name}_#{property})"
          @file.puts "    #{_name}Query.new.#{relation_name}_of_#{@name.underscore}(self).by_#{property}(#{relation_name}_#{property}).find_one"
          @file.puts '  end'
          @file.puts ''
          @file.puts "  def add_#{func_name}(#{relation_name}_#{property})"
          @file.puts "    #{relation_name} = get_#{func_name} #{relation_name}_#{property}"
          @file.puts "    unless #{relation_name}"
          @file.puts "      #{relation_name} = #{_name}Query.new.by_#{property}(#{relation_name}_#{property}).find_one"
          @file.puts "      if #{relation_name}"
          @file.puts "        self.relate_to #{relation_name}, 'Has#{relation_name.camelize}'"
          @file.puts '      else'
          @file.puts "        Neo::Exceptions::DatabaseError.new(\"#{relation_name} cannot found with #{property}: \#{#{relation_name}_#{property}}\").raise"
          @file.puts '      end'
          @file.puts '    end'
          @file.puts "    #{relation_name}"
          @file.puts '  end'
          @file.puts ''
          @file.puts "  def remove_#{func_name}(#{relation_name}_#{property})"
          @file.puts "    #{relation_name} = get_#{func_name} #{relation_name}_#{property}"
          @file.puts "    self.unrelate_to(#{relation_name}, 'Has#{relation_name.camelize}') if #{relation_name}"
          @file.puts '  end'
        end
      end
    end
    @file.puts 'end'
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
				@file.puts ''
				@file.puts "  def set_#{relation_name}(#{relation_name})"
				@file.puts "    prev = get_#{relation_name}"
				@file.puts "    if prev and prev != #{relation_name}"
				@file.puts "      self.unrelate_to #{relation_name}, 'Has#{relation_name.camelize}'"
				@file.puts '    end'
        @file.puts "    if not prev or prev != #{relation_name}"
        @file.puts "      self.relate_to #{relation_name}, 'Has#{relation_name.camelize}'"
				@file.puts '    end'
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
	end


	def generate
		write_class
		@file.close
	end
end