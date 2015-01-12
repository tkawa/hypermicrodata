require "hypermicrodata/version"
require "uberous/uber"
require "nokogiri"
require "mechanize"
require "hypermicrodata/item"
require "hypermicrodata/document"
require "hypermicrodata/property"
require "hypermicrodata/link"
require "hypermicrodata/itemprop_parser"
require "hypermicrodata/submit_button"
require "hypermicrodata/serializer/base"
require "hypermicrodata/serializer/hal"
require "hypermicrodata/serializer/uber"
require "hypermicrodata/extract"
require "hypermicrodata/rails/html_based_json_renderer"
require 'open-uri'
require 'json'
require 'addressable/uri'

module Hypermicrodata

  def self.get_items(location, encoding = nil)
    f = open(location)
    page_url = location
    Hypermicrodata::Document.new(f, page_url: location, force_encoding: encoding).extract_items
  ensure
    f.close
  end

  def self.to_json(location, encoding = nil)
    items = get_items(location, encoding)
    hash = {}
    hash[:items] = items.map do |item|
      item.to_hash
    end
    JSON.pretty_generate hash
  end

end
