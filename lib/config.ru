require PhantomJSProxy::PHANTOMJS
require PhantomJSProxy::SERVER

# You can install Rack middlewares
# to do some crazy stuff like logging,
# filtering, auth or build your own.
use Rack::CommonLogger

run PhantomJSProxy::PhantomJSServer.new()

