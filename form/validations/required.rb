require 'hash_deep_merge'

class Neo::Form::Validations::Required
  attr_accessor :error

  def initialize(opts)
    defaults = {message:'Bu alanı boş bırakmayınız'}
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