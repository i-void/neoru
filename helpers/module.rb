class Module

  alias_method :old_const_missing, :const_missing
  private :old_const_missing

  # my autoloader function
  def const_missing(e)

    full_name = self.name+'::'+e.to_s
    puts full_name
    module_dir = Neo.app_dir + '/modules/'

    # trying to add top level
    if self.name == 'Object'
      file_path = module_dir + full_name.underscore
      # if it has a main class named as folder we must init that file
      main_class_file = file_path+'/'+e.to_s.underscore+'.rb'
      if File.file?(main_class_file)
        require main_class_file
      else
        # it is a folder so we can instantiate it as a new module
        self.const_set(e, Module.new)
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

          require file_path
        else
          # if it has a main class named as folder we must init that file
          main_class_file = file_path+'/'+e.to_s.underscore+'.rb'
          if File.file?(main_class_file)
            require main_class_file
          else
            # it is a folder so we can instantiate it as a new module
            self.const_set(e, Module.new)
          end
        end
      else
        # try to find the constant from end to beggining of the path
        path_parts = self.name.split('::')
        if path_parts.length > 1
          path_parts = path_parts[0..-2] << e.to_s
          return path_parts.reduce(Object) {|memo,part| memo.const_get part }
        elsif path_parts.length == 1
          return Object.const_get(e.to_s)
        else
          return old_const_missing(e)
        end
      end

    end
    const_get(e.to_s)
  end
end