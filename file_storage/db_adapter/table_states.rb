module FileStorage
  class DbAdapter
    class TableStates < CsvEntity
      # define states order in file
      # SAVE THE ORDER/PROBLEM
      %w(last_id).compact.each_with_index do |state_name, index|
        const_name = state_name.upcase
        const_set const_name, index
        class_eval %Q(
          def #{state_name}
            read_first[#{const_name}]
          end
          def #{state_name}= val
            write_first #{const_name}, val
          end
        )
      end

      def initialize table_name
        @table_name = table_name
        @file_name = "#{Config["db_table_states_folder"]}/#{@table_name}"
        super()
      end

      def last_id_increment step = 1
        self.last_id = self.last_id.to_i + step
      end
    end
  end
end