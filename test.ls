taps = require \./index.ls
test = require \tape
require! \highland
{ unique } = require \prelude-ls

# Decided to use tape for the tests because testing a
# test framework with itself would be madness! :)

test "simple 5-successes in random order" (t) ->

  s = taps!

  t.plan 13

  [ 0 to 4 ].for-each (n) ->
    r = Math.random! * 500
    s.write {
      expected : "test number #n"
      test : (cb) ->
        set-timeout do
          -> cb null, "all fine for #n"
          r
    }
  s.end!

  highland s .to-array (d) ->
    d.length `t.equals` 10
    t.equals do
      d |> (.map (.id)) |> unique |> (.length)
      5
    t.equals do
      d |> (.filter (.ok)) |> (.length)
      5
    for n from 0 to 4
      t.ok do
        "test number #n" in d.map (.expected)
        "test #n plan exists"
      t.ok do
        "all fine for #n" in d.map (.actual)
        "test result #n exists"
