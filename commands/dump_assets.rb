# encoding: utf-8

require 'uglifier'
require 'pp'
require 'digest/md5'
require 'sass'

class Neo::Commands::DumpAssets < Neo::Command

  def get_compressed_css(files)
    content = files.reduce('') {|memo, css_file|
      content = File.read(css_file)
      content = css_relative_to_absolute(content, css_file)
      "#{memo}\n#{content}"
    }
    engine = Sass::Engine.new(content, :syntax => :scss, :style => :compressed)
    engine.render
  end

  def css_relative_to_absolute(content, path)
    root_path = Pathname Neo::Asset::Manager.media_dir
    path = Pathname(File.dirname(path)).relative_path_from(root_path)
    urls = content.scan(/url\(["']*(?<url>.+?)["']*\)/i).map{|i| i[0]}
    urls.reduce(content) do |memo, url|
      memo.gsub url, "#{path.join(url)}"
    end
  end

  def process_asset(asset)
    Neo::Params.module, Neo::Params.controller, Neo::Params.action = asset[:action].split ':'
    Neo::Asset::Manager.init

    links = Neo::Asset::Manager.get_dev_links.map{|i| Neo::Asset::Manager.media_dir + i}

    output_file_name = Digest::MD5
      .hexdigest(asset[:action] + Neo::Asset::Manager.last_version)[-10..-1]
      .to_i(16).to_s(36)

    output_file_name = Neo::Asset::Manager.media_dir + '/' + output_file_name

    links = links.group_by{|link| File.extname(link).gsub('.','').to_sym}
    links[:css] = [] if links[:css].nil?
    links[:js] = [] if links[:js].nil?

    # result = `juicer merge -o "#{output_file_name}.min.css" -d "#{Neo::Asset::Manager.media_dir}" -r "#{links[:css].join('" "')}" -f`
    # puts result

    File.open("#{output_file_name}.min.css", 'w') do |file|
      file.write get_compressed_css(links[:css])
      puts "Produced #{output_file_name}.min.css from"
      puts links[:css]
      puts ''
    end


    result = `juicer merge -s -o "#{output_file_name}.min.js" -d "#{Neo::Asset::Manager.media_dir}" -r "#{links[:js].join('" "')}" -f`
    puts result
  end

  def run
    Neo::Params.env = 'dev'

    media_dir_name = 'media'
    media_dir = Neo.app_dir + '/web/' + media_dir_name
    files = Dir[media_dir + '/*/*/*.min.js', media_dir + '/*/*/*.min.css']
    files.each {|file| File.delete file}

    Neo::Config[:assets].each do |asset|
      process_asset(asset)
    end

  end
end