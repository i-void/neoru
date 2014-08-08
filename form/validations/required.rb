class Neo::Form::Validations::Required < Neo::Form::Validations::Base
  def initialize(opts)
    defaults = {message: Neo.trn('Don\'t leave this field blank')}
    @opts = defaults.deep_merge opts
    @error = @opts[:message]
  end

  def get_tag_attributes
     {
      'data-rule-required' => 'true',
      'data-msg-required' => @opts[:message]
    }
  end

  def check(form_data, input_name)
    val = form_data[input_name]
    not val.blank?
  end
end