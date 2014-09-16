module Neo
  class Widget
    def render(params = {})
      module_name, t, widget_name = self.class.name.split('::')
      @path = "#{Neo.app_dir}/modules/#{module_name.underscore}/views/widgets/#{widget_name.underscore}.haml"
      @renderer = Haml::Engine.new(File.read(@path,encoding: 'UTF-8'))
      @renderer.render(Object.new, params)
    end
  end
end