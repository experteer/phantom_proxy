module PhantomProxy2
  class Service < Goliath::API
    use Goliath::Rack::Params

    def response(env)
      env["params"] = params
      call_stack(env, StatusApi, ProxyApi)
    end

    def call_stack(env, *apis)
      last_answer = [404,{}, ""]
      apis.each do |api|
        last_answer = api.call(env)
        if last_answer[0] != 600
          return last_answer
        end
      end
      last_answer[0] != 600 ? last_answer : [404,{}, ""]
    end
  end
end
