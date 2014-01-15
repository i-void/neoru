class String
  def camelize
    split('_').map { |w| w.capitalize }.join
  end

  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr('-', '_').
        downcase
  end

  def blank?
    true if defined?(self).nil? or self.nil? or self.empty?
  end
end