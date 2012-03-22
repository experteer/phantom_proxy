require 'rubygems'

module PhantomJSProxy
	ROOT = File.expand_path(File.dirname(__FILE__))
	SCRIPT = ROOT+"/phantom_proxy/scripts/proxy.js"
	PHANTOMJS_BIN = ROOT+'/../bin/phantomjs'
end

require PhantomJSProxy::ROOT+'/phantom_proxy/phantomjs.rb'
require PhantomJSProxy::ROOT+'/phantom_proxy/phantomjsserver.rb'