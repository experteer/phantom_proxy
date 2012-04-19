require 'net/http'

module PhantomJSProxy
	class PhantomJSServer
		def initialize()
		  @control_panel = PhantomJSProxy::PhantomJSControlPanel.new
		end
		
		attr_accessor :control_panel
    
    def check_for_route(url)
      if /\.js/i.match(url)
        return 'text/html';
      end
      if /\.css/i.match(url)
        return 'text/css'
      end
      if /\.png/i.match(url) or /\.jpg/i.match(url) or /\.jpeg/i.match(url) or /\.gif/i.match(url)
        return 'image/*';
      end
      if /phantom_proxy_control_panel/.match(url)
        return 'control_panel'
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
      
      env['rack.errors'].write("Response is:"+_res.body+"\n")
      
      resp = Rack::Response.new([], 200, 	{'Content-Type' => type}) { |r|
        r.write(_res.body)
      }
      resp.finish
    end
    
		def call(env)
		  control_panel.add_request
		  
			req = Rack::Request.new(env)
			
			haha = env.collect { |k, v| "#{k} : #{v}\n" }.join
			env['rack.errors'].write("The request: "+req.url()+"\nGET: "+haha+"\n")
			
			params = req.params.collect { |k, v| "#{k}=#{v}&\n" }.join
			env['rack.errors'].write("Paramas: "+params+"\n")
      
      #this routes the request to the outgoing server incase its not html that we want to load
      type = check_for_route(env['REQUEST_URI'])
      if type == "control_panel"
        return control_panel.show()
      elsif type != "none"
        control_panel.add_special_request "@forward_requests"
        return route(env, type)
      else        
        #Fetch the Webpage with PhantomJS
        phJS = PhantomJS.new
        
        env['rack.errors'].write("Extract the uri\n")
        
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
        
        url = env['REQUEST_URI'];
        if params.length > 0
          url += '?'+params;
        end
        
        phJS.getUrl(url, picture, loadFrames)
          
        #Create the response
        if !phJS.ready
          if !/favicon\.ico/.match(req.url())
            env['rack.errors'].write("Request FAILED\n")
            control_panel.add_special_request "@failed_requests"
          else
            control_panel.add_special_request "@favicon_requests"
          end
          resp = Rack::Response.new([], 503,  {
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
