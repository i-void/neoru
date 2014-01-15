class NilClass
  def blank?
    true if defined?(self).nil? or self.nil?
  end
end