#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), '..')

require 'test/helper'

class TestGnuPlotter < Test::Unit::TestCase 
  def setup
    @data1 = [
      [0, 0, 0.5,  0.5],
      [0, 1, -0.5, 0.5],
      [1, 1, 1,    0]
    ]

    @data2 = [
      [10, 10, 1.5,  1.5],
      [10, 11, -1.5, 1.5],
      [11, 11, 11,   10]
    ]

    @gp = GnuPlotter.new.set(title: "test").set(terminal: "dumb")
  end

  test "#set with non-hash options raises" do
    assert_raise(GnuPlotterError) { GnuPlotter.new.set("title") }
  end

  test "#unset with non-hash options raises" do
    assert_raise(GnuPlotterError) { GnuPlotter.new.set("title") }
  end

  test "#to_s with nothing set and no data returns empty" do
  end

  test "#to_s with set quoted and unquoted options returns correctly" do
    gp = GnuPlotter.new.set(title: "test").set(terminal: "dumb")
    assert_equal(%Q{set title "test"\nset terminal dumb\n}, gp.to_s)
  end

  test "#to_s with unset quoted and unquoted options returns correctly" do
    gp = GnuPlotter.new.unset(title: true).unset(terminal: true)
    assert_equal(%Q{unset title\nunset terminal\n}, gp.to_s)
  end

  test "#add_dataset without block raises" do
    assert_raise(GnuPlotterError) { @gp.add_dataset }
  end

  test "#to_s with one dataset returns correctly" do
    @gp.add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'foo'") do |plotter|
        @data1.map { |d| plotter << d }
    end

    expected = <<END
set title "test"
set terminal dumb
plot "-" using 1:2:3:4 with vectors nohead title 'foo'
0, 0, 0.5, 0.5
0, 1, -0.5, 0.5
1, 1, 1, 0
END

    assert_equal(expected, @gp.to_s)
  end

  test "#to_s with two datasets returns correctly" do
    @gp.add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'foo'") do |plotter|
        @data1.map { |d| plotter << d }
    end

    @gp.add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'bar'") do |plotter|
        @data2.map { |d| plotter << d }
    end

    expected = <<END
set title "test"
set terminal dumb
plot "-" using 1:2:3:4 with vectors nohead title 'foo', "-" using 1:2:3:4 with vectors nohead title 'bar'
0, 0, 0.5, 0.5
0, 1, -0.5, 0.5
1, 1, 1, 0
e
10, 10, 1.5, 1.5
10, 11, -1.5, 1.5
11, 11, 11, 10
END

    assert_equal(expected, @gp.to_s)
  end

#  test "#plot produces something" do
#    assert_equal("", @gp.plot)
#  end

#  test "#splot produces something" do
#    assert_equal("", @gp.splot)
#  end
end
