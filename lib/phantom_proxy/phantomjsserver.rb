require 'net/http'
require 'hmac-md5'
require 'base64'

module PhantomJSProxy
	class PhantomJSServer
		def initialize
		  @control_panel = PhantomJSProxy::PhantomJSControlPanel.new
		  
		  #load key
		  @hmac_activated = false
      @hmac = nil
		  if File.directory?("/tmp/phantom_proxy")
        if File.exists?("/tmp/phantom_proxy/key")
          key = File.open("/tmp/phantom_proxy/key", "r").read
          #puts "HMAC_KEY: #{key}"
          @hmac_activated = true
          @hmac = HMAC::MD5.new key
        end
      end
		end
		
		attr_accessor :control_panel
		attr_accessor :hmac
		attr_accessor :hmac_activated
    
    def check_for_route(url)
      if /\.js/i.match(url) and !/\.jsp/i.match(url)
        return 'text/html'
      end
      if /\.css/i.match(url)
        return 'text/css'
      end
      if /\.png/i.match(url) or /\.jpg/i.match(url) or /\.jpeg/i.match(url) or /\.gif/i.match(url)
        return 'image/*'
      end
      if /phantom_proxy_control_panel/.match(url)
        return 'control_panel'
      end
      if /phantomProxy\.get/.match(url)
      	return "base64"
      end
      "none"
    end
    
    def route(env, type)
      _req = Net::HTTP::Get.new(env['REQUEST_URI'])
      
      _req['User-Agent'] = env['HTTP_USER_AGENT']
      
      _res = Net::HTTP.start(env['HTTP_HOST'], env['SERVER_PORT']) {|http|
        #http.request(_req)
        http.get(env['REQUEST_URI'])
      }
      
      #env['rack.errors'].write("Response is:"+_res.body+"\n")
      
      resp = Rack::Response.new([], 200, 	{'Content-Type' => type}) { |r|
        r.write(_res.body)
      }
      resp.finish
    end
    
    def check_request_security req, env
      if !env['HTTP_HMAC_KEY'] || !env['HTTP_HMAC_TIME']
        return false
      end
      
      client_key = env['HTTP_HMAC_KEY']
      client_time= Time.parse(env['HTTP_HMAC_TIME'])
      remote_time= Time.now
      remote_key = hmac.update(env['REQUEST_URI']+env['HTTP_HMAC_TIME']).hexdigest

      if (client_key != remote_key || (remote_time-client_time).abs > 120)
        control_panel.add_special_request "@did not pass security check"
        return false
      end
      return true
    end

    def getOptions(env)
    	if defined? env['HTTP_GET_PAGE_AS_IMAGE']
    		picture = env['HTTP_GET_PAGE_AS_IMAGE']
      else
      	picture = true
      end
      
      if defined? env['HTTP_GET_PAGE_WITH_IFRAMES']
      	loadFrames = env['HTTP_GET_PAGE_WITH_IFRAMES']
      else
        loadFrames = false
      end
      
      return picture,loadFrames
    end

		def prepareUrl(env, params, req, https_request, type)
			if type == "none"
				url = env['REQUEST_URI'];
        if https_request
          url['http'] = 'https'
          url[':443'] = ''
        end
        
        if params.length > 0
          url += '?'+params;
        end
        return url
			end
			url = Base64.decode64(req.params["address"])
			env['rack.errors'].write("After Base64 decoding: "+url)
			return url
		end

		def call(env)
		  control_panel.add_request
		  
			req = Rack::Request.new(env)
			
			request_parameters = env.collect { |k, v| "\t#{k} : #{v}\n" }.join
			env['rack.errors'].write("The request: "+req.url()+"\nGET: "+request_parameters+"\n")
			
			if hmac_activated && hmac && !check_request_security(req, env)
        resp = Rack::Response.new([], 503,  {
                                                'Content-Type' => 'text/html'
                                            }) { |r|
          r.write("Security ERROR")
        }
        return resp.finish
      end
			
			https_request = false
			if /\:443/.match(req.url())
			 https_request = true
			end
			
			params = req.params.collect { |k, v| "#{k}=#{v}&" }.join
			env['rack.errors'].write("Paramas: "+params+"\n")
      
      #this routes the request to the outgoing server incase its not html that we want to load
      type = check_for_route(env['REQUEST_URI'])
      if type == "control_panel"
        return control_panel.show()
      elsif type != "none" and type != "base64"
        control_panel.add_special_request "@forward_requests"
        return route(env, type)
      else        
        #Fetch the Webpage with PhantomJS
        phJS = PhantomJS.new
        
        env['rack.errors'].write("Extract the uri\n")
        
        picture,loadFrames = getOptions(env)
        
        url = prepareUrl(env, params, req, https_request, type)
        
        phJS.getUrl(url, picture, loadFrames)

        #Create the response
        if phJS.ready != 200
          if !/favicon\.ico/.match(req.url())
            env['rack.errors'].write("Request FAILED\n")
            control_panel.add_special_request "@failed_requests"
          else
            control_panel.add_special_request "@favicon_requests"
          end
          resp = Rack::Response.new([], phJS.ready > 0 ? phJS.ready : 404 ,  {
                                                  'Content-Type' => 'text/html'
                                              }) { |r|
            r.write(phJS.dom)
          }
          resp.finish
        elsif picture
          control_panel.add_special_request "@image_requests"
          resp = Rack::Response.new([], 200,  {
                                                  'Content-Type' => 'image/png'
                                              }) { |r|
            r.write(phJS.image)
          }
          resp.finish
        else
          control_panel.add_special_request "@html_requests"
          resp = Rack::Response.new([], 200,  {
                                                  'Content-Type' => 'text/html'
                                              }) { |r|
            r.write(phJS.dom)
          }
          resp.finish
        end
      end
		end
	end
end
