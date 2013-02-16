require_relative "associations/has_one"
require_relative "associations/belongs_to"

module FileStorage
  module Associations
    module ClassMethods
      attr_accessor :associations
      def has_one assocaited, options = {}
        class_eval %Q(
          def #{assocaited}
            @associated["#{assocaited}"] ||= self.class.associations["#{assocaited}"].build(self)
          end
          def #{assocaited}= val
            @associated["#{assocaited}"] = self.class.associations["#{assocaited}"].assign_keys(val, self)
          end
        )
        @associations ||= {}
        @associations[assocaited.to_s] = HasOne.new self, assocaited, options
      end
      def belongs_to assocaited, options = {}
        class_eval %Q(
          def #{assocaited}
            @associated["#{assocaited}"] ||= self.class.associations["#{assocaited}"].build(self)
          end
          def #{assocaited}= val
            @associated["#{assocaited}"] = self.class.associations["#{assocaited}"].assign_keys(val, self)
          end
        )
        @associations ||= {}
        @associations[assocaited.to_s] = BelongsTo.new self, assocaited, options
      end
    end
    module InstanceMethods
      def initialize attrs = {}
        @associated = {}
      end

      def save *args
        @associated.each do |column, value|
          self.class.associations[column].save(value, self)
        end
        @associated = {}
        DbAdapter.update @table_name, @attributes, primary
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end