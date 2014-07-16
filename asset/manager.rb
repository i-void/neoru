require 'fileutils'

class Neo::Asset::Manager
  class << self
    attr_accessor :media_dir, :module_dir, :last_version, :parsers, :css, :js, :changed_files

    # set the paths
    def init
      @media_dir_name = 'media'
      @parsers = {
        dev:{
          coffee: ['coffee'],
          scss: ['scss'],
          sass: ['sass']
        },
        prod:{
        }
      }

      @changed_files = []
      @media_dir = Neo.app_dir + '/web/' + @media_dir_name
      @module_dir = Neo.app_dir + '/modules/' + Neo::Params.module + '/assets'
      @version_file = @media_dir + '/.version'
      @last_version = File.read(@version_file)
      copy_assets if @last_version.blank? or Neo::Params.env == 'dev'
      links = to_html(self.send("get_#{Neo::Params.env}_links"))
      @css = links[:css]
      @js = links[:js]
    end

    # seperate the css and js files and give their html code
    def to_html(links)
      code = {js:'',css:''}
      root_dir = @media_dir.gsub Neo.app_dir+'/web', ''
      links.uniq!
      links.each do |link|
        if File.extname(link) == '.css'
          code[:css] += "<link rel=\"stylesheet\" href=\"#{root_dir+link}\" type=\"text/css\" charset=\"utf-8\" />\n"
        else
          code[:js] += "<script type=\"text/javascript\" charset=\"utf-8\" src=\"#{root_dir+link}\"></script>\n"
        end
      end
      code
    end

    # if the selector contains # at start, then find it from asset_sets else return bare file path
    def get_asset_file(asset_selector)
      files = []
      asset_sets = Neo::Config.main[:asset_sets]
      if asset_selector.start_with? '#'
        set_files = asset_sets[asset_selector.gsub('#','').to_sym]
        set_files.each do |set_file|
          files += get_asset_file(set_file)
        end
        files
      else
        [asset_selector]
      end
    end

    def get_prod_links
      links = []
      full_action_path = Neo::Params.module + ':' + Neo::Params.controller + ':' + Neo::Params.action

      output_file_name = '/' + Digest::MD5
      .hexdigest(full_action_path + @last_version)[-10..-1]
      .to_i(16).to_s(36)

      @media_dir += '/' + Neo::Params.module + '/' + @last_version
      links << output_file_name + '.min.css'
      links << output_file_name + '.min.js'
      links
    end

    # get links for css and js files which set on config file
    def get_dev_links
      links = []
      conf = Neo::Config.main
      full_action_path = Neo::Params.module + ':' + Neo::Params.controller + ':' + Neo::Params.action
      unless conf[:assets].nil?
        asset_arr = conf[:assets].find{|asset| asset[:action]==full_action_path }
        unless asset_arr.nil?
          asset_arr[:files].each do |asset_file|
            links += get_asset_file(asset_file)
          end
        end
      end
      links
    end

    # copy assets to media folder
    def copy_assets
      file_paths = Dir[@module_dir + '/**/*']

      unless file_paths.blank?
        # find the last modified time from files
        mtime = File.mtime(file_paths.max_by { |path| File.file?(path) ? File.mtime(path).to_i : 0 }).to_i.to_s(32)

        @media_dir += '/' + Neo::Params.module + '/' + @last_version

        if mtime != @last_version
          if @last_version.blank?
            @media_dir += @last_version
          end

          file_paths.each do |file_path|
            if File.file? file_path
              file_path.gsub! @module_dir, ''
              file = Neo::Asset::File.new(file_path)
              file.copy
            end
          end


          new_dir = @media_dir.gsub(@last_version, mtime)
          dirs = Dir["#{Neo.app_dir}/web/#{@media_dir_name}/*/*"]
          dirs.each do |dir|
            modified_dir = "#{dir.split('/')[0..-2].join('/')}/#{mtime}"
            FileUtils.move(dir, modified_dir) if dir != modified_dir
          end
          @media_dir = new_dir
        end

        File.write(@version_file, mtime)
      end
    end

  end
end