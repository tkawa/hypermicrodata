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
        puts "XPath //*[#{@filter_xpath_attr}] is not found. root node is used." if itemscopes.empty?
      end
      itemscopes = @doc.xpath('self::*[@itemscope] | .//*[@itemscope and not(@itemprop)]') if itemscopes.empty?

      itemscopes.collect do |itemscope|
        Item.new(itemscope, @page_url)
      end
    end

  end
end
