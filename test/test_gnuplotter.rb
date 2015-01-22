#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), '..')

require 'test/helper'

class TestGnuPlotter < Test::Unit::TestCase 
  def setup
  end

  test "#new" do
    gp = GnuPlotter.new.set(title: "test")
    assert_equal("", gp.to_s)
  end
end
