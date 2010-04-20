require 'helper'

module RtopiaRuby18
  include Rtopia

  alias to_param to_param_ruby18
end

module String18
  def id
    1001
  end
end

class Person < Struct.new(:name)
  alias to_param name
end

class Entry < Struct.new(:id)
end

class TestRtopia < Test::Unit::TestCase
  include Rtopia

  def setup
    @ruby18 = Object.new
    @ruby18.extend RtopiaRuby18
  end

  def test_R_of_slash_is_slash
    assert_equal '/', R('/')
  end

  def test_R_of_items_is_slash_items
    assert_equal '/items', R(:items)
  end

  def test_R_of_person_named_john_is_john
    assert_equal '/john', R(Person.new('john'))
  end

  def test_R_of_person_named_john_with_items_new_is_john_items_new
    assert_equal '/john/items/new', R(Person.new('john'), :items, :new)
  end

  def test_R_of_items_and_string_1_is_items_1_when_ruby18
    @string_with_id = '1'.extend(String18)

    assert_equal '/items/1', @ruby18.R(:items, @string_with_id)
  end

  def test_R_of_items_and_int_1_is_items_1
    assert_equal '/items/1', @ruby18.R(:items, 1)
  end

  def test_R_of_entries_entry_with_id_10_is_entries_10
    assert_equal '/entries/10', R(:entries, Entry.new(10))
  end
end
