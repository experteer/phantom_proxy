require 'tempfile'

module PhantomJSProxy
	class PhantomJS
		attr_accessor :dom
		attr_accessor :image
		attr_accessor :ready
	
		def initialize()
			@ready = false
		end
		
		def getUrl(url, pictureOnly=true, loadIFrames=true)
			puts("PhantomJS: "+url)
			@ready = false
			
			pictureFile = nil
			picture = "none"
      
      loadFrames = "false"
      
      if loadIFrames
        loadFrames = "true"
      end
			
			if pictureOnly
				if !File.directory?("/tmp/phantomjs_proxy")
					Dir.mkdir("/tmp/phantomjs_proxy")
				end
				pictureFile = Tempfile.new(["phantomjs_proxy/page", ".png"])
				picture = pictureFile.path
			end
			
			url_args = ""
			
			if /\?/.match(url)
				url_args = url.split('?')[1]
				url = url.split('?')[0]
				
				if url_args
					url_args = url_args.split('&')
					url_args = url_args.join(' ')
				end
			end
			
			@dom = invokePhantomJS(SCRIPT, [picture, loadFrames, url, url_args])
			
			puts("Opened page: "+ /Open page: (.*?) END/.match(@dom)[1])
			
			if /DONE_LOADING_URL/.match(@dom)
				@dom = @dom.split('PHANTOMJS_DOMDATA_WRITE:')[1];
				@dom = @dom.split('PHANTOMJS_DOMDATA_END')[0]
				if pictureOnly && File.exist?(picture) 
					puts("File is there")
					@image = IO::File.open(picture, "rb") {|f| f.read }
					pictureFile.close!
				else
					puts("No file to load at: "+picture)
					@image = ""
				end
				@ready = true
			else
				@dom = "Failed to load page"
				puts("TOTAL FAIL")
			end
			puts("Return dom")
			return @dom
		end
		
		def getAsImageResponse(type='png')
			return "HTTP/1.0 200 OK\r\nConnection: close\r\nContent-Type: image/"+type+"\r\n\r\n"+@image;
		end
	
		def invokePhantomJS(script, args)
			argString = " "+args.join(" ")
			puts("Call phantomJS with: "+argString)
			out = IO.popen(PHANTOMJS_BIN+" --cookies-file=/tmp/phantomjs_proxy/cookies.txt "+script+argString)
			o = out.readlines.join
      puts("PHANTOMJS_OUT: "+o)
			return o
		end
	end
end
