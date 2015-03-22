module Interface
	attr_reader :abstracted

	def abstract(func_name, params)
		@abstracted ||= {}
		@abstracted[func_name] = params
	end

	def check_implementation(klass, func_name, parameters)
		unless klass.methods.include? func_name
			raise NotImplementedError.new("##{func_name} must be implemented in #{klass}")
		end
		unless parameters.all? {|parameter|
			klass.method(func_name).parameters.any? {|param|
				if parameter.kind_of? Array
					param == parameter
				else
					param[1] == parameter
				end
			}
		}
			raise NotImplementedError.new("#{klass}##{func_name} must have parameters: #{parameters} ")
		end
	end

	def check_methods(obj)
		@abstracted.each do |key, value|
			check_implementation obj, key, value
		end
	end

end

class Class
	def implement(klass)
		include klass
		@klass = klass
		def self.new
			obj = super
			@klass.check_methods obj
			obj
		end
	end
end