require 'gnuplotter/version'

class GnuPlotter
  NOQUOTE = [
    :auto,
    :autoscale,
    :cbrange,
    :border,
    :boxwidth,
    :datafile,
    :grid,
    :key,
    :logscale,
    :nocbtics,
    :palette,
    :rtics,
    :terminal,
    :tic,
    :style,
    :view,
    :yrange,
    :ytics,
    :xrange,
    :xtics,
    :ztics
  ]


  # Constructor method for a GnuPlot object.
  def initialize
    @options  = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = [] } }
    @datasets = []
  end

  # Method to set an option in the GnuPlot environment e.g:
  # set(title: "Nobel Prize")
  def set(options)
    raise unless options.is_a? Hash

    options.each do |key, value|
      @options[:set][key.to_sym] << value
    end

    self
  end

  # Method to unset an option in the GnuPlot environment e.g:
  # unset(ytics: true)
  def unset(options)
    raise unless options.is_a? Hash

    options.each do |key, value|
      @options[:unset][key.to_sym] << value || true
    end

    self
  end

  def to_s
    lines = []

    @options.each do |method, options|
      options.each do |key, list|
        list.each do |value|
          if value == :true or value === true
            lines << %Q{#{method} #{key}}
          elsif NOQUOTE.include? key.to_sym
            lines << %Q{#{method} #{key} #{value}}
          else
            lines << %Q{#{method} #{key} "#{value}"}
          end
        end
      end
    end

    lines.join $/
  end
end
