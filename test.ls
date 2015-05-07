taps = require \./index.ls
from-s = require \from
through = require \through

from-s [
  * expected : "one" test : (cb) -> cb null, "ok"
]
console.log taps!
from-s .pipe taps! .pipe through -> console.log it
