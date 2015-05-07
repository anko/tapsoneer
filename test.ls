taps = require \./index.ls
through = require \through

t = taps!

for n til 5
  console.log n
  t.write do
    expected : "test number #n"
    test : (cb) ->
      set-timeout do
        -> cb null, "all fine for #n"
        1000
t.end!

t.pipe through -> console.log JSON.stringify it
