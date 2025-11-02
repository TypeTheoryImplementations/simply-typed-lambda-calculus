-- Copyright (C) 2025 Lincoln Sand
-- SPDX-License-Identifier: MIT

module DeBruijn (convertToDeBruijn, shift, substitute) where

import Data.List (elemIndex)

import Types

-- Performs alpha conversion by turning a parsed term into one where bound names are replaced by De Bruijn indices
convertToDeBruijn :: SyntacticTerm -> DeBruijnTerm
convertToDeBruijn = convertToDeBruijnImpl []
    where
        convertToDeBruijnImpl :: [Name] -> SyntacticTerm -> DeBruijnTerm
        convertToDeBruijnImpl env (SrcVariable name) = case name `elemIndex` env of
            Just idx -> CoreBound idx
            Nothing -> CoreFree name
        convertToDeBruijnImpl env (SrcLambda paramName paramType body) =
            CoreAbstraction paramType (convertToDeBruijnImpl (paramName:env) body)
        convertToDeBruijnImpl env (SrcApplication func arg) =
            CoreApplication (convertToDeBruijnImpl env func) (convertToDeBruijnImpl env arg)

shift :: Int -> DeBruijnTerm -> DeBruijnTerm
shift distance = shiftImpl 0
    where
        shiftImpl :: Int -> DeBruijnTerm -> DeBruijnTerm
        shiftImpl cutoff (CoreBound idx)    | idx >= cutoff = CoreBound (idx + distance)
                                            | otherwise = CoreBound idx
        shiftImpl _ (CoreFree name) =
            CoreFree name
        shiftImpl cutoff (CoreAbstraction paramType body) =
            CoreAbstraction paramType (shiftImpl (cutoff+1) body)
        shiftImpl cutoff (CoreApplication func arg) =
            CoreApplication (shiftImpl cutoff func) (shiftImpl cutoff arg)

substitute :: Int -> DeBruijnTerm -> DeBruijnTerm -> DeBruijnTerm
substitute old new = substituteImpl 0
    where
        substituteImpl :: Int -> DeBruijnTerm -> DeBruijnTerm
        substituteImpl cutoff (CoreBound idx)   | idx == (old+cutoff) = shift cutoff new
                                                | otherwise = CoreBound idx
        substituteImpl _ (CoreFree name) =
            CoreFree name
        substituteImpl cutoff (CoreAbstraction paramType body) =
            CoreAbstraction paramType (substituteImpl (cutoff+1) body)
        substituteImpl cutoff (CoreApplication func arg) =
            CoreApplication (substituteImpl cutoff func) (substituteImpl cutoff arg)
