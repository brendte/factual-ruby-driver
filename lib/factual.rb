require 'oauth'
require 'factual/api'
require 'factual/query/table'
require 'factual/query/resolve'
require 'factual/query/crosswalk'

class Factual
  def initialize(key, secret)
    @api = API.new(generate_token(key, secret))
  end

  def table(table_id_or_alias)
    Query::Table.new(@api, "t/#{table_id_or_alias}")
  end

  def crosswalk(factual_id)
    Query::Crosswalk.new(@api, :factual_id => factual_id)
  end

  def resolve(values)
    Query::Resolve.new(@api, :values => values)
  end

  private

  def generate_token(key, secret)
    OAuth::AccessToken.new(OAuth::Consumer.new(key, secret))
  end
end
