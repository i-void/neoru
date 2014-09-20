class Neo::Form::Validations::Length < Neo::Form::Validations::Base

  # opts
  #   :min, :max, :min_message, :max_message
  def initialize(opts,form)
    defaults = {
      exact_message: Neo.trn('This value should have exactly {{limit}} characters.'),
      min_message: Neo.trn('This value is too short. It should have {{limit}} characters or more.'),
      max_message: Neo.trn('This value is too long. It should have {{limit}} characters or less.'),
    }
    @opts = defaults.deep_merge opts
    @error = @opts[:exact_message]
  end

  def get_tag_attributes
    {
      'data-rule-required' => 'true',
      'data-msg-required' => @opts[:message]
    }
  end

  def check(form_data, input_name)
    val = form_data[input_name]
    if @opts[:min] and @opts[:max] and @opts[:min]==@opts[:max] and (val.length < @opts[:min] or val.length > @opts[:max])
      @error = @opts[:exact_message].gsub('{{limit}}', @opts[:max].to_s)
      false
    elsif @opts[:min] and val.length < @opts[:min]
      @error = @opts[:min_message].gsub('{{limit}}', @opts[:min].to_s)
      false
    elsif @opts[:max] and val.length > @opts[:max]
      @error = @opts[:max_message].gsub('{{limit}}', @opts[:max].to_s)
      false
    else
      true
    end
  end
end