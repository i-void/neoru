class Neo::Form::Label
  attr_accessor :l_for, :text, :attr

  def initialize(l_for,text,attr={})
    @l_for = l_for
    @attr = attr
    @text = text
  end

  # attributeleri diziden tag stringine çevirip getirir
  def get_attr_string
    attrs = ''
    @attr.each do |k,v|
      attrs += v.blank? ? k+' ' : k+'="'+v+'" '
    end unless @attr.nil?
  end

  def to_tag
    ''
    '<label for="'+@l_for+'" '+get_attr_string.to_s+'>'+@text+'</label>' unless @text.blank?
  end
end