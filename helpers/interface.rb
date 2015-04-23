module Interface
	attr_reader :abstracted

	def abstract(func_name, params=[])
		@abstracted ||= {}
		@abstracted[func_name] = params
	end

	def check_parameter(parameter, func_parameters)
		func_parameters.any? {|param|
			if parameter.kind_of? Array
				param == parameter
			else
				param[1] == parameter
			end
		}
	end

	def check_implementation(klass, func_name, parameters)
		func_parameters = begin
			klass.method(func_name.to_sym).parameters
		rescue NameError
			nil
		end
		if func_parameters.nil?
			raise NotImplementedError.new("##{func_name} must be implemented in #{klass}")
		else
			unless parameters.all? {|param| check_parameter param, func_parameters }
				raise NotImplementedError.new("#{klass}##{func_name} must have parameters: #{parameters} ")
			end
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
		def self.new(**args)
			obj = super(args)
			@klass.check_methods obj
			obj
		end
	end
end