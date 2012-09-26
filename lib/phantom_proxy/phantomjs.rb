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
				if !File.directory?("/tmp/phantom_proxy")
					Dir.mkdir("/tmp/phantom_proxy")
				end
				pictureFile = Tempfile.new(["phantom_proxy/page", ".png"])
				picture = pictureFile.path
			end
			
			url_args = ""
			url_args_ = []
      
			if /\?/.match(url)
				url_args = url.split('?')[1]
				url = url.split('?')[0]
				
				if url_args
					url_args_ = url_args.split('&')
					url_args = url_args_.join(' ')
				end
			end
			
			@dom = invokePhantomJS(SCRIPT, [picture, loadFrames, url, url_args_.length, url_args])
			
			puts("Opened page: "+ /Open page: (.*?) END/.match(@dom)[1])
			
			@ready = 503
			dom_text = "Failed to load page"
			
			if /DONE_LOADING_URL/.match(@dom)
        puts("LOAD_DOM_TEXT")
				dom_text = getDOMText @dom
        puts("LOAD_DOM_TEXT_DONE")
				if pictureOnly && File.exist?(picture) 
					puts("File is there")
					@image = IO::File.open(picture, "rb") {|f| f.read }
					pictureFile.close!
				else
					puts("No file to load at: "+picture)
					@image = ""
				end
				@ready = 200
			end
			if /FAILED_LOADING_URL/.match(@dom)
        puts("LOAD_ERROR_CODE")
			  @ready = getHTTPCode @dom
        puts("LOAD_ERROR_CODE_DONE")
			end
			@dom = dom_text
			return @dom
		end
		
		def getDOMText data
		  tmp = data.split('PHANTOMJS_DOMDATA_WRITE:')[1];
		  tmp = tmp.split('PHANTOMJS_DOMDATA_END')[0]
		  tmp
		end
		
		def getHTTPCode data
		  tmp = data.split('FAILED_LOADING_URL:')[1];
      tmp = tmp.split('FAILED_LOADING_URL_END')[0]
		  #tmp = /FAILED_LOADING_URL: (.*?)FAILED_LOADING_URL_END/.match(data)[1]
		  tmp.to_i
		end
		
		def getAsImageResponse(type='png')
			return "HTTP/1.0 200 OK\r\nConnection: close\r\nContent-Type: image/"+type+"\r\n\r\n"+@image;
		end
	
		def invokePhantomJS(script, args)
			argString = " "+args.join(" ")
			puts("Call phantomJS with: "+argString)
			out = ""
			IO.popen(PHANTOMJS_BIN+" --cookies-file=/tmp/phantom_proxy/cookies.txt "+script+argString) {|io|
			  out = io.readlines.join
			}
      #puts("PHANTOMJS_OUT: "+out)
			return out
		end
	end
end
