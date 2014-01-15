# encoding: utf-8
require 'yaml'
module Neo
	class Fixture
		attr_accessor :data,:path
		def initialize(path)
			@path = path
		end

		def parse_data
			@data = YAML.load(File.read(@path, encoding: 'UTF-8'))
		end

		def load
			parse_data
			@data.each do |model, value|
				obj = eval(model)
				value.each do |params|
					obj_instance = obj.new
					params.each do |key,param|
						obj_instance.instance_variable_set('@'+key,param)
					end
					obj_instance.save
				end
			end
		end
	end
end