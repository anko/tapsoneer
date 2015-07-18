require! <[ uuid highland ]>

module.exports = construct = (opts) ->

  # The gist here is that highland usually only exposes *transform* streams,
  # which don't have the full generality of *duplex* streams, and we really
  # need that generality.

  # So, we're going to create 2 transform streams:

  # The first is just an output sink.
  s-out = highland!

  total-planned  = 0
  total-finished = 0
  input-done = false

  # The second takes input and asynchronously writes into the output sink when
  # it has something to say.
  s-in = highland!tap ({ expected, test }) ->

    id = uuid!

    # Write the test plan
    s-out.write { id, expected }

    ++total-planned

    # Asynchronously call the test function and write its result
    test.call null (err, result) ->
      ++total-finished
      if err
      then s-out.write { id, ok : no  actual : (err.message || err) }
      else s-out.write { id, ok : yes actual : result }
      if input-done and (total-planned == total-finished)
        s-out.write highland.nil

  s-in.on \end ->
    if total-planned is total-finished
      s-out.write highland.nil
    else input-done := true

  s-in.resume! # Drain input stream

  # Then we do this trick to combine the 2 streams into a duplex stream:

  # Highland.pipeline creates an initial source stream and calls all of its
  # arguments sequentially with the preceding stream as an argument.  It then
  # creates a duplex stream (yey) such that the input is connected to the
  # source it created and the output to the return value of the last one.

  return highland.pipeline (source-stream) ->

    # This means we can just pipe the source into our consumer ...
    source-stream.pipe s-in

    # ... and return our producer
    s-out
