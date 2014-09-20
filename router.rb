require 'mime/types'

class Neo::Router
  class << self
    attr_accessor :modules, :default_module, :default_controller, :params

    #builds module hash for matching auto route purposes
    def build_module_data
      module_dir = Neo.app_dir+'/modules'
      @modules = {}
      @params = []
      Dir[module_dir+'/*'].each do |f|
        if File.directory? f
          module_name =File.basename(f)
          @modules[module_name] = []
          Dir[f+'/controllers/*'].each do |c|
            controller_name = File.basename(c).split('_')[0]
            @modules[module_name] << controller_name
          end
        end
      end
    end

    def require_controller(module_name,controller_name)
      require Neo.app_dir+'/modules/'+module_name+'/controllers/'+controller_name
    end

    def action_call(module_name, controller_name=nil, action_name='index')
      pp "Executed Action: [Module=>#{module_name}, Controller=>#{controller_name}, Action=>#{action_name}]" if Neo::Params.env == 'dev'
      controller_name = module_name if controller_name.nil?
      Neo::Params.module = module_name
      Neo::Params.controller = controller_name
      Neo::Params.action = action_name
      action_name += '_action'
      require_controller module_name, controller_name
      Neo::Event.trigger :before_action
      begin
        response = Kernel
          .const_get(module_name.camelize).const_get('Controllers').const_get(controller_name.camelize)
          .new.send(action_name, *@params)
      rescue Exception=>e
        error_msg = Neo.trn('Path not found or parameter count not match on {{url}}').gsub '{{url}}', Neo.server_vars['REQUEST_PATH']
        response = Neo::Exception.new(404, error_msg).raise
      end
      Neo::Event.trigger :after_action
      response
    end

    def is_module?(part)
      part.gsub!('-','_')
      not @modules[part].blank?
    end

    def is_controller?(module_name, part)
      module_name.gsub!('-','_')
      is_module?(module_name) and @modules[module_name].include?(part+'.rb')
    end

    def is_action?(module_name, controller_name, part)
      module_name.gsub!('-','_')
      part.gsub!('-','_')
      if is_controller?(module_name, controller_name) or part.blank?
        part += '_action'
        require_controller module_name, controller_name
        module_name.camelize+'::Controllers::'+controller_name.camelize+'.new'
        eval(module_name.camelize+'::Controllers::'+controller_name.camelize+'.new').respond_to?(part)
      else
        false
      end
    end

    def init_params(uri_parts, param_start)
      @params = uri_parts[param_start..-1]
    end

    def other_route_conditions(uri_parts)
      if is_module? uri_parts[0]
        if is_controller? uri_parts[0], uri_parts[1]
          if is_action? uri_parts[0], uri_parts[1], uri_parts[2]
            init_params uri_parts, 3
            action_call uri_parts[0], uri_parts[1], uri_parts[2]
          elsif is_action? uri_parts[0], uri_parts[1], 'index'
            init_params uri_parts, 2
            action_call uri_parts[0], uri_parts[1]
          end
        elsif is_action? uri_parts[0], uri_parts[0], uri_parts[1]
          init_params uri_parts, 2
          action_call uri_parts[0], uri_parts[0], uri_parts[1]
        else
          init_params uri_parts, 1
          action_call(uri_parts[0])
        end
      elsif is_controller? @default_module, uri_parts[0]
        if is_action? @default_module, uri_parts[0], uri_parts[1]
          init_params uri_parts, 2
          action_call @default_module, uri_parts[0], uri_parts[1]
        else
          init_params uri_parts, 1
          action_call(@default_module, uri_parts[0])
        end
      elsif is_action? @default_module, @default_controller, uri_parts[0]
        init_params uri_parts, 1
        action_call(@default_module, @default_controller, uri_parts[0])
      else
        init_params uri_parts, 0
        action_call(@default_module, @default_controller, 'index')
      end
    end

    def check_from_config
      Neo::Config.main[:routes].reduce(nil) do |ret, (name, data)|
        data[3]='get' if data[3].blank?
        route_reg, param_reg, action, method = data
        param_reg = '/'+param_reg if param_reg[0]!='/'
        url_reg = route_reg + param_reg
        uri = Neo.server_vars['REQUEST_PATH']
        uri += '/' if uri[-1] != '/'
        request_method = Neo.server_vars['REQUEST_METHOD'].downcase
        if /^#{url_reg}/.match(uri) && method.split(',').include?(request_method)
          param_string = uri.gsub /^#{route_reg}/, ''
          @params = param_string.split('/')[1..-1]
          break action
        end
      end
    end

    def action_call_config(action)
      module_name, controller_name, action_name = action.split(':')
      action_call(module_name, controller_name, action_name)
    end

    #match route with modules hash
    def find_action
      #if static file
      file = Neo.app_dir+'/web'+Neo.server_vars['REQUEST_PATH']
      if File.file?(file) and not %w( .ru .rb .scss .sass .coffee ).include? File.extname(file)
        Neo::Response.static(file)
      else
        uri_parts = Neo.server_vars['REQUEST_PATH'].split('/')[1..-1]

        @default_module = Neo::Config.main[:default_module] unless Neo::Config.main[:default_module].blank?
        @default_controller = @default_module

        #if the route matches with one of the config param then call action from config
        action = check_from_config
        if action.nil?
          #if the uri is '/' then go and run default module's same named controller's index action
          if uri_parts.blank?
            action_call @default_module
          else
            response = other_route_conditions(uri_parts)
            if response.blank?
              Neo::Response.html('')
            else
              response.blank?
            end
            response unless response.blank?
          end
        else
          action_call_config(action)
        end
      end
    end

    def response
      find_action
    end
  end
end
