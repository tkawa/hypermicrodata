require 'test_helper'

class TestParse < Test::Unit::TestCase

  def setup
    @items = Hypermicrodata.get_items('test/data/example.html')
  end

  def test_top_item_type
    assert_equal ['http://schema.org/Person'], @items.first.type
  end

  def test_top_item_id
    assert_equal "http://ronallo.com#me", @items.first.id
  end

  def test_top_item_properties
    properties = @items.first.properties
    assert_equal ["Jason Ronallo"], properties['name']
    assert_equal ["http://twitter.com/ronallo"], properties['url']
    assert_equal ["Associate Head of Digital Library Initiatives"], properties['jobTitle']
  end 

  def test_nested_item
    item = @items.first.properties['affiliation'][0]
    assert_equal ['http://schema.org/Library'], item.type
    assert_equal "http://lib.ncsu.edu", item.id
  end

  def test_nested_item_properties
    properties = @items.first.properties['affiliation'][0].properties
    assert_equal ['NCSU Libraries'], properties['name']
    assert_equal ['http://www.lib.ncsu.edu'], properties['url']
  end

end