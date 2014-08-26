# Hypermicrodata

Ruby library for extracting HTML5 Microdata with Hypermedia

[![Build Status](https://travis-ci.org/tkawa/hypermicrodata.png)](https://travis-ci.org/tkawa/hypermicrodata)

## Story 

Most of the code here was extracted from [Mida](https://github.com/LawrenceWoodman/mida) by Lawrence Woodman. This was done in order to have a simpler, more generic Microdata parser without all the vocabulary awareness and other features. This gem is also tested under Ruby 1.9.3 and Ruby 2.0.0, though it could be better tested.

## Installation

This library has not been released to RubyGems.org yet, but when it is the intention is to have it install with the following.

Add this line to your application's Gemfile:

    gem 'hypermicrodata'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hypermicrodata

## Usage

The commandline tool hypermicrodata.rb can be run like the following:

```
hypermicrodata.rb http://d.lib.ncsu.edu/collections/catalog/mc00383-001-ff0006-001-001_0038
```

Output is in pretty JSON format.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
