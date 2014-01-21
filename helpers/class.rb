class Class
	def blank?
		true if defined?(self).nil? or self.nil? or self.empty?
	end
end