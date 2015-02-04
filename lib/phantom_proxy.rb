require "phantom_proxy/version"

#libs
require 'tempfile'
require 'scanf'
require 'nokogiri'
require 'journey'
require 'eventmachine'
require 'em-synchrony'
require 'json'
require 'logger'
require 'erb'
require 'openssl'
require 'base64'
require 'goliath/api'
require 'hmac-md5'

# Helper
require 'phantom_proxy/helper/logable'
require 'phantom_proxy/helper/jsonizer'
require 'phantom_proxy/helper/template_renderer'
require 'phantom_proxy/helper/status_info'
require 'phantom_proxy/helper/http'

# PhantomJS
require 'phantom_proxy/phantomjs/phantomjs'

# Router
require 'phantom_proxy/router/app_router'

# API
require 'phantom_proxy/status/status_api'
require 'phantom_proxy/proxy/proxy_api'

require 'phantom_proxy/service'

PHANTOMPROXY_ROOT=Dir.pwd
PHANTOMPROXY_GEM_DIR = File.join(File.dirname(__FILE__), "../")

module PhantomProxy
  def self.script_path
    @script_path||=root_gem.join("lib/phantom_proxy/scripts/proxy.js").to_s
  end

  def self.phantomjs_bin
    "phantomjs"
  end

  def self.root
    @root ||= Pathname.new(PHANTOMPROXY_ROOT)
  end

  def self.root_gem
    @root_gem ||= Pathname.new(PHANTOMPROXY_GEM_DIR)
  end

  def self.logger=(obj)
    @logger=obj
  end

  def self.logger
    Thread.current[:in_fiber_logger] ||= PhantomProxyLogger.new((@logger||Logger.new(STDOUT)),Logable.next_id)
  end

  def self.hmac_key
    @hmac_key
  end

  def self.hmac_key=(obj)
    @hmac_key=::HMAC::MD5.new obj
  end

  def self.always_image?
    @always_image
  end

  def self.always_image=(obj)
    @always_image=obj
  end

  def self.always_iframe?
    @always_iframe
  end

  def self.always_iframe=(obj)
    @always_iframe=obj
  end

  def self.threadpool_size=(obj)
    @threadpool_size=obj.to_i
  end

  def self.threadpool_size
    @threadpool_size
  end

  def self.wait_for(op = nil)
    fiber = Fiber.current
    EM.defer(op, Proc.new {|result|
            fiber.resume result
          })
    Fiber.yield
  end
end
