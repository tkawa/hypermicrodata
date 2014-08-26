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
require 'open-uri'
require 'json'
require 'uri'

module Hypermicrodata

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
    Hypermicrodata::Document.new(content, page_url).extract_items
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
