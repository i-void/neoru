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

	def write_class(reversed_relations)
		@file.puts "class #{@module}::Models::#{@name}Query < Neo::Database::ModelQuery"
		write_property_queries
		write_relation_queries reversed_relations
		@file.puts 'end'
	end

	def write_property_queries
		@properties.each do |property|
			prop_name = property.to_s.underscore
			@file.puts ''
			@file.puts "  def by_#{prop_name}(#{prop_name})"
			@file.puts "    self.add_where([%w[#{prop_name} = {#{prop_name}}]]).add_parameters #{prop_name}: #{prop_name}"
			@file.puts '  end'
		end unless @properties.blank?
	end

	def write_relation_queries(reversed_relations)
		reversed_relations[@module.to_sym].each do |model, relations|
			if model == @name
				relations.each do |relation, to_model|
					to_model_u = to_model.to_s.underscore
					@file.puts ''
					@file.puts "  def #{relation.to_s.underscore}_of_#{to_model_u}(#{to_model_u})"
					@file.puts "    self.add_match('#{to_model_u}','#{to_model}',{id: #{to_model_u}.id}, '-[r:Has#{relation}]->n')"
					@file.puts '  end'
				end
			end
		end unless reversed_relations[@module.to_sym].blank?
	end

	def generate(reversed_relations)
		write_class	reversed_relations
		@file.close
	end
end