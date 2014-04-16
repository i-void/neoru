require 'fileutils'
require 'pathname'

# Asset dosyası sınıfı
class Neo::Asset::File
  # dosya kendi yolunu ve kopya yolunu ayarlar
  # eğer dosyanın kopyası yoksa veya orjinalde değiştirilmişse yenisini kopyalar
  # @path: dosya yolu
  # @type: dosya tipi (css, js)
  # @virt_path: dosyanın kopyalanacağı yol
  # @modified: dosya güncellenmiş mi?
  #
  def initialize(path)
    @org_path = Neo::Asset::Manager.module_dir + path
    @type = File.extname(@org_path)[1..-1]
    @virt_path = Neo::Asset::Manager.media_dir + path
  end

  def copy
    if not File.file?(@virt_path) or is_changed?
      virt_dir = File.dirname(@virt_path)
      FileUtils.mkdir_p(virt_dir) unless Dir.exist? virt_dir

      parsers = Neo::Asset::Manager.parsers[Neo::Params.env.to_sym][@type.to_sym]
      if parsers.nil?
        FileUtils.cp(@org_path, @virt_path)
      else
        initial_path = @org_path
        parsers.each do |parser|
          content = Neo::Asset::Parsers.const_get(parser.camelize).parse(initial_path)
          if content
            if content[:extension].nil?
              File.write(@virt_path, content[:content])
            else
              FileUtils.cp(initial_path, @virt_path)
              initial_path = @virt_path.gsub(File.extname(@virt_path),content[:extension])
              File.write(initial_path, content[:content])
            end
          else
            FileUtils.cp(initial_path, @virt_path)
          end
        end
      end
    end
  end

  def is_changed?
    File.mtime(@org_path) > File.mtime(@virt_path)
  end

  def fill_content
    @content = File.read @org_path
  end
end