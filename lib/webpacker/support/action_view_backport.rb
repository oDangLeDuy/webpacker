module ActionView
  module Helpers
    def compute_asset_host(source = "", options = {})
      request = self.request if respond_to?(:request)
      host = options[:host]
      host ||= config.asset_host if defined? config.asset_host

      if host
        if host.respond_to?(:call)
          arity = host.respond_to?(:arity) ? host.arity : host.method(:call).arity
          args = [source]
          args << request if request && (arity > 1 || arity < 0)
          host = host.call(*args)
        elsif host.include?("%d")
          host = host % (Zlib.crc32(source) % 4)
        end
      end

      host ||= request.base_url if request && options[:protocol] == :request
      return unless host

      if URI_REGEXP.match?(host)
        host
      else
        protocol = options[:protocol] || config.default_asset_host_protocol || (request ? :request : :relative)
        case protocol
        when :relative
          "//#{host}"
        when :request
          "#{request.protocol}#{host}"
        else
          "#{protocol}://#{host}"
        end
      end
    end
  end
end
