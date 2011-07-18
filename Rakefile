require 'rake'
#require 'rcov/rcovtask'
require 'spec/rake/spectask'

task :default => :spec

desc "Run all spec tests"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = Dir.glob('spec/**/*_spec.rb')
  t.spec_opts = ['--color', '--format specdoc']
end

desc "Run all spec tests and generate coverage report"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_files = Dir.glob('spec/**/*_spec.rb')
  # RCov doesn't like this part for some reason
  #t.spec_opts = ['--color', '--format specdoc']
  t.rcov = true
  t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/,features\/,lib\/test_module\/}
end

