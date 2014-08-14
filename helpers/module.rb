class Module

  alias_method :old_const_missing, :const_missing
  private :old_const_missing

  # my autoloader function
  def const_missing(e)

    full_name = self.name+'::'+e.to_s
    print(full_name) if Neo.conf and Neo.conf[:env] == 'dev'
    module_dir = Neo.app_dir + '/modules/'

    # trying to add top level
    if self.name == 'Object'
      file_path = module_dir + full_name.underscore
      # if it has a main class named as folder we must init that file
      main_class_file = file_path+'/'+e.to_s.underscore+'.rb'
      if File.file?(main_class_file)
        puts(' --> init as main') if Neo.conf and Neo.conf[:env] == 'dev'
        require main_class_file
        puts("returning #{const_get(e.to_s).name}: #{const_get(e.to_s).class.name} \n\n") if Neo.conf and Neo.conf[:env] == 'dev'
        const_get(e.to_s)
      else
        # it is a folder so we can instantiate it as a new module
        puts(' --> inited') if Neo.conf and Neo.conf[:env] == 'dev'
        self.const_set(e, Module.new)
        puts("returning #{const_get(e.to_s).name}: #{const_get(e.to_s).class.name} \n\n") if Neo.conf and Neo.conf[:env] == 'dev'
        const_get(e.to_s)
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
          puts(" --> loaded #{file_path}") if Neo.conf and Neo.conf[:env] == 'dev'
          require file_path
          puts("returning #{const_get(e.to_s).name}: #{const_get(e.to_s).class.name}: ##{file_path} \n\n") if Neo.conf and Neo.conf[:env] == 'dev'
          const_get(e.to_s)
        else
          # if it has a main class named as folder we must init that file
          main_class_file = file_path+'/'+e.to_s.underscore+'.rb'
          if File.file?(main_class_file)
            puts(' --> main loaded') if Neo.conf and Neo.conf[:env] == 'dev'
            require main_class_file
          else
            # it is a folder so we can instantiate it as a new module
            puts(' --> inited') if Neo.conf and Neo.conf[:env] == 'dev'
            self.const_set(e, Module.new)
          end
          puts("returning #{const_get(e.to_s).name}: #{const_get(e.to_s).class.name} \n\n") if Neo.conf and Neo.conf[:env] == 'dev'
          const_get(e.to_s)
        end
      else
        # try to find the constant from end to beggining of the path
        path_parts = self.name.split('::')
        if path_parts.length > 1
          path_parts = path_parts[0..-2] << e.to_s
          puts(' --> searching') if Neo.conf and Neo.conf[:env] == 'dev'
          path_parts.reduce(Object) {|memo,part| memo.const_get part }
        elsif path_parts.length == 1
          puts(' --> searching') if Neo.conf and Neo.conf[:env] == 'dev'
          Object.const_get(e.to_s)
        else
          puts(' --> searching') if Neo.conf and Neo.conf[:env] == 'dev'
          old_const_missing(e)
        end
      end
    end
  end

  def make_static
    self.instance_variables.each do |i|
      i = i.to_s[1..-1]
      self.define_singleton_method(i.to_sym) do
        self.instance_variable_get "@#{i}".to_sym
      end
      self.define_singleton_method("#{i}=".to_sym) do |j|
        self.instance_variable_set "@#{i}".to_sym, j
      end
    end
  end
end