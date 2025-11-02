-- Copyright (C) 2025 Lincoln Sand
-- SPDX-License-Identifier: MIT

module BetaReduction (singleBetaReduce, fullyBetaReduce) where

import Control.Applicative ((<|>))
import Data.Maybe (fromMaybe)

import Types
import DeBruijn

-- Reduces a De Bruijn term by performing exactly a single beta reduction step, if possible.
--  NOTE: It returns `Nothing` if the input term is already in normalized form.
--  NOTE: This is what is known as "full beta" reduction, in contrast with weak beta reduction.
betaReduction :: DeBruijnTerm -> Maybe DeBruijnTerm
betaReduction (CoreApplication (CoreAbstraction _ func) arg) =
    return $ shift (-1) (substitute 0 (shift 1 arg) func)
betaReduction (CoreApplication func arg) =
    -- <|> tries the first one and then does the second if it returns `Maybe`
        (CoreApplication <$> betaReduction func <*> pure arg)
    <|> (CoreApplication func <$> betaReduction arg)
betaReduction (CoreAbstraction ty term) =
    CoreAbstraction ty <$> betaReduction term
betaReduction _ = Nothing

singleBetaReduce :: DeBruijnTerm -> DeBruijnTerm
singleBetaReduce = fromMaybe <*> betaReduction

fullyBetaReduce :: DeBruijnTerm -> DeBruijnTerm
fullyBetaReduce term = maybe term fullyBetaReduce (betaReduction term)
