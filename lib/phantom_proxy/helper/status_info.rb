module PhantomProxy
  module StatusInfo
    def self.boot_up
      @start_time=Time.now
    end
    boot_up
    
    def self.uptime
      Time.now-@start_time
    end
    def self.cache_hit
      @cache_hit||=0
    end
    def self.cache_hit=(obj)
      @cache_hit=obj
    end
    def self.cache_miss
      @cache_miss||=0
    end
    def self.cache_miss=(obj)
      @cache_miss=obj
    end
    def self.cache_error
      @cache_error||=0
    end
    def self.cache_error=(obj)
      @cache_error=obj
    end
    def self.cache_access
      @cache_access||=0
    end
    def self.cache_access=(obj)
      @cache_access=obj
    end
    def self.connections
      @connections||=0
    end
    def self.connections=(obj)
      @connections=obj
    end
  end
end
