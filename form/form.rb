require 'hash_deep_merge'

class Neo::Form
  attr_accessor :data, :errors
  # create form class from data
  def initialize(data)
    @data = data
    @errors = {}

    defaults = {method: 'post', action:''}
    @data = defaults.deep_merge @data

    # her bir input'u ilgili class'ını çağırarak başlat
    @data[:inputs].each do |input|
      input_class = Neo::Form.const_get(input[:type].capitalize)
      input_bare_name = input[:name]
      input[:name] = @data[:name] + '_' +input[:name]
      new_input_class = input_class.new(input)
      self.class.send(:define_method,input_bare_name) { new_input_class }
    end
  end

  def start
    "<form name=\"#{@data[:name]}\" method=\"#{@data[:method]}\" action=\"#{@data[:action]}\" >"
  end

  def end
    '</form>'
  end

  # Tüm input elemanlarını tek tek gez her birinin tüm validationlarını çalıştır
  # eğer herhangi biri false döndürürse, hatasını al @errors içine kaydet, false döndür
  def valid?
    @errors = {}
    @data[:inputs].reduce(true) do |memo, input|
      form_data = Neo.req.POST.select {|k| k.start_with? "#{@data[:name]}_"}
      bare_name = input[:name].gsub(/^#{@data[:name]}_/, '')
      input_inst = self.send bare_name
      result = input_inst.valid? form_data
      @errors[bare_name] = input_inst.errors unless result
      (not result) ? result : memo
    end
  end

  def posted?
    not Neo.req.POST.blank?
  end

  # Gelen post datasını modele bind eder
  #
  # @param model [Hash] post datasının bağlamak istediğin model
  # @return [Neo::Database::Model]
  def fill_model(model)
    form_data = Neo.req.POST.select {|k| k.start_with? "#{@data[:name]}_"}
    form_data.hmap! {|k,v| {k.gsub(/^#{@data[:name]}_/, '') => v} }
    model.fill_model form_data
  end

end