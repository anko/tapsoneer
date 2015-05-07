#!/usr/bin/env lsc
taps = require \./index.ls

taps!
  ..push expected : "one" test : (cb) -> cb null, "ok"
  ..on \data -> console.log it
  ..on \end -> console.log "done"
