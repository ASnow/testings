module FileStorage
  class SchemeBuilder
    class TableAdapter
      def initialize table_scheme
        raise "Adaptee should be instance of FileStorage::SchemeBuilder::Table" unless table_scheme.kind_of? Table
        @name = table_scheme.instance_variable_get "@name"
        @columns = table_scheme.instance_variable_get "@columns"
        @primary = table_scheme.instance_variable_get "@primary"
        fix_primary
      end

      def table_name
        @name
      end

      def column_type column
        @columns[column]["type"]
      end

      def column_names
        @columns.keys
      end

      def primary_names
        @primary
      end
      protected
      def fix_primary
        if @primary.empty?
          @primary = ["id"]
          @columns = Hash[@columns.to_a.unshift(["id", {"type" => "integer"}])]
        end
      end
    end
  end
end