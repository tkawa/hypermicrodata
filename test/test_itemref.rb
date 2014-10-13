require 'test_helper'

class TestItemref < Test::Unit::TestCase

  def setup
    @items = Hypermicrodata.get_items('test/data/example_itemref.html')
  end

  def test_top_item_name
    assert_equal ['Amanda'], @items.first.properties['name'].map(&:value)
  end

  def test_band_name_and_size
    band = @items.first.properties['band'].first.item
    assert_equal ['Jazz Band'], band.properties['name'].map(&:value)
    assert_equal ['12'], band.properties['size'].map(&:value)
  end

end
