class Neo::I18N
  class << self
    def translate(phrase, lang)
      lang_class = Neo::I18N.const_get(lang)
      found = lang_class.dict.find{|i| i[0]==phrase}
      found[1]
    end

    def change_lang(lang)
      Neo::Config.main[:lang] = lang
    end
  end
end