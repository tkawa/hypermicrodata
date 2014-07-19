module Microdata
  class Item
    attr_reader :type, :properties, :links, :id

    def initialize(top_node, page_url)
      @top_node = top_node
      @type = extract_itemtype
      @id   = extract_itemid
      @properties = {}
      @links = {}
      @page_url = page_url
      add_itemref_properties(@top_node)
      parse_elements(extract_elements(@top_node))
    end

    def to_hash
      hash = {}
      hash[:id] = id if id
      hash[:type] = type if type
      hash[:properties] = {}
      properties.each do |name, itemprops|
        final_values = itemprops.map do |itemprop|
          value = itemprop.properties[name]
          if value.is_a?(Item)
            value.to_hash
          else
            value
          end
        end
        hash[:properties][name] = final_values
      end
      hash[:links] = {}
      links.each do |name, itemprops|
        final_values = itemprops.map do |itemprop|
          itemprop.links[name]
        end
        hash[:links][name] = final_values
      end
      hash
    end

    private

    def extract_elements(node)
      node.search('./*')
    end

    def extract_itemid
      (value = @top_node.attribute('itemid')) ? value.value : nil
    end

    def extract_itemtype
      (value = @top_node.attribute('itemtype')) ? value.value.split(' ') : nil
    end

    def parse_elements(elements)
      elements.each {|element| parse_element(element)}
    end

    def parse_element(element)
      itemscope = element.attribute('itemscope')
      itemprop = element.attribute('itemprop')
      internal_elements = extract_elements(element)
      add_itemprop(element) if itemscope || itemprop
      parse_elements(internal_elements) if internal_elements && !itemscope
    end

    # Add an 'itemprop' to the properties
    def add_itemprop(element)
      itemprop = Itemprop.new(element, @page_url)
      itemprop.properties.each { |name, value| (@properties[name] ||= []) << itemprop }
      itemprop.links.each { |name, value| (@links[name] ||= []) << itemprop }
    end

    # Add any properties referred to by 'itemref'
    def add_itemref_properties(element)
      itemref = element.attribute('itemref')
      if itemref
        itemref.value.split(' ').each {|id| parse_elements(find_with_id(id))}
      end
    end

    # Find an element with a matching id
    def find_with_id(id)
      @top_node.search("//*[@id='#{id}']")
    end

  end
end