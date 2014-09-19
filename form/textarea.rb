class Neo::Form::Textarea < Neo::Form::Input
  attr_accessor :opts

  def initialize(opts)
    super(opts)
  end

  def to_tag
    tag = '<textarea name="'+@opts[:name]+'" id="'+@opts[:name]+'" '+get_attr_string.to_s
    tag += @opts[:value] unless @opts[:value].blank?
    tag += '></textarea>'
    tag + error_html
  end

end