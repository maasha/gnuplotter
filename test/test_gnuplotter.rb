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

  test "#to_gp with no settings returns empty array" do
    assert_equal([], GnuPlotter.new.to_gp)
  end

  test "#set with non-hash options raises" do
    assert_raise(GnuPlotterError) { GnuPlotter.new.set("title") }
  end

  test "#unset with non-hash options raises" do
    assert_raise(GnuPlotterError) { GnuPlotter.new.set("title") }
  end

  test "#to_gp with set quoted and unquoted options returns correctly" do
    gp = GnuPlotter.new.set(title: "test").set(terminal: "dumb")
    assert_equal(['set title "test"', 'set terminal dumb'], gp.to_gp)
  end

  test "#to_gp with unset quoted and unquoted options returns correctly" do
    gp = GnuPlotter.new.unset(title: true).unset(terminal: true)
    assert_equal(['unset title', 'unset terminal'], gp.to_gp)
  end

  test "#add_dataset without block raises" do
    assert_raise(GnuPlotterError) { @gp.add_dataset }
  end

  test "#to_gp with one dataset returns correctly" do
    @gp.add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'foo'") do |plotter|
      @data1.map { |d| plotter << d }
    end

    expected = [
      'set title "test"',
      'set terminal dumb',
      'plot "-" using 1:2:3:4 with vectors nohead title \'foo\'',
      '0 0 0.5 0.5',
      '0 1 -0.5 0.5',
      '1 1 1 0',
      'e'
    ]

    assert_equal(expected, @gp.to_gp)
  end

  test "#to_gp with two datasets returns correctly" do
    @gp.add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'foo'") do |plotter|
        @data1.map { |d| plotter << d }
    end

    @gp.add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'bar'") do |plotter|
        @data2.map { |d| plotter << d }
    end

    expected = [
      'set title "test"',
      'set terminal dumb',
      'plot "-" using 1:2:3:4 with vectors nohead title \'foo\', "-" using 1:2:3:4 with vectors nohead title \'bar\'',
      '0 0 0.5 0.5',
      '0 1 -0.5 0.5',
      '1 1 1 0',
      'e',
      '10 10 1.5 1.5',
      '10 11 -1.5 1.5',
      '11 11 11 10',
      'e'
    ]

    assert_equal(expected, @gp.to_gp)
  end

  test "#plot produces something" do
    @gp.add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'foo'") do |plotter|
        @data1.map { |d| plotter << d }
    end

    assert_equal(String, @gp.plot.class)
  end

  test "#splot produces something" do
    @gp.add_dataset(matrix: "with lines notitle") do |plotter|
        @data1.map { |d| plotter << d }
    end

    assert_equal(String, @gp.splot.class)
  end
end
