require 'test_helper'

class TestParse < Test::Unit::TestCase

  def setup
    @items = Hypermicrodata.get_items('test/data/example.html', 'utf-8')
  end

  def test_top_item_type
    assert_equal ['http://schema.org/Person'], @items.first.type
  end

  def test_top_item_id
    assert_equal "http://ronallo.com#me", @items.first.id
  end

  def test_top_item_properties
    properties = @items.first.properties
    assert_equal ["Jason Ronallo"], properties['name'].map(&:value)
    assert_equal ["http://twitter.com/ronallo"], properties['url'].map(&:value)
    assert_equal ["Associate Head of Digital Library Initiatives"], properties['jobTitle'].map(&:value)
  end 

  def test_nested_item
    item = @items.first.properties['affiliation'].first.item
    assert_equal ['http://schema.org/Library'], item.type
    assert_equal "http://lib.ncsu.edu", item.id
  end

  def test_nested_item_properties
    properties = @items.first.properties['affiliation'].first.item.properties
    assert_equal ['NCSU Libraries'], properties['name'].map(&:value)
    assert_equal ['http://www.lib.ncsu.edu'], properties['url'].map(&:value)
  end

end
