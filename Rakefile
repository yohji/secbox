require "rake/testtask"
require "rake/notes/rake_task"
require "rdoc/task"

task :default => :test

Rake::TestTask.new do |test|
	test.verbose = true
	test.test_files = FileList["test/**/*.rb"]
end

Rake::Notes::RakeTask.new

RDoc::Task.new do |doc|
	doc.main = "README.md"
	doc.title = "SecBox"
	doc.rdoc_files = FileList.new %w[lib LICENSE README.md]
	doc.rdoc_dir = "rdoc"
end
