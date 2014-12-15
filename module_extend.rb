class Module
	def make_modular
		extend self
		self.init if self.respond_to? :init
		def copy_initial_instance_vars(extender)
			self.instance_variables.each do |var|
				extender.instance_variable_set(var, self.instance_variable_get(var))
			end
		end
		def self.extended(extender)
			copy_initial_instance_vars extender
		end
		def self.included(extender)
			alias_method :initialize, :init if self.respond_to? :init
			copy_initial_instance_vars extender
		end
	end
end