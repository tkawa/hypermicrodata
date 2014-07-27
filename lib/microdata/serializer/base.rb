module Microdata
  module Serializer
    class Base
      def initialize(html, location=nil, main_item_id='main-item')
        @location = location
        @document = Microdata::Document.new(html, location, main_item_id)
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
