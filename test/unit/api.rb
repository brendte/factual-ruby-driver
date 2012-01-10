require 'test/unit'
require './lib/factual_api'
require File.expand_path(File.dirname(__FILE__)) + '/my_key_pair'

class ApiTest < Test::Unit::TestCase
  

  FACTUAL_ID = "03c26917-5d66-4de9-96bc-b13066173c65"
   
  def setup
    @api = Factual::Api.new( FACTUAL_OAUTH_KEY, FACTUAL_OAUTH_SECRET )
  end

  def test_first
    # basic
    row = @api.table(:global).first
    assert_equal row.factual_id.length, 36

    # search
    row = @api.table(:global).search('factual').first
    assert_match /Factual/, row.name 

  end

  def test_sort
    row = @api.table(:global).sort(:country, :name).first
    assert_match /^100/, row.name
    row = @api.table(:global).sort(:name).first
    assert_match /^\!/, row.name

    row = @api.table(:global).sort_desc(:country, :name).first
    assert_match /^Z/, row.name
    row = @api.table(:global).sort_desc(:name).first
    assert_equal 'hk', row.country
  end

  def test_paging
    row = @api.table(:global).offset(10).limit(10).first
    assert_equal 'Ciber 26', row.name
    row = @api.table(:global).page(2, :per => 10).first
    assert_equal 'Ciber 26', row.name
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
      assert_match /Factual/, row.name 
    end
  end

  def test_immutable
    query1 = @api.table(:global).search('factual')
    query2 = query1.filters(:locality => 'los angeles')

    assert_no_match /stars/i, query1.first.address
    assert_match /stars/i, query2.first.address
  end

  def test_format
    json_query = Factual::Api.new( FACTUAL_OAUTH_KEY, FACTUAL_OAUTH_SECRET, :json )
    assert_equal json_query.table(:global).first.class, Hash

    assert_equal @api.table(:global).first.class, Factual::Row
  end

  def test_crosswalk
    @api.crosswalk(FACTUAL_ID)

    assert_equal @api.first.namespace, 'facebook'
  end

  def test_resolve
    @api.resolve(:name => 'factual inc', :region => 'ca')

    assert @api.first.resolved
    assert_match /stars/i, @api.first.address
  end

  def test_facets
    query = @api.table(:global).select(:region, :locality).search('factual').min_count(2)
    assert_equal query.facets().region.length, 8
  end

  def test_schema
    schema = @api.table(:global).schema()
    assert_equal schema.fields.length, 21
  end
end
