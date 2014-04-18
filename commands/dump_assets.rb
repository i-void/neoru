# encoding: utf-8

require 'uglifier'
require 'pp'
require 'digest/md5'

class Neo::Commands::DumpAssets < Neo::Command


  def process_asset(asset)
    Neo::Params.module, Neo::Params.controller, Neo::Params.action = asset[:action].split ':'
    Neo::Asset::Manager.init

    links = Neo::Asset::Manager.get_dev_links.map{|i| Neo::Asset::Manager.media_dir + i}

    output_file_name = Digest::MD5
      .hexdigest(asset[:action] + Neo::Asset::Manager.last_version)[-10..-1]
      .to_i(16).to_s(36)

    output_file_name = Neo::Asset::Manager.media_dir + '/' + output_file_name

    links = links.group_by{|link| File.extname(link).gsub('.','').to_sym}

    result = `juicer merge -o "#{output_file_name}.min.css" -d "#{Neo::Asset::Manager.media_dir}" -r "#{links[:css].join('" "')}" -f`
    puts result

    result = `juicer merge -s -o "#{output_file_name}.min.js" -d "#{Neo::Asset::Manager.media_dir}" -r "#{links[:js].join('" "')}" -f`
    puts result
  end

  def run
    Neo::Params.env = 'dev'

    conf = Neo::Config.main
    conf[:assets].each do |asset|
      process_asset(asset)
    end

  end
end