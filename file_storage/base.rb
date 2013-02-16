require_relative "associations"
require_relative "finders"

module FileStorage
  class Base
    class << self
      def inherited subclass
        subclass.read_scheme
        subclass.generate_attributes_methods
      end

      def table_name
        @table_name ||= self.name.underscore
      end

      def read_scheme
        @table ||= SchemeBuilder.scheme.get table_name
      end

      def column_names
        @table.column_names
      end

      def generate_attributes_methods
        column_names.each do |column_name|
          class_eval <<-CODE
            def #{column_name}
              @attributes["#{column_name}"]
            end

            def #{column_name}= value
              @attributes["#{column_name}"] = value
            end

            def #{column_name}?
              @attributes["#{column_name}"].nil?
            end
          CODE
        end
      end
    end

    def initialize attrs = {}
      @attributes = {}
      @table_name = self.class.table_name
      assign_attributes attrs
      super
    end

    def assign_attributes values
      values.each do |column, value|
        method_name = "#{column}="
        send method_name, value if respond_to? method_name
      end
    end

    def save
      if exist?
        DbAdapter.update @table_name, @attributes, primary
      else
        DbAdapter.insert @table_name, @attributes
      end
      super
    end

    def destroy
      DbAdapter.delete @table_name, @attributes
    end

    def primary
      self.class.read_scheme.primary_names.inject({}) do |store, column|
        store[column] = @attributes[column]
        store
      end
    end

    def exist?
      !DbAdapter.select(@table_name, primary).empty?
    end

    include Associations
    include Finders
  end
end