using System;
using System.Diagnostics;
using System.Linq;

#if WASM
using WebAssembly;
#endif

class Program {
    static void Main () {
        const int iterations = Benchmark.IterationCount, 
            warming_iterations = Benchmark.WarmingIterationCount;

        #if WASM
            Console.WriteLine ("Platform == WASM");
        #else
            Console.WriteLine ("Platform != WASM");
        #endif
    
        WakeUp ();

        var timings = new TimeSpan[iterations];

        var b = new Benchmark ();
        b.reset ();
        PerformWarmingPass (b, warming_iterations);

        b = new Benchmark ();
        b.reset ();

        PerformRealPass (b, iterations, timings);

        Console.WriteLine ($">>> Elapsed {timings.Sum (t => t.TotalMilliseconds)}ms");
        Console.WriteLine ($">>> ms/iter avg = {timings.Average (t => t.TotalMilliseconds)}");
        Console.WriteLine ($">>> min = {timings.Min (t => t.TotalMilliseconds)}");
        Console.WriteLine ($">>> max = {timings.Max (t => t.TotalMilliseconds)}");

        if (Debugger.IsAttached) {
            Console.WriteLine (">>> Press enter to exit.");
            Console.ReadLine ();
        }
    }

    static void PerformRealPass (Benchmark b, int iterations, TimeSpan[] timings) {
        Console.WriteLine ($">>> Running {iterations} iterations...");

        // try {
            var sw = new Stopwatch ();
            for (int i = 0; i < iterations; i++) {
                sw.Restart ();
                b.Step ();
                timings[i] = sw.Elapsed;
            }
        // } finally {
            WakeUp ();
        // }
    }

    static void PerformWarmingPass (Benchmark b, int warming_iterations) {
        Console.WriteLine ($">>> Warming with {warming_iterations} iterations...");

        try {
            for (var i = 0; i < warming_iterations; i++)
                b.runIteration ();
        } finally {
            WakeUp ();
        }
    }

    static void WakeUp () {        
    }
}

public partial class Benchmark {
    public void Step () {
        for (int i = 0; i < InnerIterationCount; i++)
            runIteration ();
    }
}