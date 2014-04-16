require 'haml'
class Neo::View
  def initialize(path=nil)
    @path = to_real_path(path)
  end

  def to_real_path(path=nil)
    if path.nil?
      return "#{Neo.app_dir}/modules/#{Neo::Params.module.underscore}/views/#{Neo::Params.controller.underscore}/#{Neo::Params.action}.haml"
    else
      module_name, controller_name, action_name = path.split(':')
      module_name = Neo::Config.main[:default_module] if module_name.blank?
      controller_name = module_name if controller_name.blank?
      action_name = 'index' if action_name.blank?
      return "#{Neo.app_dir}/modules/#{module_name.underscore}/views/#{controller_name.underscore}/#{action_name.underscore}.haml"
    end
  end

  def render(params)
    @renderer = Haml::Engine.new(File.read(@path,encoding: 'UTF-8'))
    return @renderer.render(Object.new, params)
  end
end