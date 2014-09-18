module Neo
  module I18N
    attr_accessor :phrases
    extend self

    # gets the language files of modules and Neo
    def language_files
      paths = []
      # find in application
      paths << "#{Neo.app_dir}/modules/*/i18_n/*.rb"
      # find in Neo
      paths << "#{Neo.dir}/i18_n/*.rb"
      paths.reduce([]) do |files, path|
        files += Dir[path]
      end
    end

    def init
      @phrases = {}
      language_files.each {|file| require file }
    end

    def translate(phrase, lang)
      found = @phrases[lang].find{|i| i[0]==phrase}
      found[1]
    end

    def change_lang(lang)
      Neo::Config.main[:lang] = lang
    end

    def add(lang, phrase_array)
      if @phrases[lang].nil?
        @phrases[lang] = phrase_array
      else
        @phrases[lang] += phrase_array
      end
    end

  end
end