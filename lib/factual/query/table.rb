require 'factual/query/base'

class Factual
  module Query
    class Table < Base
      DEFAULT_LIMIT = 20

      def initialize(api, path, params = {})
        @path = path
        @action = :read
        super(api, params)
      end

      [:filters, :search, :geo, :sort, :select, :limit, :offset, :include_count].each do |param|
        define_method(param) do |*args|
          Table.new(@api, @path, @params.merge(param => form_value(args)))
        end
      end

      def sort_desc(*args)
        columns = args.map { |column| "#{column}:desc" }
        Table.new(@api, @path, @params.merge(:sort => columns.join(',')))
      end

      def page(page_number, paging_options = {})
        limit = (paging_options[:per] || paging_options["per"] || DEFAULT_LIMIT).to_i
        limit = DEFAULT_LIMIT if limit < 1

        page_number = page_number.to_i
        page_number = 1 if page_number < 1

        offset = (page_number - 1) * limit
        Table.new(@api, @path, @params.merge(:limit => limit, :offset => offset))
      end
    end
  end
end
