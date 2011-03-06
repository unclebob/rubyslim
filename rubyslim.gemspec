
Gem::Specification.new do |s|
  s.name = "rubyslim"
  s.version = "0.1.1"
  s.summary = "Ruby SliM protocol for FitNesse"
  s.description = <<-EOS
    RubySliM implements the SliM protocol for the FitNesse
    acceptance testing framework.
  EOS
  s.authors = ["Robert C. Martin", "Doug Bradbury"]
  s.email = "unclebob@cleancoder.com"
  s.platform = Gem::Platform::RUBY

  s.add_development_dependency 'rspec', '~> 1.3.0'
  s.add_development_dependency 'rcov'

  s.files = `git ls-files`.split("\n")
  s.require_path = 'lib'

  s.executables = ['rubyslim']
end

