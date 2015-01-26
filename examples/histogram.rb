#!/usr/bin/env ruby

require 'gnuplotter'

data = [
  ["Dogs", 343],
  ["Fishes", 143],
  ["Cats", 123],
  ["Birds", 321],
  ["Bugs", 80],
  ["Cows", 200],
  ["Snakes", 140]
]

gp = GnuPlotter.new
gp.set terminal:  "dumb"
gp.set title:     "Animals"
gp.set xlabel:    "Type"
gp.set ylabel:    "Count"
gp.set yrange:    "[0:*]"
gp.set autoscale: "xfix"
gp.set style:     "fill solid 0.5 border"
gp.set xtics:     "out"
gp.set ytics:     "out"
gp.set xtics:     "rotate" # Don't work with dumb terminal, try "png"

gp.add_dataset(using: "2:xticlabels(1)", with: "boxes notitle") do |plotter|
   data.each { |d| plotter << d }
end

puts gp.plot
