require 'factual/query'

module Factual
  module Query
    class Crosswalk < Factual::Query
      def initialize(api, params = {})
        @path = "places/crosswalk"
        @action = :crosswalk
        super(api, params)
      end

      [:factual_id, :include_count].each do |param|
        define_method(param) do |*args|
          CrossWalk.new(@api, @params.merge(param => form_value(args)))
        end
      end
    end
  end
end
