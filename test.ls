taps = require \./index.ls
through = require \through

t = taps!
t.write expected : "one" test : (cb) -> cb null, "all fine"
t.end!
t.pipe through -> console.log JSON.stringify it
