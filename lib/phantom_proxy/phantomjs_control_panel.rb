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
      info_data = ""
      info_data << create_entry("Running since", start_time.ctime)
      info_data << create_entry("Total requests", total_requests.to_s)
      special_requests.each { |key, value|
        info_data << create_entry(key, special_requests[key].to_s)
      }
      html["@control_panel_data"] = info_data
      
      html
    end
    
    def create_entry name, value
      "<div class='name'>#{name}:</div><div class='value' id='#{name}'>#{value}</div><div class='divider'></div>"
    end
  end
end