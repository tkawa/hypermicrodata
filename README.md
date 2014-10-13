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

### Basic

```
json = Hypermicrodata::Extract.new(html).to_json(:uber)
```

Supported formats are

- application/vnd.amundsen-uber+json (:uber)
- application/hal+json (:hal)
- application/json (:plain)

### Rails Integration

When you use this in Rails, you don't need to extract data manually.

/app/controllers/people_controller.rb

```
class PeopleController < ApplicationController
  before_action :set_message, only: %i(show edit update destroy)
  include Hypermicrodata::Rails::HtmlBasedJsonRenderer
  ...
end
```

/app/views/people/show.html.haml

```
.person{itemscope: true, itemtype: 'http://schema.org/Person',
        itemid: person_url(@person), data: {main_item: true}}
  .media
    .media-image.pull-left
      = image_tag @person.picture_path, alt: '', itemprop: 'image'
    .media-body
      %h1.media-heading
        %span{itemprop: 'name'}= @person.name
  = link_to 'collection', people_path, rel: 'collection', itemprop: 'isPartOf'
```

And you can serve following JSON:

```
GET /people/1 HTTP/1.1
Host: www.example.com
Accept: application/vnd.amundsen-uber+json
```

```
{
  "uber": {
    "version": "1.0",
    "data": [{
      "url": "http://www.example.com/people/1",
      "name": "Person",
      "data": [
        { "name": "image", "value": "/assets/bob.png" },
        { "name": "name", "value": "Bob Smith" },
        { "name": "isPartOf", "rel": "collection", "url": "/people" },
      ]
    }]
  }
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
