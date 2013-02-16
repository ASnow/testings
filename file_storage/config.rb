module FileStorage
  class Config
    @config = {}
    class << self
      def [] key, default= nil
        @config.key?(key) ? @config[key] : default
      end
      def []= key, value
        @config[key] = value
      end
    end
  end
end
