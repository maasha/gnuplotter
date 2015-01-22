#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), '..')

require 'test/helper'

class TestGnuPlotter < Test::Unit::TestCase 
  def setup
  end

  test "#to_s with set quoted and unquoted options returns correctly" do
    gp = GnuPlotter.new.set(title: "test").set(terminal: "dumb")
    assert_equal(%Q{set title "test"\nset terminal dumb}, gp.to_s)
  end

  test "#to_s with unset quoted and unquoted options returns correctly" do
    gp = GnuPlotter.new.unset(title: true).unset(terminal: true)
    assert_equal(%Q{unset title\nunset terminal}, gp.to_s)
  end
end
