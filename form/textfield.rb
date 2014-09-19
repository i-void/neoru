class Neo::Form::Textfield < Neo::Form::Input
  attr_accessor :opts

  def initialize(opts)
    super(opts)
  end

  def to_tag
    tag = '<input type="text" name="'+@opts[:name]+'" id="'+@opts[:name]+'" '
    tag += 'value="'+@opts[:value]+'" ' unless @opts[:value].nil?
    tag += get_attr_string.to_s + '/>'
    tag + error_html
  end

end
