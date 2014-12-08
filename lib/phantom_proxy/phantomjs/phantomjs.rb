require 'tempfile'

module PhantomProxy
  class PhantomJS
    attr_accessor :dom
    attr_accessor :image
    attr_accessor :ready

    include ::PhantomProxy::Logable
  
    def initialize()
      @ready = 503
    end
    
    def getUrl(url, pictureOnly=true, loadIFrames=true)
      logger.info("PhantomJS: "+url)
      @ready = 503
      
      pictureFile = nil
      picture = "none"
      
      loadFrames = "false"
      
      if loadIFrames
        loadFrames = "true"
      end
      
      if pictureOnly
        pictureFile = Tempfile.new(["phantom_proxy_page", ".png"])
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
      
      @dom = invokePhantomJS(PhantomProxy.script_path, [picture, loadFrames, "\""+url+"\"", url_args_.length, url_args])
      
      # logger.info("Opened page: "+ /Open page: (.*?) END/.match(@dom)[1])
      
      @ready = 503
      dom_text = "Failed to load page"
      
      if /DONE_LOADING_URL/.match(@dom)
        logger.info("LOAD_DOM_TEXT")
        dom_text = getDOMText @dom
        logger.info("LOAD_DOM_TEXT_DONE")
        if pictureOnly && File.exist?(picture) 
          logger.info("File is there")
          @image = File.open(picture, "rb")# {|f| f.read }
          pictureFile.close!
        else
          logger.info("No file to load at: "+picture)
          @image = ""
        end
        @ready = 200
      end
      if /URL_ERROR_CODE/.match(@dom)
        logger.info("LOAD_ERROR_CODE")
        @ready = getHTTPCode @dom
        logger.info("LOAD_ERROR_CODE_DONE: #{@ready}")
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
      tmp = data.split('URL_ERROR_CODE: ')[1];
      tmp = tmp.split('URL_ERROR_CODE_END')[0]
      #tmp = /FAILED_LOADING_URL: (.*?)FAILED_LOADING_URL_END/.match(data)[1]
      tmp.to_i
    end
    
    def getAsImageResponse(type='png')
      return "HTTP/1.0 200 OK\r\nConnection: close\r\nContent-Type: image/"+type+"\r\n\r\n"+@image;
    end
  
    def invokePhantomJS(script, args)
      argString = " "+args.join(" ")
      logger.info("Call phantomJS with: "+argString)
      out = ""

      IO.popen(PhantomProxy.phantomjs_bin+" --ignore-ssl-errors=yes --web-security=false "+script+argString) {|io|
        out = io.readlines.join
      }
      #logger.info("PHANTOMJS_OUT: "+out)
      return out
    end
  end
end
