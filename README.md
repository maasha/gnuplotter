# gnuplotter

Gnuplot is a very powerful tool to plot scientific data. This is a Ruby wrapper
around Gnuplot with a syntax closely following Gnuplot's. 

Installation
------------
First you must install Gnuplot. Follow the instruction at the Gnuplot website:

http://www.gnuplot.info/

Then install the Ruby gem run:

`gem install gnuplotter`

All done!

Example
-------

```
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
```

See more examples in the `examples/` directory.

Testing
-------
gnuplotter have a `to_gp` method that dumps a standaline Gnuplot script with
data, which is very useful for debugging and testing. For the above example
the output is:

```
set title "Foobar"
set terminal dumb
plot "-" using 1:2:3:4 with vectors nohead title 'foo', "-" using 1:2:3:4 with vectors nohead title 'bar'
0 0 0.5 0.5
0 1 -0.5 0.5
1 1 1 0
e
10 10 1.5 1.5
10 11 -1.5 1.5
11 11 11 10
e
```


Author
------
Copyright 2015 Martin Asser Hansen mail@maasha.dk

License
-------
GPL/v2

