module Microdata
  class Extract
    def initialize(html, options = {})
      default_data_attr_name = 'main-item'
      @location = options[:location]
      @profile_path = options[:profile_path]
      filter_xpath_attr = "@data-#{options[:data_attr_name] || default_data_attr_name}"
      @document = Microdata::Document.new(html, @location, filter_xpath_attr)
    end

    def to_json(format = :plain, options = {})
      case format
      when :hal
        Microdata::Serializer::Hal.new(@document, @location, @profile_path).to_json(options)
      when :uber
        Microdata::Serializer::Uber.new(@document, @location, @profile_path).to_json(options)
      else
        Microdata::Serializer::Base.new(@document, @location, @profile_path).to_json(options)
      end
    end
  end
end
