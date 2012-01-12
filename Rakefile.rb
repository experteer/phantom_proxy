require 'rubygems'

task :build do
	sh "gem build phproxy.gemspec"
end

task :install do
	sh "gem install phantom_proxy-*.gem"
end

task :uninstall do
	sh "gem uninstall phantom_proxy"
end

task :clean do
	sh "rm phantom_proxy-*.gem"
end
