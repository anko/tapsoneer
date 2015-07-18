require! <[ uuid highland ]>

module.exports = construct = (opts) ->

  # The gist here is that highland usually only exposes *transform* streams,
  # which don't have the full generality of *duplex* streams, and we really
  # need that generality.

  # So, we're going to create 2 transform streams:

  # The first is just an output sink.

  s-out = highland!

  # The second takes input and asynchronously writes into the output sink

  # when it has something to say.
  s-in = highland!tap ({ expected, test }) ->

    id = uuid!

    s-out.write { id, expected }

    test.call null (err, result) ->
      if err
        s-out.write { id, -ok, actual : (err.message || err) }
      else
        s-out.write { id, +ok, actual : result }

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
