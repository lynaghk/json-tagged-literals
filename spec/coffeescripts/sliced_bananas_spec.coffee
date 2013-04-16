#Tests for the Public API only


beforeEach ->
  @addMatchers
    #Dates have by-reference semantics. Ugh, JavaScript!
    toEqualDate: (d) -> @actual.valueOf() == d.valueOf()

describe "deserialization", ->
  input = {"#inst": "2013-04-05T00:00:00.000-00:00"}

  it "works on toplevel dates", ->
    res = SlicedBananas.deserialize SlicedBananas.DefaultTagTable, input
    expect(res).toEqualDate new Date(Date.UTC(2013, 3, 5))


  