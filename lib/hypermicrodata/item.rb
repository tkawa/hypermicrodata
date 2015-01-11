module Hypermicrodata
  class Item
    attr_reader :type, :properties, :links, :id

    def self.parse(top_node, page_url)
      if top_node.name == 'form'
        FormItem.new(top_node, page_url)
      else
        Item.new(top_node, page_url)
      end
    end

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
      add_itemprop(element) if itemprop || ItempropParser::LINK_ELEMENTS.include?(element.name)
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

    # Find an element with a matching id
    def find_with_id(id)
      @top_node.search("//*[@id='#{id}']")
    end
  end

  class FormItem < Item
    attr_reader :submit_buttons

    def initialize(top_node, page_url)
      form = Mechanize::Form.new(top_node)
      @submit_buttons = form.submits.map do |button|
        SubmitButton.new(button, form)
      end
      super
    end

    private

    def extract_itemtype
      super || ['http://schema.org/Action']
    end

    # TODO: Make it DRY
    def parse_element(element)
      itemscope = element.attribute('itemscope')
      itemprop = element.attribute('itemprop')
      internal_elements = extract_elements(element)
      add_itemprop(element) if itemprop || ItempropParser::LINK_ELEMENTS.include?(element.name) || submit_button_include?(element)
      parse_elements(internal_elements) if internal_elements && !itemscope
    end

    def add_itemprop(element)
      return super unless submit_button_include?(element)
      property = @submit_buttons.find {|b| b.node == element }
      if property.names.empty? && property.rels.empty?
        href = property.value.to_s.strip
        unless href.empty? || href == '#' # href which doesn't work as link is ignored
          (@links[element.name] ||= []) << property
        end
      else
        property.names.each { |name| (@properties[name] ||= []) << property }
        property.rels.each { |rel| (@links[rel] ||= []) << property }
      end
    end

    def submit_button_include?(element)
      @submit_buttons.any? {|b| b.node == element }
    end
  end
end

# Patch for bug
Mechanize::Form.class_eval do
  # Returns all buttons of type Submit
  def submits
    @submits ||= buttons.select {|f|
      f.class == Mechanize::Form::Submit || (f.class == Mechanize::Form::Button && (f.type.nil? || f.type == 'submit'))
    }
  end
end
