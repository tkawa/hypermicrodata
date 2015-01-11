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
      itemscopes.collect do |itemscope|
        Item.parse(itemscope, @page_url)
      end
    end

    private

    def itemscopes
      items_xpath = 'self::*[@itemscope] | .//*[@itemscope and not(@itemprop)] | .//form[not(@itemprop)]'
      if @filter_xpath_attr
        filtered_doc = @doc.xpath("//*[#{@filter_xpath_attr}]")
        unless filtered_doc.empty?
          return filtered_doc.xpath(items_xpath)
        end
      end
      print "XPath //*[#{@filter_xpath_attr}] is not found. "
      filtered_doc = @doc.xpath('//main')
      unless filtered_doc.empty?
        print "main node is used.\n"
        return filtered_doc.xpath(items_xpath)
      end
      print "root node is used.\n"
      @doc.xpath(items_xpath)
    end
  end
end
