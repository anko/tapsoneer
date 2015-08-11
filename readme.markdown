# tapsoneer [![](https://img.shields.io/npm/v/tapsoneer.svg?style=flat-square)][1] [![](https://img.shields.io/travis/anko/tapsoneer.svg?style=flat-square)][2]

A simple Node.js/io.js interface to the [tapson][3] test protocol, version
1.0.0.

Tests are planned, then run asynchronously.  If some of your tests depend on
each other, you can specify how.

Exports a readable tapson protocol stream.

    npm i tapsoneer

## Tutorial

```js
// Instantiate
var taps = require("tapsoneer")();

// Create 2 tests that finish in 0 - 1 seconds
var test1 = taps.plan("this runs first", function(cb) {
    setTimeout(function() { cb(null, "first ok") }, Math.random() * 1000);
});
var test2 = taps.plan("this runs second", function(cb) {
    setTimeout(function() { cb(null, "second ok") }, Math.random() * 1000);
});
// Tell tapsoneer we're done with planning tests
taps.done();

// Run the tests in parallel
test1();
test2();

// Read the output data stream
taps.out.on("data", function(d) { console.log(d); });
```

With the above, tapsoneer runs both tests in parallel.  You can expect output that
looks like—

```json
{"id":"5a10fa17-1783-4b72-afa5-5cab41209dae","expected":"this runs first"}
{"id":"68cb2ae4-f769-4f86-82d9-a15fdab4180a","expected":"this runs second"}
{"id":"4f4ac792-f37f-4dc3-a97d-5004e05ca669","ok":true,"actual":"second ok"}
{"id":"4b157358-603f-49c3-aec5-a0498ff89447","ok":true,"actual":"first ok"}
```

## Exported things

### `var tests = tapsoneer([options])`

Creates a new tapsoneer test set, ready and waiting for tests.

By default, the emitted stream outputs Node Buffers.  If you want a stream of
objects instead, pass an options object with `{ objectMode : true }`.

### `var test = tests.plan([description], testFunction)`

Plans a new test with an optional description and a function that runs it.
Returns a function that you can call to immediately run the test.

The `test` will be passed a callback function as its only argument, which it
should call once it is finished.  As is the usual Node.js practice, if there's
a failure, pass an `Error` object or `String` error message as the first
parameter.  If it succeeded, pass `null` as the first parameter and an optional
String describing the success as the second.

### `test([callback])`

Runs the given test immediately.  Its results will be on the output stream as
soon as the test completes.

You can optionally pass it a `callback` argument, to be notified when the test
finishes.  This is handy if some of your tests depend on other tests, and means
you can use [async.js][4] to do stuff like—

```js

var databaseConnection = null;

var testSetupDatabase = tests.plan("database sets up", function(cb) {
    // Do whatever you need to set up the database, and call `cb`.
});
var testQuery = tests.plan("query some values", function(cb) {
    // Use the `databaseConnection` to do stuff and call `cb`.
});

tests.done();

async.series([ testSetupDatabase, testQuery ]);
```

—to ensure they run sequentially.  If you have a tangly mess of dependencies,
[`async.auto`][5] is your friend.

If you want to run a test immediately after you plan it because it has no
dependencies on anything, that's fine too.  It'll run in parallel with other
tests:

```js
tests.plan("this runs right away", function(cb) { cb(null, "no problemo") })();
```

If you want to pass data between tests (some stuff from a database, say), just
call your test function's result callback with that data as additional
arguments.  They'll be prepended to the test callback's arguments in a way
that's compatible with [`async.waterfall`][6]:

```js
var queryDatabase = tests.plan("database opens", function(cb) {
    db.query("some-query", function(e, data) {
        if (e) {
            cb(e); // fail
        }
        else {
            cb(null, "database ok", data);
        }
    });
});

var checkData = tests.plan("data looks fine", function(data, cb) {
    if (data == "correct value") {
        cb(null, "yep");
    } else {
        cb("Got bad data: " + data); // fail
    }
}

tests.done();

async.waterfall([ queryDatabase, checkData ]);
```

### `tests.out`

This is a [stream][7] containing tapson.  All test plans and test results are
emitted from it as they happen.  The stream finishes when all the tests finish.

If you want it on `stdout`, just do `tests.out.pipe(process.stdout)`.

## License

[ISC][8].

[1]: https://www.npmjs.com/package/tapsoneer
[2]: https://travis-ci.org/anko/tapsoneer
[3]: https://github.com/anko/tapson
[4]: https://github.com/caolan/async
[5]: https://github.com/caolan/async#auto
[6]: https://github.com/caolan/async#waterfalltasks-callback
[7]: http://nodejs.org/api/stream.html
[8]: LICENSE
