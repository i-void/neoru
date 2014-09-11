#require 'digest'

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

  def to_class
    split('::').inject(Object) {|o,c| o.const_get c}
  end

  def default(definition)
    blank? ? definition : self
  end

  def to_obj
    parts = self.split '::'
    parts.reduce(Object) do |memo, i|
      memo.const_get i
    end
  end

  def to_md5
    Digest::MD5.hexdigest self
  end

  def generate_salt
    (self.split('').reduce(1) {|memo, letter|
      num = letter.to_i 32
      num = 1 if num == 0
      memo + num
    }).to_s
  end
end