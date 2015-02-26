# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< #
#                                                                                #
# Copyright (C) 2015 Martin Asser Hansen (mail@maasha.dk).                       #
#                                                                                #
# This program is free software; you can redistribute it and/or                  #
# modify it under the terms of the GNU General Public License                    #
# as published by the Free Software Foundation; either version 2                 #
# of the License, or (at your option) any later version.                         #
#                                                                                #
# This program is distributed in the hope that it will be useful,                #
# but WITHOUT ANY WARRANTY; without even the implied warranty of                 #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  #
# GNU General Public License for more details.                                   #
#                                                                                #
# You should have received a copy of the GNU General Public License              #
# along with this program; if not, write to the Free Software                    #
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA. #
#                                                                                #
# http://www.gnu.org/copyleft/gpl.html                                           #
#                                                                                #
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< #

require 'gnuplotter/version'
require 'tempfile'
require 'open3'

# Error class for all things Gnuplotter.
class GnuPlotterError < StandardError; end

class GnuPlotter
  # Quotes around the values of the below keys are stripped.
  NOQUOTE = [
    :auto,
    :autoscale,
    :cbrange,
    :border,
    :boxwidth,
    :datafile,
    :grid,
    :key,
    :linetype,
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
    raise GnuPlotterError, "gnuplot not found" unless which "gnuplot"

    @options  = Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = [] } }
    @datasets = []
  end

  # Method to set an option in the GnuPlot environment e.g:
  # set(title: "Nobel Prize")
  # set(grid: :true)   # note no such thing as set(grid).
  def set(options)
    raise GnuPlotterError, "Non-hash options given" unless options.is_a? Hash

    options.each do |key, value|
      @options[:set][key.to_sym] << value
    end

    self
  end

  # Method to unset an option in the GnuPlot environment e.g:
  # unset(ytics: true)   # note no such thing as unset(ytics).
  def unset(options)
    raise GnuPlotterError, "Non-hash options given" unless options.is_a? Hash

    options.each do |key, value|
      @options[:unset][key.to_sym] << value || true
    end

    self
  end

  # Method that returns a GnuPlot script as a list of lines.
  def to_gp(cmd = "plot")
    if ! @datasets.empty?
      data_lines = []

      @datasets.each do |dataset|
        data_lines.push(*dataset.format_data, "e")
        dataset.delete
      end

      plot_settings + [data_settings(cmd, true)] + data_lines
    else
      plot_settings
    end
  end

  # Method to add a dataset to the current GnuPlot.
  #   add_dataset(using: "1:2:3:4", with: "vectors nohead", title: "'bar'") do |plotter|
  #     data.map { |d| plotter << d }
  #   end
  def add_dataset(options = {})
    raise GnuPlotterError, "No block given" unless block_given?

    dataset = DataSet.new(options)
    @datasets << dataset

    yield dataset
  end

  # Method to execute the plotting of added datasets.
  # Any plot data, i.e. dumb terminal, is returned.
  def plot
    gnuplot("plot")
  end

  # Method to execute the splotting of added datasets.
  # Any plot data, i.e. dumb terminal, is returned.
  def splot
    gnuplot("splot")
  end

  private

  # Cross-platform way of finding an executable in the $PATH.
  #
  #   which('ruby') #=> /usr/bin/ruby
  def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']

    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      }
    end

    nil
  end

  # Method that calls gnuplot via open3 and performs the plotting.
  # Any plot data, i.e. dumb terminal, is returned.
  def gnuplot(method)
    @datasets.each { |dataset| dataset.close }

    result = nil

    Open3.popen3("gnuplot -persist") do |stdin, stdout, stderr, wait_thr|
      plot_settings.each { |line| stdin.puts line }

      if @datasets.empty?
        stdin.puts "#{method} 1/0"
      else
        stdin.puts data_settings(method)
      end

      stdin.close
      result = stdout.read
      stdout.close

      exit_status = wait_thr.value

      unless exit_status.success?
        raise GnuPlotterError, stderr.read
      end
    end

    @datasets.each { |dataset| dataset.delete }

    result
  end

  # Returns a list of lines with the plot settings.
  def plot_settings
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

    lines
  end

  # Returns one comma seperated line with plot settings for each dataset.
  def data_settings(method, input = nil)
    list = []

    @datasets.each do |dataset|
      list << dataset.format_options(input)
    end

    "#{method} " + list.join(", ")
  end

  # Nested class for GnuPlot datasets.
  class DataSet
    # Constructor for the DataSet object.
    def initialize(options = {})
      @options = options
      @file    = Tempfile.new("gp")
      @io      = @file.open
    end

    # Write method.
    def <<(*obj)
      @io.puts obj.join(" ")
    end

    alias :write :<<

    # Method to close a DataSet temporary file io.
    def close
      @io.close unless @io.closed?
    end

    # Method to delete a DataSet temporary file.
    def delete
      @io.close unless @io.closed?
      @file.unlink if File.exist? @file.path
    end

    # Method that builds a plot/splot command string from dataset options.
    def format_options(input = nil)
      options = []

      if input
        options << %Q{"-"}
      else
        options << %Q{"#{@file.path}"}
      end

      @options.each do |key, value|
        if value == :true
          options << "#{key}"
        else
          options << "#{key} #{value}"
        end
      end

      options.join(" ")
    end

    # Method that returns data lines from file.
    def format_data
      lines = []

      @io.close if @io.respond_to? :close

      File.open(@file) do |ios|
        ios.each do |line|
          line.chomp!

          lines << line
        end
      end

      lines
    end
  end
end
