class Object
  def blank?
    true if defined?(self).nil? or self.nil? or (self.methods.include?(:empty?) and self.empty?)
  end

  def if_blank
    blank? ? yield : self
  end

  def if_nil
    nil? ? yield : self
  end
end