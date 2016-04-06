Gem::Specification.new do |s|
  s.name     = "springfeld"
  s.version  = "0.1.0"
  s.date     = "2016-01-12"
  s.summary  = "A small event loop using the reactor pattern"
  s.email    = "bossi.ernestog@gmail.com"
  s.homepage = "http://github.com/bossiernesto/small_reactor"
  s.description = "A small event loop using the reactor pattern"
  s.has_rdoc = true
  s.authors  = ["Ernesto Bossi"]
  s.platform = Gem::Platform::RUBY
  s.license = "BSD Simplified"
  s.files = `git ls-files`.split("\n")
end

