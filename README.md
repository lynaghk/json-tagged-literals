# JSON Tagged Literals

This project is inspired by [EDN](https://github.com/edn-format/edn), which provides much richer data structures than JSON.
However if you're stuck with JSON for performance or interoperability, use JTL to make the best of it.
JTL was originally written to support the [Precipitron 5000](http://precipitron.com) mobile weather app.

## Install

If you're OG, just grab [jtl.min.js](jtl.min.js) and throw it on your page.
You now have the `JTL` object in your global scope.

If you're using ClojureScript, add

```clojure
[com.keminglabs/jtl "0.1.0"]
```

to your `project.clj` dependencies and then

```clojure
(:require [com.keminglabs.jtl :as jtl])
```

in your namespace form.
Note that this is a plain JavaScript library, so if you want to pass options make sure you first coerce them to a JavaScript object:
```clojure
(jtl/deserialize my-js-obj
                (clj->js {"tag_table" {"inst" (fn [d] ...)}}))
```


## Usage

This library is two pure functions, `serialize` and `deserialize`, which move values between the rich semantics of your application and the impoverished semantics of JSON.
To serialize a non-JSONable value (i.e., anything beyond a string, number, true/false/null, or array or string-key'd map thereof) you provide a *tag* and a JSONable representation of the value.
To deserialize, you provide a function that takes the JSONable representation and returns the richer type.

Consider the classic problem of serializing dates.
JTL comes with a built-in reader for the "inst" tag with the [rfc-3339](http://www.ietf.org/rfc/rfc3339.txt) string representations of dates:

```javascript
JTL.deserialize({"#inst": "2013-04-05T00:00:00.000Z"})
  .getFullYear() //=> 2013
```

Note that the argument to deserialize is a data structure, not a string; use `JSON.parse` to convert your JSON string into data and then `JTL.deserialize` to lift that data into your application domain.

Tagged literals can occur at any (potentially nested) position in JSON data:

```javascript
JTL.deserialize([0, 1, {"#inst": "2013-04-05T00:00:00.000Z"}])
  .pop().getFullYear() //=> 2013
```

Additional tags can be specified with a map of tags to reader functions:

```javascript
opts = {tag_table: {inst: function(x){return new Date(Date.parse(x)).getFullYear();}}}
JTL.deserialize([0, 1, {"#inst": "2013-04-05T00:00:00.000Z"}], opts)
  //=> [0, 1, 2013]
```

and tags can be nested within each other:

```javaScript
var Order = function Order() {}

var opts = {
  tag_table: {
    order: function(x) {
      var o = new Order();
      o.id = x.id;
      o.placed_on = x.placed_on;
      return o;}}};

var d = {"#order": {"id": 123, "placed_on": {"#inst": "2013-04-05T00:00:00.000Z"}}};
var res = JTL.deserialize(d, opts);
res.constructor == Order //=> true
res.placed_on.getFullYear() == 2013 //=> true
```

Note here that the tagged literal value `#order` was serialized as a JSON object its body, not just a string.
There's no need to compact several values together in a string and try to regex them back out---tagged literal values are just JSON, so you should use the appropriate data shapes (ordered or associative collections, scalars) to serialize your values, using JTL to lift them into application domain objects.

By default, an error is thrown when an unknown tag is encountered, but that behavior can be changed by providing a default reader function:

```javascript
JTL.deserialize({"#trouble": true})
  //=> Raises an error!
JTL.deserialize({"#trouble": true},
                          {default_reader: function(x){return 42;}})
  //=> 42
```

To convert your application values into JSONable values, you can use the `serialize` function.
By default, only the `inst` tag is implemented:

```javascript
JTL.serialize({"aDate": new Date()})
  //=> {aDate: {#inst: "2013-04-16T20:32:20.807Z"}}
```

but as with the `deserialize` function you can pass a second argument options map.
The interesting key in this options map is `constructor_table`, which should map to an instance of [goog.structs.Map](http://docs.closure-library.googlecode.com/git/class_goog_structs_Map.html) with function constructor keys and serialization function values.
A serialization function should take your higher level type and return an array of the form `[string_tag, JSONable_value]`.
Your serialization functions will also be passed the options map given to `JTL.serialize` as the second argument; you can use this to recursively serialize composite types.

Using `goog.structs.Map` is going to be painful for anyone not using the Google Closure Library, so if you have suggestions for a nicer way to implement an open polymorphic dispatch system for serialization, please let me know.

For more usage examples, [see the tests](https://github.com/lynaghk/jtl/blob/master/spec/coffeescripts/jtl_spec.coffee).

## Serverside implementation

Since everything is just JSON, it's fairly easy to teach your server to emit tagged literals
Here's an example of serializing JodaTime dates with the [Cheshire](https://github.com/dakrone/cheshire) JSON library in Clojure:

```clojure
(ns ptron.server.util
  (:require [cheshire
             [core :as json]
             [generate :refer [add-encoder encode-map]]]
            [clj-time
             [core :refer [now]]
             [format :refer [formatters unparse]]]))

(add-encoder org.joda.time.DateTime
             (fn [x jg]
               (encode-map {"#inst" (unparse (formatters :date-time)
                                             x)}
                           jg)))

(json/encode (now))
    ;;=> "{\"#inst\":\"2013-05-07T04:32:49.376Z\"}"
```

[@sbecker](https://github.com/sbecker) shows us how it's done in Rails:

```ruby
# Monkeypatch Rails time class to output json differently
class ActiveSupport::TimeWithZone
  def to_json
    {"#inst" => self}.to_json
  end
end

user.updated_at.to_json
# => {"#inst":"2013-05-06T14:27:55-07:00"}
```


## Tips

If you think your application and its serverside endpoints might become popular, you should namespace your tags.
I.e., use tags like `"com.keminglabs.precipitron5000/forecast"`.
Now Gzip is even more your friend.

## Development

You'll need Ruby and bundler to build the project.
Use [RVM](https://rvm.io/) to grab Ruby 1.9.3, install the bundler rubygem, then

    bundle install
    git submodule update --init

to get all of the dependencies.
Then run

    bundle exec rake minify 

to run CoffeeScript and minify its output with the Google Closure compiler.


## Testing

Specs are written in CoffeeScript under `spec/coffeescripts`.

Start the test server with

    bundle exec rake jasmine
    
and then open up `localhost:8888` in your browser to run specs.
If you are editing specs, make sure to run

    bundle exec guard
    
so that the specs will automatically compile from CoffeeScript to JavaScript. 

## Thanks

Thanks to [@ninjascience](https://twitter.com/ninjascience) for design discussions.
Thanks to [@fogus](https://twitter.com/fogus) for feedback on README examples and raising questions about unknown type handling.
