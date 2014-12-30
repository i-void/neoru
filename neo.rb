require 'pp'
require 'rack'
NEO_PATH = File.dirname(__FILE__)
require "#{NEO_PATH}/module_extend"

module Neo
	attr_accessor :app_dir, :dir, :server_vars, :req, :mail

  def run
    Dir[@dir+'/helpers/*'].each { |f| require f }
    require "#{NEO_PATH}/params"
    require "#{NEO_PATH}/config"
    @server_vars ||= {}
    @req = Rack::Request.new(@server_vars)

    Neo::Router.build_module_data
    Neo::Event.register(:before_action) {
      Neo::Asset::Manager.init
    }
    @mail = Neo::Mail.new
  end

  def http_response
    Neo::Router.response
  end

  def asset(file)
    root_dir = Neo::Asset::Manager.media_dir.gsub @app_dir+'/web', ''
    root_dir + file
  end

  def trn(phrase, lang=Neo::Config[:lang])
    Neo::I18N.translate(phrase,lang)
  end

  def widget(name, params={})
    module_name, widget_name = name.split(':')
    "#{module_name.camelize}::Widgets::#{widget_name.camelize}".to_obj.new.render(params)
  end

  def generate_url(name, parameters=[])
    url = Neo::Config[:routes][name][0]
    parameters.reduce(url) do |retval, i|
      "#{retval}/#{i}"
    end
  end

  def log(message, newline=false)
    if Neo::Config and Neo::Config[:env] == 'dev'
      (newline) ? puts(message) : print(message)
    end
  end

  # Detect the gem path
  # @param gem_name [String] name of gem which will be detected
  # @return [String, Nil] path of gem if exists, Nil otherwise
  def detect_gem_path(gem_name)
    require 'open3'
    out, status = Open3.capture2e 'rvm @global do gem environment gemdir'
    if status.success?
      dirs = Dir["#{out.split("\n").last.strip}/gems/#{gem_name}-[0-9]*.*.*"]
      unless dirs.blank?
        dirs[0]
      end
    end
  end

  make_modular
end