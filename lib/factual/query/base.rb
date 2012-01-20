class Factual
  module Query
    class Base
      include Enumerable

      def initialize(api, params)
        @api = api
        @params = params
      end

      attr_reader :action, :path, :params

      def each(&block)
        rows.each { |row| block.call(row) }
      end

      def last
        rows.last
      end

      def [](index)
        rows[index]
      end

      def rows
        response["data"]
      end

      def total_rows
        response["total_row_count"]
      end

      def schema
        @schema ||= @api.schema(self)
      end

      private

      def form_value(args)
        args = args.map { |arg| arg.is_a?(String) ? arg.strip : arg }
        args.length == 1 ? args.first : args.join(',')
      end

      def response
        @response ||= @api.execute(self)
      end
    end
  end
end
