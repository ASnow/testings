module FileStorage
  module Associations
    class BelongsTo
      def initialize owner_model, association_name, options = {}
        options = HashWithIndifferentAccess.new options
        @model = options[:class_name].present? ? options[:class_name].constantize : association_name.to_s.camelize.constantize
        @model_prefix = @model.name.underscore
      end
      def build owner
        @model.where(make_primary_key(owner)).first
      end

      def assign_keys primary, owner
        foreign_key = make_foreign_key(primary)
        foreign_key.each do |column, value|
          owner.send "#{column}=", value
        end
        primary
      end

      def save record, owner
        record.save unless record.exist?
        assign_keys(record, owner)
      end


      protected

      def make_primary_key record
        @model.read_scheme.primary_names.inject({}) do |store, key|
          store[key] = record.send "#{@model_prefix}_#{key}"
          store
        end
      end

      def make_foreign_key primary
        @model.read_scheme.primary_names.inject({}) do |store, key|
          store["#{@model_prefix}_#{key}"] = primary.send(key)
          store
        end
      end

    end
  end
end