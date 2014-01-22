class NilClass
	def blank?
		true if defined?(self).nil? or self.nil?
	end

	def length
		return 0
	end
end