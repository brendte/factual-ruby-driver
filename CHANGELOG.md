## v1.0.2
* lazy getting total_count of a query
* changed Query#total_rows to Query#total_count to be consistent

## v1.0.1
* fixed url escape for .filters(:category => "Food & Beverage > Restaurants")

## v1.0.0
* fully documented
* crosswalk(<factual_id>).only('yelp')

## v0.5
* big refactoring from Rudy
* ready for releasing

## v0.3
* return hash instead of objects
* removing facets
* a little refactoring

## v0.2
* refactoring

## v0.1
* initial version
** a table agnostic read api, usage as: api.table(table_alias).rows
** normal (but powerful) filters, usage as: api.table(:global).filters(:country => {'$sw' => 'u'}, :region => 'ca')
** general mapping of ALL v3 api params, e.g. geo, query, sort, select, limit, offset
** places sugers, usage as: api.crosswalk(FACTUAL_ID); api.resolve(:name => 'factual inc.', :region => 'ca')
** facets
** different format, usage as: json_api = Factual::Api.new( KEY, SECRET, :json)
** immutable api objects
