class Neo::Form
  attr_accessor :data, :errors
  # create form class from data
  def initialize(data)
    @data = data
    @errors = {}

    defaults = {method: 'post', action:'', csrf_protection: true}
    @data = defaults.deep_merge @data
    add_csrf_token_field if @data[:csrf_protection]

    # her bir input'u ilgili class'ını çağırarak başlat
    @data[:inputs].each do |input|
      input_class = Neo::Form.const_get(input[:type].capitalize)
      input_bare_name = input[:name]
      input[:name] = @data[:name] + '_' +input[:name]
      input[:form] = self
      new_input_class = input_class.new(input)
      self.class.send(:define_method,input_bare_name) { new_input_class }
    end

		fill_from_post
  end

  def add_csrf_token_field
	  @data[:inputs] << {name: 'csrf_token', type: 'hidden', value:"#{Neo::CsrfToken}"}
  end

  def take_post_data
	  form_data = Neo.req.POST.select {|k| k.start_with? "#{@data[:name]}_"}
	  form_data.each_key do |k|
		  if @data[:inputs].all? {|input| input[:name] != k}
			  form_data.delete k
		  end
	  end
	  form_data.hmap {|k,v| [k.gsub(/^#{@data[:name]}_/, ''), v] }
  end

  def fill_from_post
		if posted?
			post_data = take_post_data
			@data[:inputs].each do |input|
				bare_name = input[:name].gsub(/^#{@data[:name]}_/, '')
				input_inst = self.send bare_name
				input_inst.value = post_data[bare_name]
			end
		end
  end

  def start
    "<form name=\"#{@data[:name]}\" method=\"#{@data[:method]}\" action=\"#{@data[:action]}\" >"
  end

  def end
	  csrf_field = @data[:csrf_protection] ? self.csrf_token.to_tag : ''
    "#{csrf_field}</form>"
  end

  def csrf_token_valid?
	  if @data[:csrf_protection]
		  csrf_valid = (self.csrf_token.value == Neo::CsrfToken.to_s)
		  @errors[:form] << Neo::trn('csrf mismatch') unless csrf_valid
			csrf_valid
	  else
		  true
	  end
  end

  def inputs_valid?
	  @data[:inputs].reduce(true) do |memo, input|
		  form_data = Neo.req.POST.select {|k| k.start_with? "#{@data[:name]}_"}
		  bare_name = input[:name].gsub(/^#{@data[:name]}_/, '')
		  input_inst = self.send bare_name
		  result = input_inst.valid? form_data
		  @errors[bare_name] = input_inst.errors unless result
		  (not result) ? result : memo
	  end
  end

  # Tüm input elemanlarını tek tek gez her birinin tüm validationlarını çalıştır
  # eğer herhangi biri false döndürürse, hatasını al @errors içine kaydet, false döndür
  def valid?
    @errors = {form:[]}
    inputs_valid? and csrf_token_valid?
  end

  def posted?
    not Neo.req.POST.blank?
  end

  # Gelen post datasını modele bind eder
  #
  # @param model [Hash] post datasının bağlamak istediğin model
  # @return [Neo::Database::Model]
  def fill_model(model)
    model.fill_model take_post_data
  end

	def get_errors
		if @errors[:form] and @errors[:form].size > 0
			@errors[:form].reduce('<div class="error box">') {|memo, error| "#{memo}<div>#{error}</div>"} + '</div>'
		end
	end

end