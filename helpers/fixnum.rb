class Fixnum
	def empty?
		true if self ==0
	end
	def blank?
		true if defined?(self).nil? or self.nil? or self.empty?
	end
end