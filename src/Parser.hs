-- Copyright (C) 2025 Lincoln Sand
-- SPDX-License-Identifier: MIT

module Parser (parseTopLevel) where

import qualified Data.Void as Void
import qualified Data.Text as T

import Data.Char (isAlphaNum)

import Text.Megaparsec (Parsec, notFollowedBy, takeWhileP, (<|>), some, try, empty, eof, between)
import qualified Text.Megaparsec.Char as ParsecChar
import qualified Text.Megaparsec.Char.Lexer as CharLexer

import Types

type Parser = Parsec Void.Void T.Text

spaceConsumer :: Parser ()
spaceConsumer = CharLexer.space ParsecChar.space1 (CharLexer.skipLineComment "--") empty

reservedKeywords :: [Name]
reservedKeywords = ["lambda"]

-- NOTE: Entry point into parser
parseTopLevel :: Parser SyntacticTerm
parseTopLevel = spaceConsumer *> parseSrcTerm <* spaceConsumer <* eof

parseLexeme :: Parser a -> Parser a
parseLexeme = CharLexer.lexeme spaceConsumer

identifierChar :: Parser Char
identifierChar = ParsecChar.alphaNumChar

isIdentTail :: Char -> Bool
isIdentTail = isAlphaNum

parseKeyword :: T.Text -> Parser T.Text
parseKeyword word = parseLexeme (ParsecChar.string word <* notFollowedBy identifierChar)

parseSymbol :: T.Text -> Parser T.Text
parseSymbol = CharLexer.symbol spaceConsumer

parseParens :: Parser a -> Parser a
parseParens = between (parseSymbol "(") (parseSymbol ")")

parseIdentifier :: Parser T.Text
parseIdentifier = parseLexeme $ do
    first <- ParsecChar.letterChar
    rest <- takeWhileP (Just "identifier tail") isIdentTail
    let ident = T.cons first rest
    if ident `elem` reservedKeywords
        then fail $ "keyword " <> T.unpack ident <> " cannot be used as an identifier"
        else return ident

parseSrcTerm :: Parser SyntacticTerm
parseSrcTerm
    =       parseSrcLambda
    <|>     parseSrcVar
    <|> try parseSrcApplication
    <|>     (parseParens $ parseSrcTerm)

parseSrcVar :: Parser SyntacticTerm
parseSrcVar = SrcVariable <$> parseIdentifier

parseSrcLambda :: Parser SyntacticTerm
parseSrcLambda = do
    _ <- parseKeyword "lambda"
    argName <- parseIdentifier
    _ <- parseSymbol ":"
    argType <- parseType
    _ <- parseSymbol "."
    body <- parseSrcTerm
    return $ SrcLambda argName argType body

parseSrcApplication :: Parser SyntacticTerm
parseSrcApplication = parseParens $ do
    func <- parseSrcTerm
    args <- some parseSrcTerm
    return $ foldl SrcApplication func args

parseType :: Parser Type
parseType
    =   try parseTopLevelArrowType
    <|>     parseBaseType

parseTopLevelArrowType :: Parser Type
parseTopLevelArrowType = do
    argType <- parseNestedType
    _ <- parseSymbol "->"
    returnType <- try parseTopLevelArrowType <|> parseNestedType
    return $ TypeArrow argType returnType

parseNestedType :: Parser Type
parseNestedType
    =   try parseGroupedArrowType
    <|>     parseBaseType

parseGroupedArrowType :: Parser Type
parseGroupedArrowType = parseParens $ parseTopLevelArrowType

parseBaseType :: Parser Type
parseBaseType = TypeBase <$> parseIdentifier
