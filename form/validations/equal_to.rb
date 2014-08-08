class Neo::Form::Validations::EqualTo < Neo::Form::Validations::Base

  # opts
  #   :field
  def initialize(opts)
    defaults = {
      message: Neo.trn('This value should be equal to {{compared_value}}'),
    }
    @opts = defaults.deep_merge opts
    Neo::Exception.new(500, Neo.trn('You must set field parameter for EqualTo validator')).raise if @opts[:field].nil?
    @error = @opts[:message]
  end

  def get_tag_attributes
    {
      'data-rule-equal-to' => @field_label,
      'data-msg-equal-to' => @error
    }
  end

  def check(form_data, input_name)
    val = form_data[input_name]
    compared_value = form_data[@opts[:field]]

    unless @form.respond_to? @opts[:field]
      Neo::Exception.new(500, Neo.trn('Form doesn\'t have a field named: {{field}}').gsub('{{field}}',@opts[:field].to_s)).raise
    end
    @field_label = @form.send(@opts[:field]).opts[:label]
    @error = @opts[:message].gsub('{{compared_value}}',@field_label)

    val == compared_value
  end
end