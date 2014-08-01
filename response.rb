require 'json'

module Neo
  class Response
    class << self
      def error404
        conf = Neo::Config.main[:errors][:e404]
        view = Neo::View.new(conf[0])
        view.render(conf[1])
      end

      def error500
        conf = Neo::Config.main[:errors][:e500]
        view = Neo::View.new(conf[0])
        view.render(conf[1])
      end

      # reads the file
      # get its mimetype
      # and returns content as mimetype
      def static(file)
        mime = MIME::Types.type_for(file).first.to_s
        if mime == 'application/x-ruby'
          error404
        else
          file = File.open(file, 'rb')
          contents = file.read
          file.close
          ['200', {'Content-Type' => mime}, [contents]]
        end
      end

      #returns simple html format
      def html(content)
        [200, {'Content-Type' => 'text/html'}, [content]]
      end

      def redirect(url)
        [302, {'Content-Type' => 'text', 'Location' => url}, ['302 found']]
      end

      #returns content json encoded
      def json(content)
        [200, {'Content-Type' => 'application/json'}, [content.to_json]]
      end
    end
  end
end