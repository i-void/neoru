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

  def filled?(func=nil)
    if func or block_given?
      unless self.blank?
        ret = func ? self.send(func) : nil
        block_given? ? yield : ret
      end
    else
      not self.blank?
    end
  end
end