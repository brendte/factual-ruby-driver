require 'test/unit'
require './lib/factual'
require './lib/factual/api'
require './lib/factual/query'

require File.expand_path(File.dirname(__FILE__)) + '/my_key_pair'

class ApiTest < Test::Unit::TestCase
  

  FACTUAL_ID = "03c26917-5d66-4de9-96bc-b13066173c65"
   
  def setup
    @api = Factual.new( FACTUAL_OAUTH_KEY, FACTUAL_OAUTH_SECRET )
  end

  def test_first
    # basic
    row = @api.table(:global).first
    assert_equal row["factual_id"].length, 36

    # search
    row = @api.table(:global).search('factual').first
    assert_match /Factual/, row["name"]

  end

  def test_sort
    row = @api.table(:global).sort(:country, :name).first
    assert_match /^100/, row["name"]
    row = @api.table(:global).sort(:name).first
    assert_match /^\!/, row["name"]

    row = @api.table(:global).sort_desc(:country, :name).first
    assert_match /^Z/, row["name"]
    row = @api.table(:global).sort_desc(:name).first
    assert_equal 'hk', row["country"]
  end

  def test_paging
    row = @api.table(:global).offset(10).limit(10).first
    assert_match /El Bunker/, row["name"]
    row = @api.table(:global).page(2, :per => 10).first
    assert_match /El Bunker/, row["name"]
  end

  def test_rows
    # basic
    query = @api.table(:global)
    rows = query.rows
    total_rows = query.total_rows
    assert (total_rows > 55_000_000)
    assert_equal rows.length, 20

    # search
    query = @api.table(:global).search('factual')
    query.rows.each do |row|
      assert_match /Factual/, row["name"] 
    end
  end

  def test_immutable
    query1 = @api.table(:global).search('factual')
    query2 = query1.filters(:locality => 'los angeles')

    assert_no_match /stars/i, query1.first["address"]
    assert_match /stars/i, query2.first["address"]
  end

  def test_format
    query = @api.table(:global)
    json  = query.first.to_json
    assert_equal json.class, String

    hash = query.first
    assert_equal hash.class, Hash
  end

  def test_crosswalk
    query = @api.crosswalk(FACTUAL_ID)

    assert_equal query.first["namespace"], 'facebook'
  end

  def test_resolve
    query = @api.resolve(:name => 'factual inc', :region => 'ca')

    assert query.first["resolved"]
    assert_match /stars/i, query.first["address"]
  end

  def test_schema
    schema = @api.table(:global).schema()
    assert_equal schema["fields"].length, 21
  end
end
