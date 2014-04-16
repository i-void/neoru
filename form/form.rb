class Neo::Form::Form
  attr_accessor :data
  # create form class from data
  def initialize(data)
    @data = data

    @data[:inputs].each do |input|
      input_class = ('Neo::Form::'+input[:type].capitalize).to_class
      new_input_class = input_class.new(input)
      self.class.send(:define_method,input[:name]) { return new_input_class }
    end
  end
end