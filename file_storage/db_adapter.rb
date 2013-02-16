require_relative "db_adapter/csv_entity"
require_relative "db_adapter/table"

module FileStorage
  class DbAdapter
    class << self
      def select table_name, conditions
        table = get_table(table_name)
        rows = table.select conditions
        make_records table_name, table, rows 
      end

      def update table, changes, conditions
        get_table(table).update changes, conditions
      end
      def insert table, records
        get_table(table).insert records
      end
      def delete table, conditions
        get_table(table).delete conditions
      end
      def query table_name, conditions = {}, sort = nil, limit = nil, offset = nil, select = nil
        table = get_table(table_name)
        rows = table.query conditions, sort, limit, offset, select
        make_records table_name, table, rows, select
      end

      protected
      def get_table table
        Table.new table
      end

      def make_records table_name, table, rows, select = nil
        model = table_name.camelize.constantize
        rows.map do |row|
          model.new table.row_to_attributes(row, select)
        end
      end
    end
  end
end