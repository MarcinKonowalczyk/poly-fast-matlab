# poly-fast-matlab

Fast versions of Matlab's `polyval` and `polyfit` for sane people.

## Usage

Original `poly` functions are very good and useful, but they do a lot of not-always-necessary work (matrix condition checking), especially when one is in the middle of a tight `for`-loop. `poly_fast` functions do not do these checks, but assume the user is sane and knows what they're doing. It is recommended to **first** write one's code with normal `poly` functions, and then switch to the `poly_fast` once the code works fine. This can be done by simply replacing the calls to `polyfit` and `polyval` with ones to `polyfit_fast` and `polyval_fast`.

Note that teh `poly_fast` functions do not implement the alternate scale-and-shift syntax - `[p,S,mu] = polyfit(x,y,n)`. You'll have to do that yourself.

## Reusing the Vandermode matrix

`polyfit` works by inverting the [Vandermode matrix](https://mathworld.wolfram.com/VandermondeMatrix.html) - matrix who's columns are successive powers of the x-axis. It it relatively fast, but unnecessary, to construct it each time. This becomes a bit of a bottleneck especially for dense x-axis or high-degree polynomials. To mitigate this, `poly_fast` functions both output, and take the Vandermode matrix as an input. This allows it to be re-used, but results in a more significant code rewrite. See `example.m` for detail.

## Weighted fit

Additionally a `polyfit_weighted` function can perform a weighted least-squares fit in a similar manner to `polyfit_fast`.

## Performance

![Benchmark degree 1](./benchmark_1.png)
![Benchmark degree 10](./benchmark_10.png)

## ToDo's

 - [ ] Test whether QR decomposition of the Vandermode matrix helps