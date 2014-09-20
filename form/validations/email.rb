class Neo::Form::Validations::Email < Neo::Form::Validations::Base
  def initialize(opts, form)
    defaults = {message: Neo.trn('Please enter a valid email address')}
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
    if val.blank?
      true
    else
      regex = <<-'REG'.gsub("\n",'').strip
        ^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?
      REG
      not (val =~ /#{regex}/).nil?
    end
  end
end