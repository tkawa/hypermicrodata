module Hypermicrodata
  module Serializer
    class Base
      def initialize(document, location = nil, profile_path = nil)
        @document = document
        @location = location
        @profile_path = profile_path
      end

      def to_json(options = {})
        MultiJson.dump(serialize, options)
      end

      def serialize
        # return hash or array suitable for application/json
        if @document.items
          @document.items.map(&:to_hash)
        else
          []
        end
      end
    end
  end
end
