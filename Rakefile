require "rake/testtask"
require "rdoc/task"

task :default => :test

Rake::TestTask.new do |test|
	test.verbose = true
	test.test_files = FileList["test/**/*.rb"]
end

RDoc::Task.new do |doc|
	doc.main = "README.md"
	doc.title = "SecBox"
	doc.rdoc_files = FileList.new %w[lib LICENSE README.md]
	doc.rdoc_dir = "rdoc"
end
