require_relative "finders/query_constructor"

module FileStorage
  module Finders
    module ClassMethods
      ["where", "limit", "offset", "select", "order", "first", "last", "all"].each do |method| # delegated methods
        class_eval %Q(
          def #{method} *args, &block
            QueryConstructor.new(self).#{method}(*args, &block)
          end
        )
      end
      def find conditions = {}, sort = nil, limit = 1, offset = 0, select = nil
        DbAdapter.query @table_name, conditions, sort, limit, offset, select
      end

      protected

      def method_missing method, *args, &block
        case method.to_s
        when /\Afind_by_/ then magick_finder(method, args, &block)
        else super
        end
      end

      def magick_finder method, args, &block
        columns = /^find_by_(.+?)(?:_and_(.+?))*$/.match(method).to_a[1..-1].compact
        raise "Wrong params count for #{method}. #{args.size} for #{columns.size}" unless columns.size == args.size
        conditions = {}
        columns.each_with_index do |column, index|
          conditions[column] = args[index]
        end
        find conditions
      end
    end
    
    module InstanceMethods
      
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
