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
