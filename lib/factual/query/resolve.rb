require 'factual/query'

module Factual
  module Query
    class Resolve < Factual::Query
      def initialize(api, params = {})
        @path = "places/resolve"
        @action = :resolve
        super(api, params)
      end

      [:values, :include_count].each do |param|
        define_method(param) do |*args|
          Resolve.new(@api, @params.merge(param => form_value(args)))
        end
      end
    end
  end
end
