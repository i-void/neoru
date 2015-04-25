class Module

  alias_method :old_const_missing, :const_missing
  private :old_const_missing

  # my autoloader function
  def const_missing(e)

    full_name = "#{self}::#{e}"
    print(full_name) if Neo::Config and Neo::Config[:env] == 'dev'
    module_dir = Neo.app_dir + '/modules/'
    rubymine_mapper = ''
    if $mapper
      rubymine_mapper = File.open("#{Neo.app_dir}/rubymine_mapper.rb", 'a')
    end

    # trying to add top level
    if self.name == 'Object'
      file_path = module_dir + e.to_s.underscore
      # if it has a main class named as folder we must init that file
      main_class_file = file_path+'/'+e.to_s.underscore+'.rb'
      if File.file?(main_class_file)
        Neo.log ' --> init as main', true
        require main_class_file
        Neo.log "returning #{const_get(e.to_s).name}: #{const_get(e.to_s).class.name} \n\n\n"
        const_get(e.to_s)
      elsif File.directory? file_path
        # it is a folder so we can instantiate it as a new module
        Neo.log ' --> inited', true
        self.const_set(e, Module.new)
        Neo.log "returning #{const_get(e.to_s).name}: #{const_get(e.to_s).class.name} \n\n\n"
        if $mapper
          rubymine_mapper.write("module #{const_get(e.to_s).name}; end \n")
          rubymine_mapper.close
        end
        const_get(e.to_s)
      else
        LoadError.new("Not Found: #{full_name}").raise
      end
    else
      if self.name.start_with? 'Neo'
        # trying to add to Neo module
        file_path = Neo.dir + full_name.underscore.gsub(/^neo/,'')
      elsif self.name.start_with? 'App'
        # trying to add to App module
        file_path = Neo.app_dir + full_name.underscore.gsub(/^app/,'')
      else
        # trying to add to one of the Application's module
        file_path = module_dir + full_name.underscore
      end

      # check that it is a file (class) or folder (module)
      if File.exist?(file_path) or File.exist?(file_path + '.rb')
        if File.file?(file_path + '.rb')
          # it is a file so we can require it
          Neo.log " --> loaded #{file_path}\n"
          require file_path
          Neo.log "returning #{const_get(e.to_s).name}: #{const_get(e.to_s).class.name}: ##{file_path} \n\n\n"
          const_get(e.to_s)
        else
          # if it has a main class named as folder we must init that file
          main_class_file = file_path+'/'+e.to_s.underscore+'.rb'
          if File.file?(main_class_file)
            Neo.log ' --> main loaded', true
            require main_class_file
          else
            # it is a folder so we can instantiate it as a new module
            Neo.log ' --> inited', true
            self.const_set(e, Module.new)
            if $mapper
              rubymine_mapper.write("module #{const_get(e.to_s).name}; end \n")
              rubymine_mapper.close
            end
          end
          Neo.log "returning #{const_get(e.to_s).name}: #{const_get(e.to_s).class.name} \n\n\n"
          const_get(e.to_s)
        end
      else
        # try to find the constant from end to beggining of the path
        path_parts = self.name.split('::')
        if path_parts.length > 1
          path_parts = path_parts[0..-2] << e.to_s
          Neo.log ' --> searching', true
          path_parts.reduce(Object) {|memo,part| memo.const_get part }
        elsif path_parts.length == 1
          Object.const_get(e.to_s)
        else
          old_const_missing(e)
        end
      end
    end
  end
end