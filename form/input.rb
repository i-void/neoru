class Neo::Form::Input
  attr_accessor :name,:errors,:label,:attr,:opts
  attr_reader :validations

  def initialize(opts)
    @name = opts[:name]
    @label = Neo::Form::Label.new(@name,opts[:label],opts[:label_attr])
    @errors = []
    @attr = !opts[:attr].nil? ? opts[:attr] : {}
    @validations = opts[:validations]
    @form = opts[:form]
    @opts = opts
    set_validations
  end

  def set_validations
    @validations.each do |rule,params|
      validator = Neo::Form::Validations.const_get(rule.to_s.camelize).new(params,@form)
      @attr = validator.get_tag_attributes.deep_merge @attr
    end unless @validations.nil?
  end

  def valid? form_data
    @errors = []
    # validationların hepsinin true dönmesi durumunda true getir
    if @validations.nil?
      true
    else
      @validations.reduce(true) do |memo, (rule,params)|
        validator = Neo::Form::Validations.const_get(rule.to_s.camelize).new(params,@form)
        result = validator.check form_data, @name
        @errors << validator.error unless result
        (not result) ? result : memo
      end
    end
  end

  def value=(value)
		@attr[:value] = value
  end

  def value
	  @attr[:value]
  end
  # attributeleri diziden tag stringine çevirip getirir
  def get_attr_string
    if @attr.nil?
      ''
    else
      @attr.reduce('') do |attr, (k, v)|
        k = k.to_s
        attr += v.blank? ? k+' ' : k+'="'+v+'" '
      end
    end
  end

  def error_html
    if @errors.blank?
      ''
    else
      # error_text = @errors.reduce('') {|error_text, error| error_text += (error + '<br>')}
      # error_text = error_text[0..-5]
      "\n<div class='validation_error'>#{@errors[0]}</div>"
    end
  end

end
