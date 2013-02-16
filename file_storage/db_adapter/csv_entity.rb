require "csv"

module FileStorage
  class DbAdapter
    class CsvEntity

      def initialize
        File.write(@file_name, "") unless File.exists? @file_name
      end

      def read
        CSV.read(@file_name) || []
      end

      def write rows
        CSV.open @file_name, "wb" do |csv|
          rows.each do |row|
            csv << row
          end
        end
      end

      def read_first
        CSV.read(@file_name).first || []
      end
      def write_first index, value
        row = read_first
        row[index] = value
        write [row]
      end
    end
  end
end