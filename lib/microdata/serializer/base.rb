module Microdata
  module Serializer
    class Base
      def initialize(html, location=nil, data_attr_name='main-item')
        @location = location
        filter_xpath = "//*[@data-#{data_attr_name}]"
        @document = Microdata::Document.new(html, location, filter_xpath)
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
