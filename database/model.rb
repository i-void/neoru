module Neo
  module Database
    class Model
      attr_accessor :id
      attr_reader :_excluded_instance_variables

      Node = Neo::Database::Node

      def exclude(*vars)
        @_excluded_instance_variables = vars
      end
      def labels=(labels)
        @labels = labels
      end
      def labels
        @labels
      end
      def save
        node = Node.new.fill_from_model(self)
        @id = node.upsert
      end
      def relate_to(node,relation_name,props={})
        self_node = Node.new.fill_from_model(self)
        node = Node.new.fill_from_model(node)
        self_node.relate_to(node,relation_name,props)
      end

      def fill_model(data)
        if data.filled?
          data.each do |k,v|
            if self.respond_to? k+'='
              self.send(k+'=',v)
            end
          end
        end
        self
      end

      #@param data Hash :hash data which will fill the model ex;{id:3}
      def self.fill_model(data)
        self.new.fill_model(data)
      end
    end
  end
end