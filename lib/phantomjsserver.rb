module PhantomJSProxy
	class PhantomJSServer
		def initialize()
		end
		def call(env)
			req = Rack::Request.new(env)
			
			haha = env.collect { |k, v| "#{k} : #{v}\n" }.join
			env['rack.errors'].write("The request: "+req.url()+"\nGET: "+haha+"\n")
			
			params = req.params.collect { |k, v| "#{k}=#{v}&\n" }.join
			env['rack.errors'].write("Paramas: "+params+"\n")
			
				
			# Fetch the Webpage with PhantomJS
			phJS = PhantomJS.new
			
			env['rack.errors'].write("Extract the uri\n")
			
			picture = env['HTTP_GET_PAGE_AS_IMAGE']
			
			loadFrames = env['HTTP_GET_PAGE_WITH_IFRAMES']
			
			phJS.getUrl(env['REQUEST_URI']+'?'+params, picture, loadFrames)
				
			#Create the response
			if !phJS.ready
				resp = Rack::Response.new([], 503, 	{
																								'Content-Type' => 'text/html'
																						}) { |r|
					r.write(phJS.dom)
				}
				resp.finish
			elsif picture
				resp = Rack::Response.new([], 200, 	{
																								'Content-Type' => 'image/png'
																						}) { |r|
					r.write(phJS.image)
				}
				resp.finish
			else
				resp = Rack::Response.new([], 200, 	{
																								'Content-Type' => 'text/html'
																						}) { |r|
					r.write(phJS.dom)
				}
				resp.finish
			end
		end
	end
end
