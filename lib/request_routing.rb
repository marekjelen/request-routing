module ActionController
  module Routing
    class Route
      
      TESTABLE_REQUEST_METHODS = [:subdomain, :domain, :method, :port, :remote_ip, 
        :content_type, :accepts, :request_uri, :protocol, :param]
      
      def recognition_conditions
        result = ["(match = #{Regexp.new(recognition_pattern).inspect}.match(path))"]
        conditions.each do |method, value|
          if method == :param
            result << if value[1].is_a? Regexp
              "#{value[1].inspect} =~ env['param_#{value[0].to_s}']"
            else
              "#{value[1].inspect} === env['param_#{value[0].to_s}']"
            end
          elsif method == :params
            value.each do |p,v|
              result << if v.is_a? Regexp
                "#{v.inspect} =~ env['param_#{p.to_s}']"
              else
                "#{v.inspect} === env['param_#{p.to_s}']"
              end
            end
          elsif method == :nparam
            result << if value[1].is_a? Regexp
              "!(#{value[1].inspect} =~ env['param_#{value[0].to_s}'])"
            else
              "!(#{value[1].inspect} === env['param_#{value[0].to_s}'])"
            end
          elsif method == :nparams
            value.each do |p,v|
              result << if v.is_a? Regexp
                "!(#{v.inspect} =~ env['param_#{p.to_s}'])"
              else
                "!(#{v.inspect} === env['param_#{p.to_s}'])"
              end
            end
          elsif TESTABLE_REQUEST_METHODS.include? method
            result << if value.is_a? Regexp
              "conditions[#{method.inspect}] =~ env[#{method.inspect}]"
            else
              "conditions[#{method.inspect}] === env[#{method.inspect}]"
            end
          else
          end
        end
        result
      end
      
    end
    
    class RouteSet
      
      def extract_request_environment(request)
        env = {
          :method => request.method,
          :subdomain => request.subdomains.first.to_s, 
          :domain => request.domain, 
          :port => request.port, 
          :remote_ip => request.remote_ip, 
          :content_type => request.content_type, 
          :accepts => request.accepts.map(&:to_s).join(','), 
          :request_uri => request.request_uri, 
          :protocol => request.protocol
        }
        request.params.each do |name, value|
          env["param_#{name}"] = value
        end
        return env
      end
      
    end
  end
end