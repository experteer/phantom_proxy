module PhantomProxy
  class ProxyApi < AppRouterBase
    get "/favicon.ico", :next_api
    get "/*path", :handle_proxy_request
    get "/", :handle_proxy_request

    put "*any", :next_api
    delete "*any", :next_api
    head "*any", :next_api
    post "*any", :next_api

    private
      def handle_proxy_request
        return Http.NotAuthorized unless !PhantomProxy.hmac_key || check_request_security
        phJS = PhantomJS.new
        PhantomProxy.wait_for(lambda {
          phJS.getUrl(canonical_url, as_image?, iframes?)
        })
        return image_response(phJS) if as_image?
        html_response(phJS)
      end

      def html_response(phJS)
        [phJS.ready > 0 ? phJS.ready : 404 , {'Content-Type' => 'text/html'}, phJS.dom]
      end

      def image_response(phJS)
        [200 , {'Content-Type' => 'image/png'}, phJS.image]
      end

      def host
        if https?
          env['SERVER_NAME']
        else
          env['HTTP_HOST']
        end
      end

      def path
        env[nil] ? env[nil][:path] : ""
      end

      def iframes?
        env["HTTP_GET_PAGE_WITH_IFRAMES"] == "true" || PhantomProxy.always_iframe?
      end

      def as_image?
        env["HTTP_GET_PAGE_AS_IMAGE"] == "true" || PhantomProxy.always_image?
      end

      def https?
        env["SERVER_PORT"] == "443"
      end

      def protocoll
        https? ? "https" : "http"
      end

      def canonical_path
        ["#{protocoll}://#{host}",path].join("/")
      end

      def canonical_url
        [canonical_path, env["params"] ? env["params"].map{|k,v| "#{k}=#{v}"}.join('&') : nil].join("?")
      end

      def check_request_security
        if !hmac_hash || !hmac_time
          return false
        end
        
        client_time= Time.parse(hmac_time)
        remote_time= Time.now
        remote_key = PhantomProxy.hmac_key.update(env['REQUEST_URI']+env['HTTP_HMAC_TIME']).hexdigest

        if (hmac_hash != remote_key || (remote_time-client_time).abs > 120)
          # control_panel.add_special_request "@did not pass security check"
          logger.info "@did not pass security check"
          return false
        end
        return true
      end

      def hmac_hash
        env['HTTP_HMAC_KEY']
      end
      def hmac_time
        env['HTTP_HMAC_TIME']
      end
  end
end
