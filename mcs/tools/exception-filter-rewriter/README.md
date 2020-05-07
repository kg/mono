This tool rewrites methods that use exception filters (C#'s ```when```) so they only use ordinary ```try```/```catch``` exception handling. Each filter and its associated ```catch``` blocks are pulled out into methods and the function's state is pulled out into a closure stored on the heap while the method is running. This makes the methods compatible with mono's full AOT mode and similar compilers.

## How to use

```exception-filter-rewriter.exe [input] [output]``` 
or

```exception-filter-rewriter.exe --overwrite [filename]```. Multiple files can be processed in one invocation.

To enumerate all the methods in an assembly that use exception filters, pass the ```--audit``` switch and the tool will dump the method names instead of rewriting them. You can use this to identify problem methods or verify that no new filters have been added by updating a third-party dependency.

By default, rewritten assemblies will have a dependency on an ```ExceptionFilterSupport``` assembly that has to contain the exception filter API. If using a current version of mono's ```mscorlib```, you can pass the ```--mono``` switch and the tool will import the exception filter API from there instead, eliminating the dependency.

Additional options are available, run the tool without any arguments for more information.

## Notes

* Generic methods and/or methods of generic types cannot be rewritten.
* ```ref```/```out``` parameters cannot be used by filters. They can still be used inside ```try```, ```catch``` and ```finally``` blocks.
* Stack-only types like ```Span<T>``` cannot be used by filters or ```catch``` blocks.
* Unsafe types like pointers may not work.
* Rewritten methods will no longer have debugging information.
* Exception filters may run earlier than expected.
* Exception filters may be eagerly evaluated in some scenarios where the exception is going to be caught before the filter is reached.
* Exception filters run with the stack of whichever method is currently processing the exception instead of running with the stack of the method that contains the filter. You are most likely to observe this if you use ```Environment.StackTrace``` or throw exceptions inside your filter.
* If an exception filter throws, the behavior may not match that of your runtime's JIT. The thrown exception will be discarded and the filter will be treated as if it returned false.
* The introduction of the closure means that every invocation of a method with filters will allocate. This can introduce GC pressure and performance overhead you may not be expecting.
* Objects may survive GCs even if they are technically unreachable, because they have moved from a temporary slot on the stack to a long-lived location in the closure.

## How it works

All methods in the assembly are scanned for exception handlers that use a filter in order to build a list of methods to rewrite.

When rewriting a method, it is first converted to store local and argument values inside a heap-allocated closure. Any values touched by filters or their ```catch``` blocks are moved into the closure so that they will be accessible when the filter runs, with the exception of ```ref```/```out``` parameters that cannot live on the heap (they will be passed in to the catch block when it runs.)

Once the method has been rewritten to use a closure, each filter is hoisted out into a dedicated subclass of ```Mono.ExceptionFilter```. 