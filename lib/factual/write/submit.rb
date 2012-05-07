require 'factual/write/base'

class Factual
  module Write
    class Submit < Base
      VALID_KEYS = [
        :table, :user,
        :factual_id, :values,
        :comment, :reference
      ]

      def initialize(api, params)
        validate_params(params)
        super(api, params)
      end

      VALID_KEYS.each do |key|
        define_method(key) do |*args|
          Submit.new(@api, @params.merge(key => form_value(args)))
        end
      end

      def path
        if @params[:factual_id]
          "/t/#{@params[:table]}/#{@params[:factual_id]}/submit"
        else
          "/t/#{@params[:table]}/submit"
        end
      end

      private

      def validate_params(params)
        params.keys.each do |key|
          raise "Invalid submit option: #{key}" unless VALID_KEYS.include?(key)
        end
      end
    end
  end
end
