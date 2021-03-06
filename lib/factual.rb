require 'oauth'
require 'factual/api'
require 'factual/query/table'
require 'factual/query/resolve'
require 'factual/query/crosswalk'

class Factual
  def initialize(key, secret, debug_mode = false)
    @api = API.new(generate_token(key, secret), debug_mode)
  end

  def table(table_id_or_alias)
    Query::Table.new(@api, "t/#{table_id_or_alias}")
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

  private

  def generate_token(key, secret)
    OAuth::AccessToken.new(OAuth::Consumer.new(key, secret))
  end
end
