# Introduction

This is the Factual supported Ruby driver for [Factual's public API](http://developer.factual.com/display/docs/Factual+Developer+APIs+Version+3).

# Installation

TODO: gemify

    require 'factual'
    factual = Factual.new("YOUR_KEY", "YOUR_SECRET")
  
# Examples

## Read

    # Returns Places with names beginning with "Star", as JSON
    factual.find("places", {:filters => {"name" => {"$bw" => "Star"}}})

## Resolve

    # Returns resolved entities as JSON
    factual.resolve("places", {"name" => "McDonalds",
                               "address" => "10451 Santa Monica Blvd",
                               "region" => "CA",
                               "postcode" => "90025"})

