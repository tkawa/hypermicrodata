module Microdata
  module Serializer
    class Base
      def initialize(html, location=nil)
        html = StringIO.new(html) if html.is_a?(String)
        @location = location
        @document = Microdata::Document.new(html, location)
      end

      def to_json
        # 暫定的
        if @document.items.present?
          JSON.pretty_generate(@document.items.map(&:to_hash))
        else
          '[]'
        end
      end
    end
  end
end
