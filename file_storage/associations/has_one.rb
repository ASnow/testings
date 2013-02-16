module FileStorage
  module Associations
    class HasOne
      def initialize owner_model, association_name, options = {}
        options = HashWithIndifferentAccess.new options
        @model = options[:class_name].present? ? options[:class_name].constantize : association_name.to_s.camelize.constantize
        @model_prefix = owner_model.name.underscore
      end
      def build owner
        @model.where(make_foreign_key(owner.primary)).first
      end

      def assign_keys record, owner
        foreign_key = make_foreign_key(owner.primary)
        foreign_key.each do |column, value|
          record.send "#{column}=", value
        end
        record
      end

      def save record, owner
        assign_keys(record, owner)
        record.save
      end

      protected

      def make_foreign_key keys
        keys.inject({}) do |store, (key, value)|
          store["#{@model_prefix}_#{key}"] = value
          store
        end
      end
    end
  end
end