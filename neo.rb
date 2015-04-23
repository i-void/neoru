require 'pp'
require 'rack'
NEO_PATH = File.dirname(__FILE__)
require "#{NEO_PATH}/module_extend"

module Neo
	attr_accessor :app_dir, :dir, :server_vars, :req, :mail

  def run
    Dir[@dir+'/helpers/*'].each { |f| require f }
    @server_vars ||= {}
    @req = Rack::Request.new(@server_vars)
    require "#{NEO_PATH}/params"
    require "#{NEO_PATH}/config"

    Neo::Event.register(:before_action, :init_asset_manager) {
      Neo::Asset::Manager.init
    }
    @mail = Neo::Mail.new
  end

  def http_response
	  routes = Neo::Router::ConfigurationParser.new.generate_routes
    routes += Neo::Router::AutoRouteGenerator.new.generate_routes
    router = Neo::Router.new request: @req, routes: routes
	  router.get_http_response
  end

  def asset(file)
    root_dir = Neo::Asset::Manager.media_dir.gsub @app_dir+'/web', ''
    root_dir + file
  end

  def trn(phrase, lang:Neo::Config[:lang], replace:{})
    translated_phrase = Neo::I18N.translate(phrase,lang)
		replace.reduce(translated_phrase) {|memo, (key, value)|	memo.gsub key, value }
  end

  def widget(name, params={})
    module_name, widget_name = name.split(':')
    "#{module_name.camelize}::Widgets::#{widget_name.camelize}".to_obj.new.render(params)
  end

  def generate_url(name, parameters=[])
		options = Neo::Config[:routes][name]
	  config = Neo::Router::Configuration.new(name: name, options: options)
		config.get_url(parameters)
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
	  Gem::Specification.find_by_name(gem_name).gem_dir
  rescue
	  nil
  end

  make_modular
end