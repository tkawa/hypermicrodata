module Microdata
  class Document

    attr_reader :items, :doc

    def initialize(content, page_url=nil, entry_point=nil)
      @doc = Nokogiri::HTML(content)
      if entry_point
        entry_node = @doc.xpath(%{//*[@id="#{entry_point}"]})
        if entry_node.empty?
          puts "entry point #{entry_point} is not found. root node is used."
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