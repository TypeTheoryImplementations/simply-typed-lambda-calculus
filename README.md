# <p align="center"> Simply-Typed-Lambda-Calculus </p>

<p align="center">
<a href="https://mit-license.org/">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT"></img>
</a>
</p>

## What is Simply-Typed Lambda Calculus? What is supported?

My implementation supports a very vanilla version of Simply-Typed Lambda Calculus (STLC). It does have a few minor extensions though as follows:

- `A -> B -> C` is automatically turned into `A -> (B -> C)`. You can also explicitly write the second form.

- You can do `(f a b)` and it will implicitly do `((f a) b)` for function application.

- There is also some more liberal parsing around grouping parentheses around terms.

Otherwise, see the following for all other features: https://en.wikipedia.org/wiki/Simply_typed_lambda_calculus.

## What is the architecture of the implementation?

The implementation uses MegaParsec for parsing. It then converts the parsed form into one using De Bruijn indices for all bound variables (which turns alpha equivalence into simple structural equivalence). It then infers the type of the whole expression using a single simple `typingSynth` function that implements the 3 typing rules. Finally, it performs beta reduction to normalize the well-typed program.

## What is the license for this code?

All code in this repository is licensed under the MIT license. A copy of this can be found in `LICENSE`. Additionally, all source code files in this repository should also contain a copyright header specifying this.

This code also uses the library [megaparsec](https://github.com/mrkkrp/megaparsec). In compliance with its license (BSD 2-clause), a copy of megaparsec's license can be found at `LICENSE-megaparsec.md`.

## How to use?

This is a standard Haskell cabal package, so it can be cloned, built, and ran like any other cabal package.

The program accepts a list of Simply-Typed Lambda Calculus source file names and outputs whether or not they are valid. If they are valid, it will print out the normalized beta reduced form (it will use De Bruijn indices for bound variable names). An example for how to use can be found in the `runTests.sh` shell script if on Linux.

