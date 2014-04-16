class Neo::Form::Textarea < Neo::Form::Input
  attr_accessor :opts

  def initialize(opts)
    #name,label=nil,value='',attr={}, label_attr={}
    @opts = opts
    super(@opts[:name],@opts[:label],@opts[:attr],@opts[:label_attr])
  end

  def to_tag
    tag = '<textarea name="'+@opts[:name]+'" id="'+@opts[:name]+'" '+get_attr_string.to_s
    tag += @opts[:value] unless @opts[:value].blank?
    tag + '></textarea>'
  end

end