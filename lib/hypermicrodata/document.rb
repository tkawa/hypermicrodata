module Hypermicrodata
  class Document

    attr_reader :items, :doc

    def initialize(content, options = {})
      encoding = options[:force_encoding] || nil
      @doc = Nokogiri::HTML(content, nil, encoding)
      @page_url = options[:page_url]
      @filter_xpath_attr = options[:filter_xpath_attr]
      @items = extract_items
    end

    def extract_items
      itemscopes = []
      if @filter_xpath_attr
        itemscopes = @doc.xpath("//*[#{@filter_xpath_attr} and @itemscope]")
      end
      if itemscopes.empty?
        print "XPath //*[#{@filter_xpath_attr}] is not found. "
        itemscopes = @doc.xpath("//main[@itemscope]")
      end
      if itemscopes.empty?
        print "root node is used.\n"
        itemscopes = @doc.xpath('self::*[@itemscope] | .//*[@itemscope and not(@itemprop)]')
      else
        print "main node is used.\n"
      end

      itemscopes.collect do |itemscope|
        Item.new(itemscope, @page_url)
      end
    end

  end
end
