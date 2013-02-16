module FileStorage
  class SchemeBuilder
    class Table
      COLUMN_OPTIONS = ["default", "null"]
      def initialize name
        @name = name
        @columns = {}
        @primary = []
      end

      def column name, type, options = {}
        name = name.to_s
        type = type.to_s


        raise "Column #{name} in #{@name} is already defined!" if @columns.key? name

        if type == "primary"
          type = "integer"
          @primary.push name
        elsif type == "references"
          type = "integer"
          name = "#{name}_id"
        end

        @columns[name] = {type: type}
        options.each do |key, value|
          key = key.to_s
          @columns[name][key] = value if COLUMN_OPTIONS.include? key
        end
      end

      def columns &block
        instance_eval &block
      end

      [:integer, :string, :date, :datetime, :float, :primary, :references].each do |type|
        class_eval %(
          def #{type} name, options = {}
            column name, :#{type}, options
          end
        )
      end

    end
  end
end