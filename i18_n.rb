module Neo
  module I18N
    attr_accessor :phrases

    def init
      @phrases = {}
      language_files.each {|file| require file }
    end

    # gets the language files of modules and Neo
    def language_files
      paths = []
      # find in application
      paths << "#{Neo.app_dir}/modules/*/i18_n/*.rb"
      # find in Neo
      paths << "#{Neo.dir}/i18_n/*.rb"
      paths.reduce([]) {|files, path|  files + Dir[path]}
    end

    def translate(phrase, lang)
      Neo::Exceptions::SystemError.new("Can't find the phrases for language:#{lang}").raise if @phrases[lang].nil?
      found = @phrases[lang].find{|i| i[0]==phrase}
      if found.nil?
        puts "Can't find a translation for #{phrase}. Returning original one"
        phrase
      else
        found[1]
      end
    end

    def change_lang(lang)
      Neo::Config.main[:lang] = lang
    end

    def add(lang, phrase_array)
      @phrases[lang] ||= []
      @phrases[lang] += phrase_array
    end

    make_modular
  end
end