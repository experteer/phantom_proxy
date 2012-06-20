require 'rubygems'

module PhantomJSProxy
	ROOT = File.expand_path(File.dirname(__FILE__))
	SCRIPT = ROOT+"/phantom_proxy/scripts/proxy.js"
	CONTROL_PANEL = ROOT+"/phantom_proxy/web/control_panel.html"
	PHANTOMJS_BIN = 'phantomjs'#ROOT+'/phantom_proxy/vendor/bin/phantomjs'
end

require PhantomJSProxy::ROOT+'/phantom_proxy/phantomjs.rb'
require PhantomJSProxy::ROOT+'/phantom_proxy/phantomjsserver.rb'
require PhantomJSProxy::ROOT+'/phantom_proxy/phantomjs_control_panel.rb'