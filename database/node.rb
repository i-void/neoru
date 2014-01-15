Neo.use 'database:query'
module Neo
	module Database
		class Node
			attr_accessor :properties,:labels,:id,:model

			def initialize
				@labels = [Neo::Config.main[:db][:name]]
			end

			def fill_from_model(model)
				@properties = model.instance_variables
				@model = model
				@id = model.id
				labels = model.labels.kind_of?(Array)?(model.labels):[model.labels]
				@labels += labels
				return self
			end

			def insert(id)
				properties = {:id=>id}
				@properties.each do |prop|
					properties[prop.to_s.gsub('@','')] = @model.instance_variable_get(prop) unless prop=='@labels'.to_sym
				end
				cypher = Cypher.new
				cypher.add_create('n',@labels,properties)
				cypher.set_return('n')
				result = cypher.run
				increase_id(id) if result['data'].length>0
			end

			def relate_to(node,relation_name,relation_props={})
				cypher = Cypher.new.add_match('n',@labels,{:id=>@id}).add_match('m',node.labels,{:id=>node.id})
				rel_params = ''
				rel_params = ' {rel_params}' unless relation_props.blank?
				cypher.add_create('n',[],'',"-[r:#{relation_name}#{rel_params}]->(m)")
				unless relation_props.blank?
					cypher.add_parameters(:rel_params=>relation_props)
				end
				cypher.set_return('r')
				result = cypher.run
				return result
			end

			def upsert
				if @id.nil?
					id = generate_id
					insert(id)
					@id = id
					return id
				end
			end

			def increase_id(id)
				table_name = 'Neo4jUniqueId'
				labels = [Neo::Config.main[:db][:name],table_name]
				uid_cyp = Cypher.new
				uid_cyp.add_match('n',labels)
				uid_cyp.add_set('n',{:id=>id})
				uid_cyp.set_return('n')
				uid_cyp.run
			end

			def generate_id
				table_name = 'Neo4jUniqueId'
				labels = [Neo::Config.main[:db][:name],table_name]
				cypher = Cypher.new
				cypher.add_match('n',labels)
				cypher.set_return('n.id')
				result = cypher.run
				if result['data'].length>0
					id  = result['data'][0][0].to_s
					id = id.to_i(36)+1
					return id.to_s(36)
				else
					create = Cypher.new
					create.add_create('n',labels,{:id=>1})
					create.set_return('n')
					create.run
					return '1'
				end
			end
		end
	end
end