$LOAD_PATH << './lib'

require 'test/unit'
require 'factual'

require File.expand_path(File.dirname(__FILE__)) + '/my_key_pair'

class ApiTest < Test::Unit::TestCase
  

  FACTUAL_ID   = "110ace9f-80a7-47d3-9170-e9317624ebd9"
  SIMPLEGEO_ID = "SG_6XIEi3qehN44LH8m8i86v0"
   
  def setup
    @api = Factual.new( FACTUAL_OAUTH_KEY, FACTUAL_OAUTH_SECRET )
  end

  def test_select
    row = @api.table(:global).select(:name, :address).first
    assert_equal row.keys.length, 2
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
    row = @api.table(:global).sort_asc(:country, :name).first
    assert_match /^100/, row["name"]
    row = @api.table(:global).sort_asc(:name).first
    assert_match /^\!/, row["name"]

    row = @api.table(:global).sort_desc(:country, :name).first
    assert_match /^Z/, row["name"]
    row = @api.table(:global).sort_desc(:name).first
    assert_equal 'hk', row["country"]
  end

  def test_paging
    row = @api.table(:places).offset(10).limit(10).first
    assert_match /Tupelo/, row["name"]
    row = @api.table(:places).page(2, :per => 10).first
    assert_match /Tupelo/, row["name"]
  end

  def test_rows
    # basic
    query = @api.table(:global)
    rows = query.rows
    total_count = query.total_count
    assert (total_count > 55_000_000)
    assert_equal rows.length, 20

    # search
    query = @api.table(:global).search('factual')
    query.rows.each do |row|
      assert_match /Factual/, row["name"] 
    end
  end

  def test_filters
    query = @api.table(:places).filters(:category => "Food & Beverage > Restaurants")
    assert_equal query.first['name'], "Jessops Tavern"
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

  def test_geo
    query = @api.table(:global).geo("$circle" => {"$center" => [34.06021, -118.41828], "$meters" => 1003}).search('factual')
    assert_equal query.first["name"], "Factual"
  end

  def test_crosswalk
    query = @api.crosswalk(FACTUAL_ID)
    assert_equal query.rows.length, 20
    assert_equal query.first["namespace"], 'allmenus'

    query = query.limit(3)
    assert_equal query.rows.length, 3

    query = query.only(:yelp, :chow)
    assert_equal query.rows.length, 2
    assert_equal query.first['namespace'], 'chow'

    query = @api.crosswalk(SIMPLEGEO_ID, :simplegeo)
    assert_equal query.first['factual_id'], FACTUAL_ID

  end

  def test_resolve
    query = @api.resolve(:name => 'factual inc', :locality => 'los angeles')

    assert_equal query.first["resolved"], true
    assert_match /stars/i, query.first["address"]
  end

  def test_schema
    schema = @api.table(:global).schema()
    assert_equal schema["fields"].length, 22
  end
end
