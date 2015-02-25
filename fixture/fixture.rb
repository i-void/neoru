# encoding: utf-8
require 'yaml'
class Neo::Fixture
	attr_accessor :data,:path
	def initialize(options)
		@paths = options[:paths]
		@sort_cols = options[:sort_cols] || {}
	end

	def parse_data
		@data = {}
		@paths.each do |path|
			@data.deep_merge! YAML.load(File.read(path, encoding: 'UTF-8'))
		end
		@data
	end

	def fill_sort_col(sort_col)
		unless sort_col.nil?
			sorter = TrSort.new case_sensitive: case_sensitive
			point = sorter.point_of obj_instance.send(sort_col)
			obj_instance.send("#{sort_col}_seq=",point)
		end
	end

	# @return [Hash]
	#   node_name: node_object
	def create_nodes
		nodes = {}
		@data.each do |model, value|
			obj = model.gsub('/','::Models::').to_obj
			value.each do |value_name, params|
				obj_instance = obj.new
				params.each do |key,param|
					if obj_instance.respond_to? "#{key}="
						obj_instance.send "#{key}=", param
					end
				end
				if (sort_cols = @sort_cols[model])
					sort_cols.each do |sort_col|
						fill_sort_col sort_col
					end
				end

				obj_instance.save
				nodes[value_name] = obj_instance
			end
		end
	end

	def load
		parse_data
		nodes = create_nodes

	end
end