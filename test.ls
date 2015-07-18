taps = require \./index.ls
through = require \through

{ input, output } = taps!

[ 0 to 4 ].for-each (n) ->
  input.write {
    expected : "test number #n"
    test : (cb) ->
      set-timeout do
        -> cb null, "all fine for #n"
        1000
  }
input.end!

output.pipe through -> console.log "+", JSON.stringify it
