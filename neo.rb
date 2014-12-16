require 'pp'
require 'rack'
require "#{File.dirname(__FILE__)}/module_extend"

module Neo
	attr_accessor :app_dir, :dir, :server_vars, :req, :mail, :conf

  def run
    Dir[@dir+'/helpers/*'].each { |f| require f }
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

  make_modular
end