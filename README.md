# Introduction

This is the Factual supported Ruby driver for [Factual's public API](http://developer.factual.com/display/docs/Factual+Developer+APIs+Version+3).

# Installation

    gem 'factual-api'
    require 'factual_api'
    factual = Factual::Api.new(YOUR_KEY, YOUR_SECRET)
  
# Examples

## Quick Sample 

    # Returns Places with names beginning with "Star"
    factual.table("places").filters("name" => {"$bw" => "Star"}).rows

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

    # 7. Finally, get response in Factual::Row objects
    query.first    # return one row
    query.rows     # return many rows

    # 8. Returns total row counts that matches the criteria
    query.total_count

    # You can chain the query methods, like this
    factual.table("places").filters("region" => "CA").search("sushi", "sashimi").geo("$circle" => {"$center" => [34.06021, -118.41828], "$meters" => 5000}).sort("name").page(2, :per => 10).rows

## Crosswalk

    # Concordance information of a place
    FACTUAL_ID = "110ace9f-80a7-47d3-9170-e9317624ebd9"
    factual.crosswalk(FACTUAL_ID)

## Resolve

    # Returns resolved entities as Factual::Row objects
    factual.resolve("name" => "McDonalds",
                    "address" => "10451 Santa Monica Blvd",
                    "region" => "CA",
                    "postcode" => "90025")

## Schema

    # Returns a Factual::Table object whose fields are an array of Factual::Field objects
    factual.table("global").schema()

## Facets

    # Returns number of starbucks in regions thoughout the world
    factual.table("global").select("country", "region").search("starbucks").min_count(2).facets()

