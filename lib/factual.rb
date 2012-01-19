require 'oauth'
require 'factual/api'
require 'factual/query'

class Factual
  def initialize(key, secret)
    @api = Factual::API.new(generate_token(key, secret))
  end

  def crosswalk(factual_id)
    Query.new(@api, :crosswalk, "places/crosswalk", :factual_id => factual_id)
  end

  def resolve(values)
    Query.new(@api, :resolve, "places/resolve", :values => values)
  end

  def table(table_id_or_alias)
    Query.new(@api, :read, "t/#{table_id_or_alias}")
  end

  private

  def generate_token(key, secret)
    OAuth::AccessToken.new(OAuth::Consumer.new(key, secret))
  end
end
