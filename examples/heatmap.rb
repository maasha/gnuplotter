#!/usr/bin/env ruby

require 'gnuplotter'

gp = GnuPlotter.new
gp.set   title:     "Heatmap"
gp.set   view:      "map"
gp.set   autoscale: "xfix"
gp.set   autoscale: "yfix"
gp.set   nokey:     true
gp.set   tic:       "scale 0"
gp.set   palette:   "rgbformulae 22,13,10"
gp.unset xtics:     true
gp.unset ytics:     true

gp.add_dataset(matrix: :true, with: "image") do |plotter|
  row = []

  0.upto(400) do |i|
    0.upto(600) do |j|
      row[j] = i + j
    end

    plotter << row
  end
end

gp.splot
