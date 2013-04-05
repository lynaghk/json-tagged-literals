goog.provide "com.keminglabs.sliced_bananas"

# Lil' print function that's helpful to have during development; it'll be removed by Closure compiler if it's not used in anything exported.
p = (x) ->
  console.log x
  x

get_tag = (literal_prefix, x) ->
  if (x instanceof Object)
    ks = Object.keys(x)
    if ks.length == 1 and ks[0][0] == literal_prefix
      #return the tag
      Object.keys(x)[0].substring 1

sb = null #need CoffeeScript to define the var up here rather than within goog.scope.
goog.scope ->
  sb = com.keminglabs.sliced_bananas

  sb.LiteralPrefix = "#"
  sb.DefaultReader = (tag, x) ->
    throw "Tag '#{tag}' not recognized"

  sb.deserialize = (tag_table, x) ->
    tag = get_tag sb.LiteralPrefix, x
    if tag
      tag_reader = tag_table[tag]
      val = x[Object.keys(x)[0]]
      if tag_reader
        tag_reader val
      else
        sb.DefaultReader tag, val

  sb.DefaultTagTable =
    inst: (x) -> new Date(Date.parse x)


  # The function provided to goog.scope shouldn't return anything, but CoffeeScript will always return the last expression of a fn.
  # This return statement will be matched by a regex in the Rakefile and eliminated before it's passed to the Closure compiler.
  return "eliminate-this-line"