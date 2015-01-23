require 'gnuplotter/version'
require 'tempfile'

class GnuPlotterError < StandardError; end

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
    raise GnuPlotterError, "Non-hash options given" unless options.is_a? Hash

    options.each do |key, value|
      @options[:set][key.to_sym] << value
    end

    self
  end

  # Method to unset an option in the GnuPlot environment e.g:
  # unset(ytics: true)
  def unset(options)
    raise GnuPlotterError, "Non-hash options given" unless options.is_a? Hash

    options.each do |key, value|
      @options[:unset][key.to_sym] << value || true
    end

    self
  end

  # Method that returns lines of gnuplot commands, options and data.
  def to_s(cmd = "plot")
    cmd_lines = []

    @options.each do |method, options|
      options.each do |key, list|
        list.each do |value|
          if value == :true or value === true
            cmd_lines << %Q{#{method} #{key}}
          elsif NOQUOTE.include? key.to_sym
            cmd_lines << %Q{#{method} #{key} #{value}}
          else
            cmd_lines << %Q{#{method} #{key} "#{value}"}
          end
        end
      end
    end

    cmd_lines  = cmd_lines.join($/)
    opt_lines  = @datasets.inject([]) { |list, dataset| list << dataset.format_options }.join(", ")
    data_lines = @datasets.inject([]) { |list, dataset| list << dataset.format_data.join($/) }.join("#$/e#$/")

    if opt_lines.empty?
      lines = [cmd_lines].join $/
    elsif data_lines.empty?
      lines = [cmd_lines, "#{cmd} " + opt_lines].join $/
    else
      lines = [cmd_lines, "#{cmd} " + opt_lines, data_lines].join $/
    end

    lines + $/
  end

  # Method to add a dataset to the current GnuPlot.
  #   add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'bar'") do |plotter|
  #     data2.map { |d| plotter << d }
  #   end
  def add_dataset(options = {})
    raise GnuPlotterError, "No block given" unless block_given?

    dataset = DataSet.new(options)
    @datasets << dataset

    yield dataset
  end

  # Method to execute the plotting of added datasets.
  def plot
    #@datasets.each { |dataset| dataset.close }

    result = nil

    Open3.popen3("gnuplot -persist") do |stdin, stdout, stderr, wait_thr|

      if @datasets.empty?
        lines << "plot 1/0"
      else
        lines << "plot " + @datasets.map { |dataset| dataset.to_gp }.join(", ")
      end

      lines.map { |l| $stderr.puts l } if $VERBOSE
      lines.map { |l| stdin.puts l }

      stdin.close
      result = stdout.read
      stdout.close

      exit_status = wait_thr.value

      unless exit_status.success?
        raise GnuPlotterError, stderr.read
      end
    end

    result
  end

  def splot
  end

  # Nested class for GnuPlot datasets.
  class DataSet
    def initialize(options = {})
      @options = options
      @data    = []
    end

    # Write method.
    def <<(*obj)
      @data << obj
    end

    alias :write :<<

    # Method that builds a plot/splot command string from dataset options.
    def format_options
      options = []
      options << %Q{"-"}

      @options.each do |key, value|
        if value == :true
          options << "#{key}"
        else
          options << "#{key} #{value}"
        end
      end

      options.join(" ")
    end

    def format_data
      lines = []

      @data.each do |row|
        lines << row.join(", ")
      end

      lines
    end
  end
end
