require 'slim'
require 'fileutils'
require 'tilt'
class Neo::View

  Cache = Tilt::Cache.new

  def initialize(path=nil)
    @default_extension = ".#{Neo::Config[:default_template_engine]}"
    @path = to_real_path(path)
  end

  def to_real_path(path=nil)
    if path.nil?
      "#{Neo.app_dir}/modules/#{Neo::Params.module.underscore}/views/#{Neo::Params.controller.underscore}/#{Neo::Params.action}#{@default_extension}"
    else
      module_name, controller_name, action_name = path.split(':')
      module_name = Neo::Config[:default_module] if module_name.blank?
      controller_name = module_name if controller_name.blank?
      action_name = 'index' if action_name.blank?
      "#{Neo.app_dir}/modules/#{module_name.underscore}/views/#{controller_name.underscore}/#{action_name.underscore}#{@default_extension}"
    end
  end

  def get_renderer(&block)
    if Neo::Config[:env] == 'prod'
      Cache.fetch(@path, &block)
    else
      mtime = File.mtime(@path)
      Cache.fetch(@path,mtime, &block)
    end
  end

  def render(params)
	  options = {default_encoding: 'UTF-8'}
	  if Neo::Config[:env] == 'dev' and File.extname(@path) == '.slim'
		  options[:pretty] = true
	  end
    renderer = get_renderer { Tilt.new(@path,options) }
    renderer.render Object.new, params
  end

end