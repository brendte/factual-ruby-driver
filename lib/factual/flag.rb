class Factual
  class Flag
    PROBLEMS = [:duplicate, :nonexistent, :inaccurate, :inappropriate, :spam, :other]
    VALID_KEYS = [:table, :factual_id, :problem, :user, :comment, :debug, :reference]

    def initialize(api, params)
      validate_params(params)
      @api = api
      @params = params
    end

    VALID_KEYS.each do |key|
      define_method(key) do |*args|
        Flag.new(@api, @params.merge(key => form_value(args)))
      end
    end

    def path
      "/t/#{@params[:table]}/#{@params[:factual_id]}/flag"
    end

    def body
      @params.keys.map { |key| "#{key}=#{@params[key]}" }.join("&")
    end

    def write
      @api.post(self)
    end

    private

    def form_value(args)
      args = args.map { |arg| arg.is_a?(String) ? arg.strip : arg }
      args.length == 1 ? args.first : args.join(',')
    end

    def validate_params(params)
      params.keys.each do |key|
        raise "Invalid flag option: #{key}" unless VALID_KEYS.include?(key)
      end

      unless PROBLEMS.include?(params[:problem])
        raise "Flag problem should be one of the following: #{PROBLEMS.join(", ")}"
      end
    end
  end
end
