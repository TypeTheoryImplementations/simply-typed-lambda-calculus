-- Copyright (C) 2025 Lincoln Sand
-- SPDX-License-Identifier: MIT

module TypeChecker (typingSynth) where

import Data.List ((!?))

import qualified Data.Text as T

import Types

findFreeVar :: Name -> Context -> Maybe Type
findFreeVar name ctx = lookup (Just name) ctx

typingSynth :: Context -> DeBruijnTerm -> Either Error Type
-- Variable Type Rule:
-- If x : A ∈ Γ, then Γ ⊢ x : A
typingSynth ctx (CoreFree name) = case findFreeVar name ctx of
    Just varType -> return varType
    Nothing  -> Left $ "Free variable missing from context: " <> (T.unpack name) <> "."
typingSynth ctx (CoreBound idx) = case ctx !? idx of
    Just (_, ty) -> return ty
    Nothing      -> Left $ "DeBruijn index not in context: " <> show idx <> "."
-- Abstraction Type Rule:
-- If Γ, x : A ⊢ t : B, then Γ ⊢ λx:A.t : A → B
typingSynth ctx (CoreAbstraction paramType body) =
    TypeArrow paramType <$> typingSynth ((Nothing, paramType):ctx) body
-- Application Type Rule:
-- If Γ ⊢ f : A → B and Γ ⊢ a : A, then Γ ⊢ f a : B
typingSynth ctx (CoreApplication func arg) = do
    funcType <- typingSynth ctx func
    argType <- typingSynth ctx arg
    case funcType of
        TypeArrow paramType bodyType    | paramType == argType -> return bodyType
                                        | otherwise -> Left $ "Type mismatch in application: expected " <> show paramType <> ", got " <> show argType <> "."
        _ -> Left $ "Function type expected, got: " <> show funcType <> "."
