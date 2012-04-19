module PhantomJSProxy
  class PhantomJSControlPanel
    def initialize
      @start_time = Time.new
      @total_requests = 0
      @special_requests = Hash.new
      @special_requests.default = 0
    end

    attr_accessor :start_time
    
    attr_accessor :total_requests
    attr_accessor :route_requests
    attr_accessor :html_requests
    attr_accessor :picture_requests
    attr_accessor :special_requests
    
    def show
      add_special_request "@control_requests"
      
      resp = Rack::Response.new([], 200,   {
        'Content-Type' => 'text/html'
        }) { |r|
          r.write(load_html)
        }
      resp.finish
    end
    
    def add_request
      @total_requests = @total_requests+1
    end
    
    def add_special_request type
      @special_requests[type] = @special_requests[type]+1
    end
    
    private
    def load_html
      insert_value IO.read(CONTROL_PANEL)
    end
    
    def insert_value html
      html["@start_time"] = start_time.ctime
      html["@total_requests"] = total_requests.to_s
      html["@html_requests"] = special_requests["@html_requests"].to_s
      html["@image_requests"] = special_requests["@image_requests"].to_s
      html["@forward_requests"] = special_requests["@forward_requests"].to_s
      html["@control_requests"] = special_requests["@control_requests"].to_s
      html["@failed_requests"] = special_requests["@failed_requests"].to_s
      html["@favicon_requests"] = special_requests["@favicon_requests"].to_s
      #special_requests.each { |key, value|
      #  html[key] = value.to_s
      #}
      
      html
    end
  end
end