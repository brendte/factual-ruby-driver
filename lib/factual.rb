require 'oauth'
require 'factual/api'
require 'factual/query/table'
require 'factual/query/facets'
require 'factual/query/resolve'
require 'factual/query/crosswalk'
require 'factual/flag'

class Factual
  def initialize(key, secret, options = {})
    debug_mode = options[:debug].nil? ? false : options[:debug]
    @api = API.new(generate_token(key, secret), debug_mode)
  end

  def table(table_id_or_alias)
    Query::Table.new(@api, "t/#{table_id_or_alias}")
  end

  def facets(table_id_or_alias)
    Query::Facets.new(@api, "t/#{table_id_or_alias}")
  end

  def crosswalk(namespace_id, namespace = nil)
    if namespace
      Query::Crosswalk.new(@api, :namespace_id => namespace_id, :namespace => namespace)
    else
      Query::Crosswalk.new(@api, :factual_id => namespace_id)
    end
  end

  def resolve(values)
    Query::Resolve.new(@api, :values => values)
  end

  def read(path)
    @api.raw_read(path)
  end

  def flag(table, factual_id, problem, user)
    flag_params = {
      :table => table,
      :factual_id => factual_id,
      :problem => problem,
      :user => user }
    Flag.new(@api, flag_params)
  end

  private

  def generate_token(key, secret)
    OAuth::AccessToken.new(OAuth::Consumer.new(key, secret))
  end
end
