# About

This is the Factual supported Ruby driver for [Factual's public API](http://developer.factual.com/display/docs/Factual+Developer+APIs+Version+3).

This API supports queries to Factual's Read, Schema, Crosswalk, and Resolve APIs. Full documentation is available on the Factual website:

*   [Read](http://developer.factual.com/display/docs/Factual+Developer+APIs+Version+3): Search the data
*   [Schema](http://developer.factual.com/display/docs/Core+API+-+Schema): Get table metadata
*   [Crosswalk](http://developer.factual.com/display/docs/Places+API+-+Crosswalk): Get third-party IDs
*   [Resolve](http://developer.factual.com/display/docs/Places+API+-+Resolve): Enrich your data and match it against Factual's
*   [Facets](http://wiki.corp.factual.com/display/DOCS/Core+API+-+Facets): Get facets of the data

This driver is supported via the [Factual Developer Group](https://groups.google.com/group/factual_developers)

# Overview

## Basic Design

The driver allows you to create an authenticated handle to Factual. With a Factual handle, you can send queries and get results back.

Queries are created using the Factual handle, which provides a fluent interface to constructing your queries. 

````ruby
# You can chain the query methods, like this:
factual.table("places").filters("category" => "Food & Beverage > Restaurants").search("sushi", "sashimi")
  .geo("$circle" => {"$center" => [34.06021, -118.41828], "$meters" => 5000})
  .sort("name").page(2, :per => 10)
````

Results are returned as Ruby Arrays of Hashes, where each Hash is a result record.

## Setup

The driver's gems are hosted at [Rubygems.org](http://rubygems.org). You can install the factual-api gem as follows:

`````bash
$ gem install factual-api
`````

Once the gem is installed, you can use it in your Ruby project like:

````ruby
require 'factual'
factual = Factual.new("YOUR_KEY", "YOUR_SECRET")
````
  
## Simple Read Examples

`````ruby
# Return entities from the Places dataset with names beginning with "starbucks"
factual.table("places").filters("name" => {"$bw" => "starbucks"}).rows
````

`````ruby
# Return entity names and non-blank websites from the Global dataset, for entities located in Thailand
factual.table("global").select(:name, :website)
  .filters({"country" => "TH", "website" => {"$blank" => false}})
````

`````ruby
# Return highly rated U.S. restaurants in Los Angeles with WiFi
factual.table("restaurants-us")
  .filters({"locality" => "los angeles", "rating" => {"$gte" => 4}, "wifi" => true}).rows
````

## Simple Crosswalk Example

````ruby
# Concordance information of a place
FACTUAL_ID = "110ace9f-80a7-47d3-9170-e9317624ebd9"
query = factual.crosswalk(FACTUAL_ID)
query.rows

# Or specify a place with its namespace_id and namespace
SIMPLEGEO_ID = "SG_6XIEi3qehN44LH8m8i86v0"
query = factual.crosswalk(SIMPLEGEO_ID, :simplegeo)
query.rows
````

## Simple Resolve Example

````ruby
# Returns resolved entities as an array of hashes
query = factual.resolve("name" => "McDonalds",
                        "address" => "10451 Santa Monica Blvd",
                        "region" => "CA",
                        "postcode" => "90025")

query.first["resolved"]   # true or false
query.rows                # all candidate rows
````

## More Read Examples

````ruby
# 1. Specify the table Global
query = factual.table("global")
````

````ruby
# 2. Filter results in country US
query = query.filters("country" => "US")
````

````ruby
# 3. Search for "sushi" or "sashimi"
query = query.search("sushi", "sashimi")
````

````ruby
# 4. Filter by geolocation
query = query.geo("$circle" => {"$center" => [34.06021, -118.41828], "$meters" => 5000})
````

````ruby
# 5. Sort it 
query = query.sort("name")            # ascending 
query = query.sort_desc("name")       # descending
query = query.sort("address", "name") # sort by multiple columns
````

````ruby
# 6. Page it
query = query.page(2, :per => 10)
````

````ruby
# 7. Finally, get response in a hash or array of hashes
query.first    # return one row
query.rows     # return many rows
````

````ruby
# 8. Returns total row counts that matches the criteria
query.total_count
````

# Read API

## All Top Level Query Parameters

<table>
  <col width="33%"/>
  <col width="33%"/>
  <col width="33%"/>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td>filters</td>
    <td>Restrict the data returned to conform to specific conditions.</td>
    <td><tt>query = query.filters("name" => {"$bw" => "starbucks"})</tt></td>
  </tr>
  <tr>
    <td>get total row count</td>
    <td>returns the total count of the number of rows in the dataset that conform to the query.</td>
    <td><tt>query.total_count</tt></td>
  </tr>
  <tr>
    <td>geo</td>
    <td>Restrict data to be returned to be within a geographical range based.</td>
    <td>(See the section on Geo Filters)</td>
  </tr>
  <tr>
    <td>limit</td>
    <td>Limit the results</td>
    <td><tt>query = query.limit(12)</tt></td>
  </tr>
  <tr>
    <td>page</td>
    <td>Limit the results to a specific "page".</td>
    <td><tt>query = query.page(2, :per => 10)</tt></td>
  </tr>
  <tr>
    <td>search (across entity)</td>
    <td>Full text search across entity</td>
    <td>
      Find "sushi":<br><tt>query = query.search("sushi")</tt><p>
      Find "sushi" or "sashimi":<br><tt>query = query.search("sushi", "sashimi")</tt><p>
      Find "sushi" and "santa" and "monica":<br><tt>query.search("sushi santa monica")</tt>
    </td>
  </tr>
  <tr>
    <td>search (across field)</td>
    <td>Full text search on specific field</td>
    <td><tt>query = query.filters({"name" => {"$search" => "cafe"}})</tt></td>
  </tr>
  <tr>
    <td>select</td>
    <td>Specifiy which fields to include in the query results.  Note that the order of fields will not necessarily be preserved in the resulting response due to the nature Hashes.</td>
    <td><tt>query = query.select(:name, :address, :locality, :region)</tt></td>
  </tr>
  <tr>
    <td>sort</td>
    <td>The field (or fields) to sort data on, as well as the direction of sort.<p>
        Sorts ascending by default, but supports both explicitly sorting ascending and descending, by using <tt>sort_asc</tt> or <tt>sort_desc</tt>.
        Supports $distance as a sort option if a geo-filter is specified.<p>
        Supports $relevance as a sort option if a full text search is specified either using the q parameter or using the $search operator in the filter parameter.<p>
        By default, any query with a full text search will be sorted by relevance.<p>
        Any query with a geo filter will be sorted by distance from the reference point.  If both a geo filter and full text search are present, the default will be relevance followed by distance.</td>
    <td><tt>query = query.sort("name")</tt><br>
    <tt>query = query.sort_desc("$distance")</tt>
    <tt>query = query.sort_asc("name").sort_desc("rating")</tt></td>
  </tr>
</table>

## Row Filters

The driver supports various row filter logic. For example:

`````ruby
# Returns records from the Places dataset with names beginning with "starbucks"
factual.table("places").filters("name" => {"$bw" => "starbucks"}).rows
````

### Supported row filter logic

<table>
  <tr>
    <th>Predicate</th>
    <th width="25%">Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td>$eq</td>
    <td>equal to</td>
    <td><tt>query = query.filters("region" => {"$eq" => "CA"})</tt></td>
  </tr>
  <tr>
    <td>$neq</td>
    <td>not equal to</td>
    <td><tt>query = query.filters("region" => {"$neq" => "CA"})</tt></td>
  </tr>
  <tr>
    <td>search</td>
    <td>full text search</td>
    <td><tt>query = query.search("sushi")</tt></td>
  </tr>
  <tr>
    <td>$in</td>
    <td>equals any of</td>
    <td><tt>query = query.filters("region" => {"$in" => ["CA", "NM", "NY"]})</tt></td>
  </tr>
  <tr>
    <td>$nin</td>
    <td>does not equal any of</td>
    <td><tt>query = query.filters("region" => {"$nin" => ["CA", "NM", "NY"]})</tt></td>
  </tr>
  <tr>
    <td>$bw</td>
    <td>begins with</td>
    <td><tt>query = query.filters("name" => {"$bw" => "starbucks"})</tt></td>
  </tr>
  <tr>
    <td>$nbw</td>
    <td>does not begin with</td>
    <td><tt>query = query.filters("name" => {"$nbw" => "starbucks"})</tt></td>
  </tr>
  <tr>
    <td>$bwin</td>
    <td>begins with any of</td>
    <td><tt>query = query.filters("name" => {"$bwin" => ["starbucks", "coffee", "tea"]})</tt></td>
  </tr>
  <tr>
    <td>$nbwin</td>
    <td>does not begin with any of</td>
    <td><tt>query = query.filters("name" => {"$nbwin" => ["starbucks", "coffee", "tea"]})</tt></td>
  </tr>
  <tr>
    <td>$blank</td>
    <td>test to see if a value is (or is not) blank or null</td>
    <td><tt>query = query.filters("tel" => {"$blank" => true})</tt><br>
        <tt>query = query.filters("website" => {"$blank" => false})</tt></td>
  </tr>
  <tr>
    <td>$gt</td>
    <td>greater than</td>
    <td><tt>query = query.filters("rating" => {"$gt" => 7.5})</tt></td>
  </tr>
  <tr>
    <td>$gte</td>
    <td>greater than or equal</td>
    <td><tt>query = query.filters("rating" => {"$gte" => 7.5})</tt></td>
  </tr>
  <tr>
    <td>$lt</td>
    <td>less than</td>
    <td><tt>query = query.filters("rating" => {"$lt" => 7.5})</tt></td>
  </tr>
  <tr>
    <td>$lte</td>
    <td>less than or equal</td>
    <td><tt>query = query.filters("rating" => {"$lte" => 7.5})</tt></td>
  </tr>
</table>

### AND

Filters can be logically AND'd together. For example:

````ruby
# name begins with "coffee" AND tel is not blank
query = query.filters({ "$and" => [{"name" => {"$bw" => "coffee"}}, {"tel" => {"$blank" => false}}] })
````

### OR

Filters can be logically OR'd. For example:

````ruby
# name begins with "coffee" OR tel is not blank
query = query.filters({ "$or" => [{"name" => {"$bw" => "coffee"}}, {"tel" => {"$blank" => false}}] })
````

### Combined ANDs and ORs

You can nest AND and OR logic to whatever level of complexity you need. For example:

````ruby
# (name begins with "Starbucks") OR (name begins with "Coffee")
# OR
# (name full text search matches on "tea" AND tel is not blank)
query = query.filters({ "$or" => [ {"$or" => [ {"name" => {"$bw" => "starbucks"}},
                                               {"name" => {"$bw" => "coffee"}}]},
                                   {"$and" => [ {"name" => {"$search" => "tea"}},
                                                {"tel" => {"$blank" => false}} ]} ]})
````

# Crosswalk

The driver fully supports Factual's Crosswalk feature, which lets you "crosswalk" the web and relate entities between Factual's data and that of other web authorities.

(See [the Crosswalk Blog](http://blog.factual.com/crosswalk-api) for more background.)

## Simple Crosswalk Example

````ruby
# Get all Crosswalk data for a Place with a specific FactualID
factual.crosswalk("110ace9f-80a7-47d3-9170-e9317624ebd9").rows
````

## Supported Crosswalk Options

### only

You can specify which namespaces you want, like this:

````ruby
# Get Crosswalk data for only yelp and facebook for a Place with a specific FactualID
factual.crosswalk("110ace9f-80a7-47d3-9170-e9317624ebd9").only(:yelp, :facebook).rows
````

This will generally return 1 record per requested namespace.

### limit

You can limit the amount of Crosswalk results you get back, like this:

````ruby
# Get only 3 Crosswalk results for a Place with a specific FactualID
factual.crosswalk("110ace9f-80a7-47d3-9170-e9317624ebd9").limit(3).rows
````

# Resolve

The driver fully supports Factual's Resolve feature, which lets you start with incomplete data you may have for an entity, and get potential entity matches back from Factual.

Each result record will include a confidence score (<tt>"similarity"</tt>), and a flag indicating whether Factual decided the entity is the correct resolved match with a high degree of accuracy (<tt>"resolved"</tt>).

For any Resolve query, there will be 0 or 1 entities returned with <tt>"resolved"=true</tt>. If there was a full match, it is guaranteed to be the first record in the response Array.

(See [the Resolve Blog](http://blog.factual.com/factual-resolve) for more background.)

## Simple Resolve Examples

````ruby
# Returns resolved entities as an array of hashes
query = factual.resolve("name" => "McDonalds",
                        "address" => "10451 Santa Monica Blvd",
                        "region" => "CA",
                        "postcode" => "90025")

query.first["resolved"] # true or false
query.rows              # all candidate rows
````

# Geo Filters

You can query Factual for entities located within a geographic area. For example:

````ruby
query = query.geo("$circle" => {"$center" => [34.06021, -118.41828], "$meters" => 5000})
````

# Facets

The driver fully supports Factual's Facets feature, which lets you return row counts for Factual tables, grouped by facets of data.  For example, you may want to query all businesses within 1 mile of a location and for a count of those businesses by category.

For example:

````ruby
# Returns a count of Starbucks by country
factual.facets("global").select("country").search("starbucks").columns
````

## All Top Level Facets Parameters

<table>
  <col width="33%"/>
  <col width="33%"/>
  <col width="33%"/>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td>select</td>
    <td>The fields for which facets should be generated. The response will not be ordered identically to this list, nor will it reflect any nested relationships between fields.</td>
    <td><tt>.select("region", "locality")</tt></td>
  </tr>
  <tr>
    <td>limit</td>
    <td>The maximum number of unique facet values that can be returned for a single field. Range is 1-250. The default is 25.</td>
    <td><tt>.limit(10)</tt></td>
  </tr>
  <tr>
    <td>filters</td>
    <td>Restrict the data returned to conform to specific conditions.</td>
    <td><tt>.filters("name" => {"$bw" => "starbucks"})</tt></td>
  </tr>
  <tr>
    <td>include_count</td>
    <td>Include a count of the total number of rows in the dataset that conform to the request based on included filters. Requesting the row count will increase the time required to return a response. The default behavior is to NOT include a row count. When the row count is requested, the Response object will contain a valid total row count via <tt>.getTotalRowCount()</tt>.</td>
    <td><tt>.include_count</tt></td>
  </tr>
  <tr>
    <td>geo</td>
    <td>Restrict data to be returned to be within a geographical range.</td>
    <td>(See the section on Geo Filters)</td>
  </tr>
  <tr>
    <td>search</td>
    <td>Full text search query string.</td>
    <td>
      Find "sushi":<br><tt>.search("sushi")</tt><p>
      Find "sushi" or "sashimi":<br><tt>.search("sushi, sashimi")</tt><p>
      Find "sushi" and "santa" and "monica":<br><tt>.search("sushi santa monica")</tt>
    </td>
  </tr>
</table>  
  
</table>


# Flag

Factual's Flag feature enables flagging problematic rows in Factual tables. Use this feature if you are requesting for an entity to be deleted or merged into a duplicate record.

## Simple Flag Example

````ruby
# User user123 flags row 0545b03f-9413-44ed-8882-3a9a461848da in the global dataset as inaccurate
factual.flag("global", "0545b03f-9413-44ed-8882-3a9a461848da", :inaccurate, "user123").write
````

The reason for flagging must be one of the following:
<ul>
<li>:duplicate
<li>:nonexistent
<li>:inaccurate
<li>:inappropriate
<li>:spam
<li>:other
</ul>

You can also create a Flag object and set it with optional parameters beforing writing it. For example:

````ruby
flag = factual.flag("global", "0545b03f-9413-44ed-8882-3a9a461848da", :inaccurate, "user123")
flag = flag.comment("this row is outdated").reference("http://www.example.com/somepage.html")
flag.write
````

## Optional Flag Parameters

<table>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td>comment</td>
    <td>Any english text comment that may help explain your corrections.</td>
    <td><tt>.comment("this row is outdated")</tt></td>
  </tr>
  <tr>
    <td>reference</td>
    <td>A reference to a URL, title, person, etc. that is the source of this data.</td>
    <td><tt>.reference("http://www.example.com/somepage.html")</tt></td>
  </tr>
</table>  

# Contribute

The driver fully supports Factual's Contribute feature, which enables you to contribute edits to existing rows and/or contribute new rows of data in Factual tables. For information on deleting records, see Flag.


## Simple Contribute Examples

The <tt>contribute</tt> method is a contribution to edit an existing row or add a new row:

````ruby
# Contribute a new row to Factual's global dataset
factual.contribute("global", "user123").values({"name" => "McDenny's", "address" => "1 Main St.", "locality" => "Bedrock", "region" => "BC"}).write
````

````ruby
# Contribute a correction to an existing row in Factual's places dataset.
# Also set optional <tt>comment</tt> and <tt>reference</tt>
contr = factual.contribute("places", "user123").values({:name => "McDenny's"})
contr = contr.comment("They changed their name last month").reference("http://www.example.com/mypage.html")
contr.write
````


## Required Contribute Parameters

<table>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td>values</td>
    <td>A hash of names and values to be added to a Factual table</td>
    <td><tt>{"name" => "McDenny's", "address" => "1 Main St.", "locality" => "Bedrock", "region" => "BC"}</tt></td>
  </tr>
  <tr>
    <td>user</td>
    <td>An arbitrary token representing the user contributing the data.</td>
    <td><tt>user123</tt></td>
  </tr>
</table>

## Optional Contribute Parameters

<table>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Example</th>
  </tr>
  <tr>
    <td>factual_id</td>
    <td>The factual_id of the row to which you want to contribute a correction</td>
    <td><tt>.factual_id("0545b03f-9413-44ed-8882-3a9a461848da")</tt></td>
  </tr>
  <tr>
    <td>comment</td>
    <td>Any english text comment that may help explain your corrections.</td>
    <td><tt>.comment("They changed their name last month")</tt></td>
  </tr>
  <tr>
    <td>reference</td>
    <td>A reference to a URL, title, person, etc. that is the source of this data.</td>
    <td><tt>.reference("http://www.example.com/mypage.html")</tt></td>
  </tr>
</table>	


# Schema

You can query Factual for the detailed schema of any specific table in Factual. For example:

````ruby
# Returns a hash of metadata for the table named "global", including an array of fields
factual.table("global").schema
````

# Raw Read Queries

You can perform any read queries documented in the Factual API using the
raw read query. Just supply the full path (including the first
forward-slash) and the request will be made using your OAuth token:

````ruby
# Find rows in the restaurant database whose name begins with "Star" and return both the data and a total count of the matched rows
factual.read('/t/restaurants-us?filters={"name":{"$bw":"Star"}}&include_count=true')
````

# Debug Mode

To see the query paths generated by the driver you can use it in debug mode by passing :debug => true as
the third argument of the Factual constructor. Here is an example in irb:


````ruby
> factual = Factual.new(key, secret, :debug => true)
> factual.table("places").filters("name" => {"$bw" => "starbucks"})
Request: http://api.v3.factual.com/t/places?filters=%7B%22name%22%3A%7B%22%24bw%22%3A%22starbucks%22%7D%7D
 => [{"address"=>"11290 Donner Pass Rd", "category"=>"Food & Beverage > Cafes, Coffee Houses & Tea Houses", ...
````
