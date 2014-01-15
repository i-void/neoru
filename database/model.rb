Neo.use 'database:node'
Neo.use 'database:model_query'
module Neo
	module Database
		class Model
			attr_accessor :id
			def labels=(labels)
				@labels = labels
			end
			def labels
				return @labels
			end
			def save
				node = Node.new.fill_from_model(self)
				@id = node.upsert
			end
			def relate_to(node,relation_name,props={})
				self_node = Node.new.fill_from_model(self)
				node = Node.new.fill_from_model(node)
				self_node.relate_to(node,relation_name,props)
			end
		end
	end
end