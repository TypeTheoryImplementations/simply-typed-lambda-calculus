#!/usr/bin/env bash

cabal run simply-typed-lambda-calculus --               \
    tests/stlc/testsThatShouldPass/TestProgram1.stlc    \
    tests/stlc/testsThatShouldPass/TestProgram2.stlc    \
    tests/stlc/testsThatShouldPass/TestProgram3.stlc

cabal run simply-typed-lambda-calculus --               \
    tests/stlc/testsThatShouldFail/TestProgram1.stlc
