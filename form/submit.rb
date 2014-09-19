class Neo::Form::Submit < Neo::Form::Input
  def initialize(opts)
    super(opts)
  end

  def value=(value)
		@opts[:value] = value
  end

  def value
	  @opts[:value]
  end

  def to_tag
    tag = '<input type="submit" name="'+@opts[:name]+'" id="'+@opts[:name]+'" '
    tag += 'value="'+@opts[:value]+'" ' unless @opts[:value].blank?
    tag += get_attr_string.to_s + '/>'
    tag + error_html
  end
end