module Microdata
  class Document

    attr_reader :items, :doc

    def initialize(content, page_url=nil, filter_xpath=nil)
      @doc = Nokogiri::HTML(content)
      if filter_xpath
        entry_node = @doc.xpath(filter_xpath)
        if entry_node.empty?
          puts "XPath #{filter_xpath} is not found. root node is used."
        else
          @doc = entry_node
        end
      end
      @page_url = page_url
      @items = extract_items
    end

    def extract_items
      itemscopes = @doc.xpath('self::*[@itemscope] | .//*[@itemscope and not(@itemprop)]')
      return nil unless itemscopes

      itemscopes.collect do |itemscope|
        Item.new(itemscope, @page_url)
      end
    end

  end
end