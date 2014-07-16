class Fixnum
	def empty?
		true if self == 0
	end

  def default(definition)
    blank? ? definition : self
  end

  def random_char
    o = [('a'..'z'), (1..9)].map { |i| i.to_a }.flatten
    (0...self).map { o[rand(o.length)] }.join
  end
end