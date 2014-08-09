module Microdata
# Class that parses itemprop elements
  class ItempropParser

    NON_TEXTCONTENT_ELEMENTS = {
      'a' => 'href',        'area' => 'href',
      'audio' => 'src',     'embed' => 'src',
      'iframe' => 'src',    'img' => 'src',
      'link' => 'href',     'meta' => 'content',
      'object' => 'data',   'source' => 'src',
      'time' => 'datetime', 'track' => 'src',
      'video' => 'src'
    }

    LINK_ELEMENTS = ['a', 'area', 'audio', 'embed', 'iframe',
                     'img', 'link', 'source', 'track', 'video']

    URL_ATTRIBUTES = ['data', 'href', 'src']

    # A Hash representing the properties.
    # Hash is of the form {'property name' => 'value'}
    attr_reader :property
    # attr_reader :properties
    # attr_reader :links

    # Create a new Itemprop object
    # [element]  The itemprop element to be parsed
    # [page_url] The url of the page, including filename, used to form
    #            absolute urls
    def initialize(element, page_url=nil)
      @element, @page_url = element, page_url
      @property = Property.new(extract_property, extract_property_names, extract_rel_names)
      # @properties = extract_properties
      # @links = extract_links
    end

    # Parse the element and return a hash representing the properties.
    # Hash is of the form {'property name' => 'value'}
    # [element]  The itemprop element to be parsed
    # [page_url] The url of the page, including filename, used to form
    #            absolute urls
    def self.parse(element, page_url=nil)
      self.new(element, page_url).property
    end

    def link?
      LINK_ELEMENTS.include?(@element.name)
    end

  private
    def extract_properties
      prop_names = extract_property_names
      prop_names.each_with_object({}) do |name, memo|
        memo[name] = extract_property
      end
    end

    def extract_links
      rel_names = extract_rel_names
      rel_names.each_with_object({}) do |name, memo|
        memo[name] = extract_property_value
      end
    end

    # This returns an empty string if can't form a valid
    # absolute url as per the Microdata spec.
    def make_absolute_url(url)
      return url unless URI.parse(url).relative?
      begin
        URI.parse(@page_url).merge(url).to_s
      rescue URI::Error
        url
      end
    end

    def non_textcontent_element?(element)
      NON_TEXTCONTENT_ELEMENTS.has_key?(element)
    end

    def url_attribute?(attribute)
      URL_ATTRIBUTES.include?(attribute)
    end

    def extract_property_names
      itemprop_attr = @element.attribute('itemprop')
      itemprop_attr ? itemprop_attr.value.split : []
    end

    def extract_rel_names
      link_rel = @element.attribute('rel')
      link? && link_rel ? link_rel.value.split : []
    end

    def extract_property_value
      element = @element.name
      if non_textcontent_element?(element)
        attribute = NON_TEXTCONTENT_ELEMENTS[element]
        value = @element.attribute(attribute).value
        url_attribute?(attribute) ? make_absolute_url(value) : value
      else
        @element.inner_text.strip
      end
    end

    def extract_property
      if @element.attribute('itemscope')
        Item.new(@element, @page_url)
      else
        extract_property_value
      end
    end

  end
end