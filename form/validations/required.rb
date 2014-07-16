require 'hash_deep_merge'

class Neo::Form::Validations::Required
  def initialize(opts)
    defaults = {message:'Bu alanı boş bırakmayınız'}
    @opts = defaults.deep_merge opts
  end

  def get_tag_attributes
    return {
      'data-rule-required' => 'true',
      'data-msg-required' => @opts[:message]
    }
  end
end