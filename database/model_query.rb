Neo.use 'database:cypher'
module Neo
	module Database
		class ModelQuery < Cypher
			attr_accessor :model,:labels
			def initialize
				super
				module_name, class_name = self.class.name.scan(/(.+)::Models::(.+)Query/)[0]
				@model = Kernel.const_get(module_name).const_get('Models').const_get(class_name)
				@labels = @model.new.labels
				@labels = [@labels] if @labels.kind_of?(String)
				add_match('n',@labels+ [Neo::Config.main[:db][:name]])
			end

			def find_one
				set_limit(1)
				return find
			end

			def find
				set_return('n')
				return fill_model(@model)
			end
		end
	end
end