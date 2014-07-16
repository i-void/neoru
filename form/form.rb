require 'hash_deep_merge'

class Neo::Form
  attr_accessor :data
  # create form class from data
  def initialize(data)
    @data = data

    defaults = {method: 'post', action:''}
    @data = defaults.deep_merge @data

    # her bir input'u ilgili class'ını çağırarak başlat
    @data[:inputs].each do |input|
      input_class = Neo::Form.const_get(input[:type].capitalize)
      input_bare_name = input[:name]
      input[:name] = @data[:name] + '_' +input[:name]
      new_input_class = input_class.new(input)
      self.class.send(:define_method,input_bare_name) { return new_input_class }
    end
  end

  def start
    return "<form name=\"#{@data[:name]}\" method=\"#{@data[:method]}\" action=\"#{@data[:action]}\" >"
  end

  def end
    return '</form>'
  end



end