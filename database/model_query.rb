Neo.use 'database:cypher'
module Neo
	module Database
		class ModelQuery < Cypher
			attr_accessor :model,:labels
			def initialize
				super
				module_name, class_name = self.class.name.scan(/(.+)::Models::(.+)Query/)[0]
				@model = Kernel.const_get(module_name).const_get('Models').const_get(class_name).new
				@labels = @model.labels
				add_match('n',@labels)
			end

			def find_one
				set_limit(1)
				set_return('n')
				result = run
				props = result['data'][0][0]['data']
				props.each do |k,v|
					@model.instance_variable_set('@'+k,v)
				end
				return @model
			end
		end
	end
end