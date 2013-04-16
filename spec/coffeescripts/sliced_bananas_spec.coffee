#Tests for the Public API only


beforeEach ->
  @addMatchers
    #Dates have by-reference semantics. Ugh, JavaScript!
    toEqualDate: (d) -> @actual.valueOf() == d.valueOf()

describe "deserialization", ->
  input = {"#inst": "2013-04-05T00:00:00.000Z"}

  it "works on toplevel dates", ->
    res = SlicedBananas.deserialize SlicedBananas.DefaultTagTable, input
    expect(res).toEqualDate new Date(Date.UTC(2013, 3, 5))


describe "serialization", ->
  
  it "works on toplevel dates", ->
    res = SlicedBananas.serialize SlicedBananas.DefaultConstructorTable, new Date(Date.UTC(2013, 3, 5))
    expect(res).toEqual {"#inst": "2013-04-05T00:00:00.000Z"}

  it "works on array'd dates", ->
    res = SlicedBananas.serialize SlicedBananas.DefaultConstructorTable, [new Date(Date.UTC(2013, 3, 5))]
    expect(res).toEqual [{"#inst": "2013-04-05T00:00:00.000Z"}]
