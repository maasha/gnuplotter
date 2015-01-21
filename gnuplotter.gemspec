$:.push File.expand_path("../lib", __FILE__)

require 'gnuplotter/version'

Gem::Specification.new do |s|
  s.name              = 'gnuplotter'
  s.version           = GnuPlotter::VERSION
  s.platform          = Gem::Platform::RUBY
  s.date              = Time.now.strftime("%F")
  s.summary           = "GnuPlotter"
  s.description       = "GnuPlotter is a wrapper around gnuplot."
  s.authors           = ["Martin A. Hansen"]
  s.email             = 'mail@maasha.dk'
  s.rubyforge_project = "gnuplotter"
  s.homepage          = 'http://github.com/maasha/gnuplotter'
  s.license           = 'GPL2'
  s.rubygems_version  = "2.0.0"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables       = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files  = Dir["wiki/*.rdoc"]
  s.require_paths     = ["lib"]
end
