module PhantomJSProxy
  class PhantomJSControlPanel
    def initialize
      @start_time = Time.new
      @total_requests = 0
    end

    attr_accessor :start_time
    
    attr_accessor :total_requests
    attr_accessor :route_requests
    attr_accessor :html_requests
    attr_accessor :picture_requests
    
    def show
      resp = Rack::Response.new([], 200,   {
        'Content-Type' => 'text/html'
        }) { |r|
          r.write(load_html)
        }
      resp.finish
    end
    
    def add_request
      total_requests += 1
    end
    
    private
    def load_html
      insert_value IO.read(CONTROL_PANEL)
    end
    
    def insert_value html
      html["@start_time"] = start_time.ctime
      html["@total_requests"] = total_requests.to_s
      html
    end
  end
end