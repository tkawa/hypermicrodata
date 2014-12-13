module Hypermicrodata
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
      properties.each do |name, same_name_properties|
        final_values = same_name_properties.map do |property|
          if property.item
            property.item.to_hash
          else
            property.value
          end
        end
        hash[:properties][name] = final_values
      end
      hash[:links] = {}
      links.each do |rel, same_rel_links|
        final_values = same_rel_links.map do |link|
          if link.item
            link.item.to_hash
          else
            link.value
          end
        end
        hash[:links][rel] = final_values
      end
      hash
    end

    def all_properties_and_links
      properties.values.flatten | links.values.flatten
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
      add_itemprop(element) if itemscope || itemprop || ItempropParser::LINK_ELEMENTS.include?(element.name)
      add_form(element) if element.name == 'form'
      parse_elements(internal_elements) if internal_elements && !itemscope
    end

    # Add an 'itemprop' to the properties
    def add_itemprop(element)
      property = ItempropParser.parse(element, @page_url)
      if property.link? && property.names.empty? && property.rels.empty?
        href = property.value.to_s.strip
        unless href.empty? || href == '#' # href which doesn't work as link is ignored
          (@links[element.name] ||= []) << property
        end
      else
        property.names.each { |name| (@properties[name] ||= []) << property }
        property.rels.each { |rel| (@links[rel] ||= []) << property }
      end
    end

    # Add any properties referred to by 'itemref'
    def add_itemref_properties(element)
      itemref = element.attribute('itemref')
      if itemref
        itemref.value.split(' ').each {|id| parse_elements(find_with_id(id))}
      end
    end

    def add_form(element)
      submit_buttons = FormParser.parse(element, @page_url)
      submit_buttons.each do |submit_button|
        submit_button.names.each { |name| (@properties[name] ||= []) << submit_button }
        if submit_button.rels.empty?
          (@links['submit'] ||= []) << submit_button
        else
          submit_button.rels.each { |rel| (@links[rel] ||= []) << submit_button }
        end
      end
    end

    # Find an element with a matching id
    def find_with_id(id)
      @top_node.search("//*[@id='#{id}']")
    end

  end
end
