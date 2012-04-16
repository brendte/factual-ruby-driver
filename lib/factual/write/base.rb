class Factual
  module Write
    class Base
      def initialize(api, params)
        @api = api
        @params = params
      end

      def path
        raise "Virtual method called"
      end

      def body
        keys = @params.keys.reject { |key| [:table, :factual_id].include?(key) }
        keys.map { |key| "#{key}=#{CGI.escape(stringify(@params[key]))}" }.join("&")
      end

      def write
        @api.post(self)
      end

      private

      def stringify(value)
        value.class == Hash ? value.to_json : value.to_s
      end

      def form_value(args)
        args = args.map { |arg| arg.is_a?(String) ? arg.strip : arg }
        args.length == 1 ? args.first : args.join(',')
      end
    end
  end
end
