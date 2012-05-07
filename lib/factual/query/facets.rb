require 'factual/query/base'

class Factual
  module Query
    class Facets < Base
      DEFAULT_LIMIT = 20
      VALID_PARAMS  = [
        :filters, :search, :geo, 
        :select, 
        :limit, :min_count,
        :include_count
      ] 

      def initialize(api, path, params = {})
        @path = path
        @action = :facets
        super(api, params)
      end

      VALID_PARAMS.each do |param|
        define_method(param) do |*args|
          Facets.new(@api, @path, @params.merge(param => form_value(args)))
        end
      end

      def each(&block)
        columns.each do |col, data|
          block.call(col, data)
        end
      end

      def [](col)
        columns[col]
      end

      def columns
        response["data"]
      end
    end
  end
end
