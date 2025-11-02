-- Copyright (C) 2025 Lincoln Sand
-- SPDX-License-Identifier: MIT

module Main where

import System.Environment (getArgs)

import Interface

main :: IO ()
main = do
    filePaths <- getArgs
    mapM_ typeCheckAndEvaluateFile filePaths
