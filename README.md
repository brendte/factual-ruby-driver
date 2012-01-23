# About

This is the Factual supported Ruby driver for [Factual's public API](http://developer.factual.com/display/docs/Factual+Developer+APIs+Version+3).

This API supports queries to Factual's Read, Schema, Crosswalk, and Resolve APIs. Full documentation is available on the Factual website:

*   [Read](http://developer.factual.com/display/docs/Factual+Developer+APIs+Version+3): Search the data
*   [Schema](http://developer.factual.com/display/docs/Core+API+-+Schema): Get table metadata
*   [Crosswalk](http://developer.factual.com/display/docs/Places+API+-+Crosswalk): Get third-party IDs
*   [Resolve](http://developer.factual.com/display/docs/Places+API+-+Resolve): Enrich your data and match it against Factual's

This driver is supported via the [Factual Developer Group](https://groups.google.com/group/factual_developers)

# Overview

## Basic Design

The driver allows you to create an authenticated handle to Factual. With a Factual handle, you can send queries and get results back.

Queries are created using the Factual handle, which provides a fluent interface to constructing your queries. 

Results are returned as Ruby Arrays of Hashes, where each Hash is a result record.

## Setup

The driver's gems are hosted at [Rubygems.org](http://rubygems.org). Make sure you're using the latest version of rubygems:

````bash
$ gem update --system
````

Then you can install the factual-api gem as follows:

`````bash
$ gem install factual-api
`````

Once the gem is installed, you can use it in your Ruby project like:

````ruby
gem 'factual-api'
require 'factual'
factual = Factual.new("YOUR_KEY", "YOUR_SECRET")
````
  
## Simple Query Example

`````ruby
# Returns records from the Places dataset with names beginning with "Star"
factual.table("places").filters("name" => {"$bw" => "Star"}).rows
`````

# Read API

## Read (with all features)

    # 1. Specify the table Global
    query = factual.table("global")

    # 2. Filter results in country US (For more filters syntax, refer to [Core API - Row Filters](http://developer.factual.com/display/docs/Core+API+-+Row+Filters))
    query = query.filters("country" => "US")

    # 3. Search for "sushi" or "sashimi" (For more search syntax, refer to [Core API - Search Filters](http://developer.factual.com/display/docs/Core+API+-+Search+Filters))
    query = query.search("sushi", "sashimi")

    # 4. Filter by Geo (For more geo syntax, refer to [Core API - Geo Filters](http://developer.factual.com/display/docs/Core+API+-+Geo+Filters))
    query = query.geo("$circle" => {"$center" => [34.06021, -118.41828], "$meters" => 5000})

    # 5. Sort it 
    query = query.sort("name")            # ascending 
    query = query.sort_desc("name")       # descending
    query = query.sort("address", "name") # sort by multiple columns

    # 6. Page it
    query = query.page(2, :per => 10)

    # 7. Finally, get response in a hash or array of hashes
    query.first    # return one row
    query.rows     # return many rows

    # 8. Returns total row counts that matches the criteria
    query.total_count

    # You can chain the query methods, like this
    factual.table("places").filters("region" => "CA").search("sushi", "sashimi").geo("$circle" => {"$center" => [34.06021, -118.41828], "$meters" => 5000}).sort("name").page(2, :per => 10).rows

## Crosswalk

    # Concordance information of a place
    FACTUAL_ID = "110ace9f-80a7-47d3-9170-e9317624ebd9"
    query = factual.crosswalk(FACTUAL_ID)
    query.rows

## Resolve

    # Returns resolved entities as an array of hashes
    query = factual.resolve("name" => "McDonalds",
                    "address" => "10451 Santa Monica Blvd",
                    "region" => "CA",
                    "postcode" => "90025")

    query.first["resolved"]   # true or false
    query.rows                # all candidate rows

## Schema

    # Returns a hash of table metadata, including an array of fields
    factual.table("global").schema
