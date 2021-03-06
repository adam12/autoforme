require "rake"
require "rake/clean"

CLEAN.include ["autoforme-*.gem", "rdoc", "coverage"]

desc "Build autoforme gem"
task :package=>[:clean] do |p|
  sh %{#{FileUtils::RUBY} -S gem build autoforme.gemspec}
end

### Specs

spec = proc do |env|
  env.each{|k,v| ENV[k] = v}
  sh "#{FileUtils::RUBY} spec/all.rb"
  env.each{|k,v| ENV.delete(k)}
end
task :default => :roda_spec

desc "Run specs for all frameworks"
spec_tasks = [:roda_spec, :sinatra_spec]
if RUBY_VERSION >= '1.9'
  spec_tasks << :rails_spec
end
task :spec => spec_tasks

%w'roda sinatra rails'.each do |framework|
  desc "Run specs with for #{framework} with coverage"
  task "#{framework}_spec" do
    spec.call('FRAMEWORK'=>framework)
  end

  desc "Run specs with coverage for #{framework}"
  task "#{framework}_spec_cov" do
    spec.call('FRAMEWORK'=>framework, 'COVERAGE'=>'1')
  end

  desc "Run specs with -w for #{framework}, some warnings filtered"
  task "#{framework}_spec_w" do
    spec.call('FRAMEWORK'=>framework, 'RUBYOPT'=>'-w', 'WARNING'=>'1')
  end
end

### RDoc

RDOC_DEFAULT_OPTS = ["--quiet", "--line-numbers", "--inline-source", '--title', 'AutoForme: Web Administrative Console for Sinatra/Rails and Sequel']

begin
  gem 'hanna-nouveau'
  RDOC_DEFAULT_OPTS.concat(['-f', 'hanna'])
rescue Gem::LoadError
end

rdoc_task_class = begin
  require "rdoc/task"
  RDoc::Task
rescue LoadError
  require "rake/rdoctask"
  Rake::RDocTask
end

RDOC_OPTS = RDOC_DEFAULT_OPTS + ['--main', 'README.rdoc']

rdoc_task_class.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += RDOC_OPTS
  rdoc.rdoc_files.add %w"README.rdoc CHANGELOG MIT-LICENSE lib/**/*.rb"
end

