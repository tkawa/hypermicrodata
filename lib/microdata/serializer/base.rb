module Microdata
  module Serializer
    class Base
      def initialize(html, options = {})
        default_data_attr_name = 'main-item'
        @location = options[:location]
        @profile_path = options[:profile_path]
        filter_xpath = "//*[@data-#{options[:data_attr_name] || default_data_attr_name}]"
        @document = Microdata::Document.new(html, @location, filter_xpath)
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
