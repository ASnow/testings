require_relative "scheme_builder/table"
require_relative "scheme_builder/table_adapter"

module FileStorage
  class SchemeBuilder
    # Allow to define scheme like this:
    #   FileStorage::SchemeBuilder.define do
    #     table :name do
    #       columns do
    #         type :name, 
    #       end
    #       column :name, :type
    #     end
    #   end
    def self.scheme
      return @scheme if @scheme

      if Config["scheme_file"] && File.exists?(Config["scheme_file"])
        require Config["scheme_file"]
        @scheme
      else
        raise "Scheme file not founded in '#{Config["scheme_file"]}'. Configure your file in FileStorage::Config['scheme_file']=path"
      end
    end

    def self.define &block
      @scheme = new
      @scheme.instance_eval &block
      @scheme
    end

    def initialize
      @tables = {}
    end

    def table name, &block
      name = name.to_s
      @tables[name] = @tables.key?(name) ? @tables[name] : Table.new(name)
      @tables[name].instance_eval &block
    end

    def get name
      name = name.to_s
      if @tables.key? name
        TableAdapter.new @tables[name]
      else
        raise "Table '#{name}' was not defined in scheme"
      end
    end
  end
end