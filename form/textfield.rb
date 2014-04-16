class Neo::Form::Textfield < Neo::Form::Input
  attr_accessor :opts

  def initialize(opts)
    #name,label=nil,value='',attr={}, label_attr={}
    @opts = opts
    super(@opts[:name],@opts[:label],@opts[:attr],@opts[:label_attr])
  end

  def to_tag
    tag = '<input type="text" name="'+@opts[:name]+'" id="'+@opts[:name]+'" '
    tag += 'value="'+@opts[:value]+'" ' unless @opts[:value].nil?
    tag + get_attr_string.to_s + '/>'
  end

end
