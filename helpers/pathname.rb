class Pathname
	def each_child_recursively(&block)
		self.each_child do |path|
			yield path
			if path.directory?
				path.each_child_recursively &block
			end
		end
	end
end