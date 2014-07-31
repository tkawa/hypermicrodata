require "microdata/version"
require "nokogiri"
require "microdata/item"
require "microdata/document"
require "microdata/itemprop"
require "microdata/serializer/base"
require "microdata/serializer/hal"
require "microdata/extract"
require 'open-uri'
require 'json'
require 'uri'

module Microdata

  # PROPERTY_VALUES = {
  #   meta:     'content',
  #   audio:    'src',
  #   embed:    'src',
  #   iframe:   'src',
  #   img:      'src',
  #   source:   'src',
  #   video:    'src',
  #   a:        'href',
  #   area:     'href',
  #   link:     'href',
  #   object:   'data',
  #   time:     'datetime'
  # }

  def self.get_items(location)
    content = open(location)
    page_url = location
    Microdata::Document.new(content, page_url).extract_items
  end

  def self.to_json(location)
    items = get_items(location)
    hash = {}
    hash[:items] = items.map do |item|
      item.to_hash
    end
    JSON.pretty_generate hash
  end

end
