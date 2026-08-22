-- Copyright (C) 2025 Lincoln Sand
-- SPDX-License-Identifier: MIT

module Types (Name, Error, Context, Type(..), SyntacticTerm(..), DeBruijnTerm(..)) where

import qualified Data.Text as T

type Name = T.Text -- [a-zA-Z] or [0-9] (first character must be a letter)

type Error = String

type Context = [(Maybe Name, Type)]

data Type
    = TypeBase Name
    | TypeArrow Type Type
    deriving (Eq, Show)

data SyntacticTerm
    = SrcVariable Name
    | SrcLambda Name Type SyntacticTerm
    | SrcApplication SyntacticTerm SyntacticTerm
    deriving (Eq, Show)

data DeBruijnTerm
    = CoreBound Int
    | CoreFree Name
    | CoreAbstraction Type DeBruijnTerm
    | CoreApplication DeBruijnTerm DeBruijnTerm
    deriving (Eq, Show)
