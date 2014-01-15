require 'pp'

module Neo
	class ConstMisser
		def const_missing(const)
			const_get(const)
		end
	end
end

class Module
	# preserves the original method
	alias_method :old_const_missing, :const_missing
	private :old_const_missing

	def class_from_string(str)
		pp str
		found_obj = nil
		str.split('::').inject(Object) do |mod, class_name|
			found_obj = mod.const_get(class_name)
			$found[found_obj.name] = mod.const_get(class_name)
		end
		return found_obj
	end

	# redefine the method which is called on a missing const
	def const_missing(const)
		$new_module = Module.new if defined?($new_module).nil?
		$autoload_path = [] if $autoload_path.blank?
		$autoload_mods = [] if $autoload_mods.blank?
		$found = {} if $found.blank?

		class_symbol = ''
		begin
			blah = old_const_missing(const)
		rescue NameError => e
			class_symbol = e.message.gsub('uninitialized constant ','')
		end

		class_symbol_parts = class_symbol.split '::'
		initer = class_symbol_parts[0..-2].join('::')
		mod = class_symbol_parts[-1]

		if $found.key?(class_symbol)
			$autoload_path = []
			$autoload_mods = []
			return $found[self_part]
		end

		roots = {
			:App => Neo.app_dir,
			:Neo => Neo.dir,
		   :Modules => Neo.app_dir + '/modules'
		}

		if $autoload_path.length == 0
			if roots.key?(initer.to_sym)
				$autoload_path << roots[initer.to_sym]
				$autoload_mods << initer
				path = roots[initer.to_sym]+'/'+mod.underscore
				if File.directory?(path)
				   $autoload_path << mod.underscore
				   $autoload_mods << mod
				   return $new_module
				elsif File.file?(path+'.rb')
					$autoload_mods << mod
					return load_module(path)
				end
			end
			if $found.key?(initer) and defined?($found[initer])=='method'
				$autoload_path << roots[:Modules] + '/' + initer.underscore
				$autoload_mods << initer
				path = $autoload_path[0]+'/'+mod.underscore
				if File.directory?(path)
					$autoload_path << mod.underscore
					$autoload_mods << mod
					return $new_module
				elsif File.file?(path+'.rb')
					$autoload_mods << mod
					return load_module(path)
				end
			end
			if roots.key?(mod.to_sym) and $found.key?(initer)
				$autoload_path << roots[mod.to_sym]
				$autoload_mods << mod
				return $new_module
			end
			if mod.nil?
				mod = initer
			end
			path = roots[:Modules]+'/'+mod.underscore
			if File.directory? path
				$autoload_path << path
				$autoload_mods << mod
				return $new_module
			elsif File.file?(path+'.rb')
				$autoload_mods << mod
				return load_module(path)
			end
		else
			path = $autoload_path.join('/') + '/' + mod.underscore
			if File.directory? path
				$autoload_path << mod.underscore
				$autoload_mods << mod
				return $new_module
			elsif File.file?(path+'.rb')
				$autoload_mods << mod
				return load_module(path)
			end
		end
	end

	def load_module(path)
		real_class_path = $autoload_mods.join('::')
		$autoload_path = []
		$autoload_mods = []
		begin
			require path
			return class_from_string(real_class_path)
		rescue LoadError => e
			if e.message.include? path
				old_const_missing(const)
			else
				raise
			end
		end
	end
end