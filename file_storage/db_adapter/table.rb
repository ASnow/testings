require_relative "table_states"

module FileStorage
  class DbAdapter
    class Table < CsvEntity
      def initialize table_name
        @index_types = []
        @info = SchemeBuilder.scheme.get table_name
        @states = TableStates.new table_name
        @file_name = "#{Config["db_records_folder"]}/#{table_name}"
        super()
      end

      def select conditions
        validate_columns conditions
        read.select(&generate_conditions(conditions))
      end
      def update changes, conditions
        validate_columns conditions
        validate_columns changes
        all = read
        changed = all.select(&generate_conditions(conditions))
        changed.each do |row|
          changes.each do |column, value|
            row[get_column_index(column)] = value
          end
        end
        write all
      end
      def insert records
        if records.kind_of? Hash
          validate_columns records

          all = read
          all.push insert_row(records)
          write all
          @states.last_id_increment
        elsif records.kind_of? Array
          all = read
          records.each do |record|
            validate_columns record
            all.push insert_row(record)
            @states.last_id_increment
          end
          write all
          @states.last_id
        else
          raise "Wrong insert parameter #{records}"
        end
      end
      def delete conditions
        validate_columns conditions
        write read.reject(&generate_conditions(conditions))
      end

      def query conditions = {}, sort = nil, limit = nil, offset = nil, select = nil
        rows = select conditions
        if sort
          sort_proc = generate_sort_proc sort
          rows.sort! &sort_proc
        end

        if limit && offset
          rows = rows.slice(offset, limit)
        elsif limit
          rows = rows.slice(limit)
        end

        if select
          select_proc = generate_select_proc select
          rows.map! &select_proc
        end

        rows
      end

      def read
        rows = super
        rows.each do |row|
          row.each_with_index do |value, index|
            row[index] = cast_value value, index
          end
        end
        rows
      end

      def row_to_attributes row, columns = nil
        output = {}
        if columns
          columns = columns.to_s.split(',').map do |column|
            index = get_column_index(column.strip)
            get_column_name(index) if index
          end.compact
          row.each_with_index do |value, index|
            output[columns[index]] = value
          end
        else
          row.each_with_index do |value, index|
            output[get_column_name(index)] = value
          end
        end
        output
      end

      protected

      def insert_row record
        output = []
        record[@info.primary_names.first] = @states.last_id
        record.each do |column, value|
          output[get_column_index(column)] = value
        end
        output
      end

      def validate_columns hash
        existed_columns = @info.column_names
        hash.keys.each do |column_name| 
          raise "Column '#{column_name}' is not defined in '#{@info.table_name}' table." unless existed_columns.include? column_name.to_s
        end
      end

      def generate_conditions conditions
        conditions = conditions.inject({}) do |mem, (column, value)| 
          mem[get_column_index(column)] = cast_value value, get_column_index(column)
          mem
        end
        Proc.new do |record|
          conditions.all? do |column, value|
            record[column] == value
          end
        end
      end

      def generate_sort_proc sort
        case sort
          when Symbol
            index = get_column_index sort.to_s
            Proc.new do |a, b|
              a[index] <=> b[index]
            end
          when String
            proc_chain = []
            columns = sort.split(',').map(&:strip)
            columns.each do |column|
              column, order = column.split(/\s+/)
              proc_chain.push new_proc_bind(order, get_column_index(column))
            end
            Proc.new do |a, b|
              deep = 0
              while proc_chain.size>deep && (last_cmp = proc_chain[deep].call(a,b)) == 0 do
                deep += 1
              end
              last_cmp
            end
          else 
            raise "Sort by #{sort.class.name} not implemented!"
        end
      end

      def new_proc_bind order, index
        if order && order.upcase == 'DESC'
          Proc.new do |a, b|
            b[index] <=> a[index]
          end
        else
          Proc.new do |a, b|
            a[index] <=> b[index]
          end
        end
      end

      def generate_select_proc select
        select = select.to_s if select.kind_of? Symbol
        case select
          when String
            indexes = select.split(',').map{ |column| get_column_index(column.strip) }.compact
            Proc.new do |row|
              row.values_at *indexes
            end
          else 
            raise "Select by #{select.class.name} not implemented!"
        end
      end


      def get_column_index column
        @info.column_names.find_index column.to_s
      end

      def get_column_name index
        @info.column_names[index]
      end

      def get_column_type index
        return @index_types[index] if @index_types[index]
        column = get_column_name index
        @index_types[index] = @info.column_type column
      end


      def cast_value value, index
        case get_column_type index
          when "integer"
            value.to_i
          when "float"
            value.to_f
          when "date"
            value.to_date rescue nil
          when "datetime"
            value.to_time rescue nil
          else
            value
        end
      end

    end
  end
end