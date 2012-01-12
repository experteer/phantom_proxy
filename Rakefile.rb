require 'rubygems'

task :build do
	sh "gem build phproxy.gemspec"
end

task :install do
	sh "gem install phantomjs_proxy-*.gem"
end

task :uninstall do
	sh "gem uninstall phantomjs_proxy"
end

task :clean do
	sh "rm phantomjs_proxy-*.gem"
end
