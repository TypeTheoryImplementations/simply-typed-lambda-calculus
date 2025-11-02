-- Copyright (C) 2025 Lincoln Sand
-- SPDX-License-Identifier: MIT

module ParsingSpec where

import Test.Hspec

import Types
import Parser

import Text.Megaparsec (parse)

spec :: Spec
spec = do
    describe "Parser" $ do
        it "Parses a simple expression" $ do
            let input = "x"
            let expectedResult = SrcVariable "x"
            parse parseTopLevel "x" input `shouldBe` Right expectedResult
        it "Parses Single Param Arrow" $ do
            let input = "lambda x:Int.x"
            let expectedResult = SrcLambda "x" (TypeBase "Int") (SrcVariable "x")
            parse parseTopLevel "lambda x:Int.x" input `shouldBe` Right expectedResult
