class Factual
  class Contribute
    VALID_KEYS = [:table, :user, :factual_id, :values]

    def initialize(api, params)
      validate_params(params)
      @api = api
      @params = params
    end

    VALID_KEYS.each do |key|
      define_method(key) do |*args|
        Contribute.new(@api, @params.merge(key => form_value(args)))
      end
    end

    def path
      if @params[:factual_id]
        "/t/#{@params[:table]}/#{@params[:factual_id]}/contribute"
      else
        "/t/#{@params[:table]}/contribute"
      end
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

    def validate_params(params)
      params.keys.each do |key|
        raise "Invalid contribute option: #{key}" unless VALID_KEYS.include?(key)
      end
    end
  end
end
