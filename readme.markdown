# tapson

Streaming asynchronous test harness.  Outputs tapson objects.

## Tutorial

```js
// Instantiate.
var taps = require("tapson")();

// Push test objects.
var n = 10;
while(--n) {
    taps.push({
        expected : "test number " + n,
        test : function(callback) {

            // Test logic goes here.

            // Illustration: succeed 1 second later.
            setTimeout(function() { callback(null, "Success " + n); }, 1000);

        }
    });
}
taps.push(null); // End input stream.

// Tapson immediately runs tests on reception.

taps.pipe(process.stdout);
```

## methods

### `tapson([name], fun)`

Creates new test with optional name `name`.  The test function `fun` will be
called with a callback function as its first argument.  It is expected to call
that callback on completion with its first parameter a failure message (or
`null` on success) and a success message on its second parameter (it's ignored
if the failure parameter is present).

The return value is an object with these properties:

- `plan`::`object`: an object representing a tapson test plan.
- `test`::`function`: an object representing a tapson test plan.

The `test` function itself takes a single parameter callback, such that it can
be used in an asynchronous context.  It calls the callback with a first
parameter of error, and the second an object representing the tapson output for
that test.

## Examples

```js
var taps = require("tapson");
var async = require("async");

tests = [
    taps("math works", function(cb) { (1 + 1 == 2) ? cb(null, "yep") : cb("oh no") }),
    taps("package.json exists", function(cb) { fs.readFile("package.json", cb); })
];

var t = taps(tests);

async.map(tests, function(e, success));

taps!
    ..queue "what" -> it null
    ..queue "what else" [ "what" ], -> it null
    ..run!

```

[1]: https://github.com/substack/tape
