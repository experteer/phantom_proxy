module PhantomProxy
  class StatusApi < AppRouterBase
    get "/phantom_proxy_control_panel(.:format)", :status_page

    get "*any", :next_api
    put "*any", :next_api
    delete "*any", :next_api
    head "*any", :next_api
    post "*any", :next_api

    json_var :uptime

    private
      def status_page
        case format
        when :json
          render_json
        when :xml
          render_xml
        else
          render "status_page"
        end
      end

      def name
        "Data"
      end
      def value
        @value||="none"
      end
      def uptime
        logger.info "Call Uptime"
        @uptime||=StatusInfo.uptime
      end
      def format
        if env[nil] && env[nil][:format]
          env[nil][:format].to_sym
        else
          :html
        end
      end
  end
end
