module Factual
  class Query
    include Enumerable

    DEFAULT_LIMIT = 20
    VALID_PARAMS = {
      :read      => [ :filters, :search, :geo, :sort, :select, :limit, :offset ],
      :resolve   => [ :values ],
      :crosswalk => [ :factual_id ],
      :schema    => [ ],
      :any       => [ :include_count ]
    }

    def initialize(api, action, path, params = {})
      @api = api
      @action = action
      @path = path
      @params = params
      @response = nil
      @schema = nil
      validate_params
    end

    # Attribute Readers
    [:action, :path, :params].each do |attribute|
      define_method(attribute) do
        instance_variable_get("@#{attribute}").clone
      end
    end

    # Response Methods
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
      (@response ||= @api.execute(self))["data"].clone
    end

    def total_rows
      (@response ||= @api.execute(self))["total_row_count"].clone
    end

    def schema
      (@schema ||= @api.schema(self)).clone
    end

    # Query Modifiers
    VALID_PARAMS.values.flatten.uniq.each do |param|
      define_method(param) do |*args|
        value = args.length == 1 ? args.first.strip : args.map(&:strip).join(',')

        new_params = @params.clone
        new_params[param] = value

        Query.new(@api, @action, @path, new_params)
      end
    end

    def sort_desc(*args)
      columns = args.map { |column| "#{column}:desc" }

      new_params = @params.clone
      new_params[:sort] = columns.join(',')

      Query.new(@api, @action, @path, new_params)
    end

    def page(page_number, paging_options = {})
      limit = (paging_options[:per] || paging_options["per"] || DEFAULT_LIMIT).to_i
      limit = DEFAULT_LIMIT if limit < 1

      page_number = page_number.to_i
      page_number = 1 if page_number < 1

      new_params = @params.clone
      new_params[:limit] = limit
      new_params[:offset] = (page_number - 1) * limit

      Query.new(@api, @action, @path, new_params)
    end

    private

    # Validations
    def validate_params
      @params.each do |param, val|
        unless (VALID_PARAMS[@action] + VALID_PARAMS[:any]).include?(param)
          raise StandardError.new("InvalidArgument #{param} for #{@action}")
        end
      end
    end
  end
end
