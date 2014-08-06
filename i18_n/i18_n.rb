class Neo::I18N
  @lang = Neo::Config.main[:lang]

  class << self
    attr_accessor :lang
    def translate(phrase)
      lang_class = Neo::I18N.const_get(@lang)
      found = lang_class.dict.find{|i| i[0]==phrase}
      found[1]
    end
  end

end