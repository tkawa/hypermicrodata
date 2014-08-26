require 'test_helper'

class TestJson < Test::Unit::TestCase

  def setup
    json = Hypermicrodata.to_json('test/data/example_itemref.html')
    @top_item = JSON.parse(json)['items'].first
  end

  def test_json_without_itemtypes
    assert !@top_item.has_key?('type')
    assert !@top_item['properties']['band'].first.has_key?('type')
  end

end