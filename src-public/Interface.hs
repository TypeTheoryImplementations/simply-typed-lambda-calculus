-- Copyright (C) 2025 Lincoln Sand
-- SPDX-License-Identifier: MIT

module Interface (typeCheckAndEvaluateFile, typeCheckAndEvaluateText) where

import qualified Data.Text as T
import qualified Data.Text.IO as TIO

import Text.Megaparsec (parse, errorBundlePretty)

import Parser
import TypeChecker
import BetaReduction
import DeBruijn
import Types

typeCheckAndEvalImpl :: String -> T.Text -> IO ()
typeCheckAndEvalImpl message src = case parse parseTopLevel message src of
    Left err            -> putStrLn $ errorBundlePretty err
    Right parsedForm    -> case typingSynth [(Just "free", TypeBase "Int")] alphaConvertedResult of
                                Left typeErr -> putStrLn $ "Type error: " <> typeErr
                                Right ty     -> putStrLn $ "Reduced form: " <> show (fullyBetaReduce alphaConvertedResult) <> ", Type: " <> show ty <> "."
                                where
                                    alphaConvertedResult = convertToDeBruijn parsedForm

typeCheckAndEvaluateFile :: FilePath -> IO ()
typeCheckAndEvaluateFile fp = do
    putStr $ fp <> ": "
    src <- TIO.readFile fp
    typeCheckAndEvalImpl fp src

typeCheckAndEvaluateText :: T.Text -> IO ()
typeCheckAndEvaluateText src = typeCheckAndEvalImpl "<input>" src
