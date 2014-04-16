class Neo::Form::Submit
  attr_accessor :value
  def initialize(name,label=nil,value='',attr={}, label_attr={})
    super(name,label,attr,label_attr)
    @value = value
  end

  def to_tag
    tag = '<input type="text" name="'+@name+'" id="'+@name+'" '
    tag += 'value="'+@value+'" ' unless @value.blank?
    tag + get_attr_string + '/>'
  end
end