class Neo::Form::Input
  attr_accessor :name,:errors,:label,:attr

  def initialize(name,label,attr,label_attr={})
    @name = name
    @label = Neo::Form::Label.new(@name,label,label_attr)
    @errors = []
    @attr = attr
  end

  # attributeleri diziden tag stringine çevirip getirir
  def get_attr_string
    attrs = ''
    @attr.each do |k,v|
      k = k.to_s
      attrs += v.blank? ? k+' ' : k+'="'+v+'" '
    end unless @attr.nil?
    return attrs
  end

end
