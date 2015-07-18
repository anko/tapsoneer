taps = require \./index.ls
through = require \through

s = taps!

[ 0 to 4 ].for-each (n) ->
  r = Math.random! * 500
  s.write {
    expected : "test number #n"
    test : (cb) ->
      set-timeout do
        -> cb null, "all fine for #n (#r)"
        r
  }
s.end!

s.pipe through -> console.log "+", JSON.stringify it
