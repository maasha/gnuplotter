#!/usr/bin/env ruby

require 'gnuplotter'

data1 = [
  [0,   0,   0.5,  0.5],
  [0,   1,   -0.5, 0.5],
  [1,   1,   1,    0]
]

data2 = [
  [10,   10,   1.5,  1.5],
  [10,   11,   -1.5, 1.5],
  [11,   11,   11,    10]
]

gp = GnuPlotter.new

gp.set title:    "Foobar"
gp.set terminal: "dumb"

gp.add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'foo'") do |plotter|
  data1.map { |d| plotter << d }
end

gp.add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'bar'") do |plotter|
  data2.map { |d| plotter << d }
end

puts gp.plot
