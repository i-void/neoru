class Neo::Form::Checkbox < Neo::Form::Input
  attr_accessor :checked
  def initialize(name,label=nil,checked=false,attr={})
    super(name,label,attr)
    @checked = checked
  end

  def to_tag
    tag = '<input type="checkbox" name="'+@name+'" id="'+@name+'" '
    tag += 'checked ' if @checked
    @attr.each do |k,v|
      tag += "#{k}=\"#{v}\" "
    end
    tag + "/><label for=\"#{@name}\">#{@label}</label>"
  end
end