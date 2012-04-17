require 'factual/write/base'

class Factual
  module Write
    class Contribute < Base
      VALID_KEYS = [:table, :user, :factual_id, :values]

      def initialize(api, params)
        validate_params(params)
        super(api, params)
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

      private

      def validate_params(params)
        params.keys.each do |key|
          raise "Invalid contribute option: #{key}" unless VALID_KEYS.include?(key)
        end
      end
    end
  end
end
