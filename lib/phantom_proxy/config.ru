require 'rubygems'
require 'phantom_proxy'

# You can install Rack middlewares
# to do some crazy stuff like logging,
# filtering, auth or build your own.
use Rack::CommonLogger

run PhantomJSProxy::PhantomJSServer.new()

