require 'factual/query/base'

class Factual
  module Query
    class Crosswalk < Base
      def initialize(api, params = {})
        @path = "places/crosswalk"
        @action = :crosswalk
        super(api, params)
      end

      [:factual_id, :only, :limit, :include_count].each do |param|
        define_method(param) do |*args|
          self.class.new(@api, @params.merge(param => form_value(args)))
        end
      end
    end
  end
end
