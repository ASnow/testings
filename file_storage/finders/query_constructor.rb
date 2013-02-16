module FileStorage
  module Finders
    class QueryConstructor
      def initialize model
        @model = model
        @conditions = HashWithIndifferentAccess.new
      end

      def where conditions
        @conditions.merge! conditions
        self
      end
      def limit val
        @limit = val
        self
      end
      def order val
        @sort = val
        self
      end
      def offset val
        @offset = val
        self
      end
      def select val
        @select = val
        self
      end

      def first
        @model.find @conditions, @sort, 1, 0, @select
      end
      def last
        @model.find @conditions, @sort, 1, -1, @select
      end
      def all
        @model.find @conditions, @sort, @limit, @offset, @select
      end
    end
  end
end