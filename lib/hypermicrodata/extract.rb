module Hypermicrodata
  class Extract
    def initialize(html, options = {})
      default_data_attr_name = 'main-item'
      @location = options[:location]
      @profile_path = options[:profile_path]
      filter_xpath_attr = "@data-#{options[:data_attr_name] || default_data_attr_name}"
      @document = Hypermicrodata::Document.new(html, page_url: @location, filter_xpath_attr: filter_xpath_attr)
    end

    def to_json(format = :plain, options = {})
      case format
      when :hal
        Hypermicrodata::Serializer::Hal.new(@document, @location, @profile_path).to_json(options)
      when :uber
        Hypermicrodata::Serializer::Uber.new(@document, @location, @profile_path).to_json(options)
      else
        Hypermicrodata::Serializer::Base.new(@document, @location, @profile_path).to_json(options)
      end
    end
  end
end
