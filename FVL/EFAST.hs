{-# LANGUAGE FlexibleInstances #-}

module FVL.EFAST
( Expr(..)
) where

import FVL.Algebra

data Expr a
    = CInt Integer
    | CBool Bool
    | CVar String
    | Add a a 
    | Sub a a 
    | Mul a a 
    | Div a a 
    | Mod a a
    | And a a 
    | Or a a 
    | Not a
    | Equal a a 
    | Less a a
    | LessEq a a
    | Great a a
    | GreatEq a a
    | Empty
    | Cons a a
    | If a a a 
    | Function String a
    | Appl a a 
    | Let String [String] a a 
    | Semi a a
    | Case a a String String a

instance Functor Expr where
    fmap eval (CInt n) = CInt n
    fmap eval (CBool b) = CBool b
    fmap eval (CVar s) = CVar s
    fmap eval (x `Add` y) = eval x `Add` eval y
    fmap eval (x `Sub` y) = eval x `Sub` eval y
    fmap eval (x `Mul` y) = eval x `Mul` eval y
    fmap eval (x `Div` y) = eval x `Div` eval y
    fmap eval (x `Mod` y) = eval x `Mod` eval y
    fmap eval (x `And` y) = eval x `And` eval y
    fmap eval (x `Or` y) = eval x `Or` eval y
    fmap eval (Not x) = Not $ eval x
    fmap eval (x `Equal` y) = eval x `Equal` eval y
    fmap eval (x `Less` y) = eval x `Less` eval y
    fmap eval (x `LessEq` y) = eval x `LessEq` eval y
    fmap eval (x `Great` y) = eval x `Great` eval y
    fmap eval (x `GreatEq` y) = eval x `GreatEq` eval y
    fmap eval Empty = Empty
    fmap eval (x `Cons` y) = eval x `Cons` eval y
    fmap eval (If p e1 e2) = If (eval p) (eval e1) (eval e2)
    fmap eval (Function s p) = Function s (eval p)
    fmap eval (Appl f x) = Appl (eval f) (eval x)
    fmap eval (Let s a x y) = Let s a (eval x) (eval y)
    fmap eval (Semi x y) = Semi (eval x) (eval y)
    fmap eval (Case p x s t y) = Case (eval p) (eval x) s t (eval y)

showCons' :: Fix Expr -> [Fix Expr]
showCons' (Fx (x `Cons` y)) = x : showCons' y
showCons' e = [e]

showCons :: Fix Expr -> Fix Expr -> String
showCons x y = "[" ++ (foldr combine (show x) (showCons' y)) ++ "]"
    where combine (Fx Empty) b = b
          combine a b = b ++ ", " ++ show a

instance Show (Fix Expr) where
    show (Fx (CInt n)) = show n
    show (Fx (CBool b)) = show b
    show (Fx (CVar s)) = s
    show (Fx (x `Add` y)) = show x ++ " + " ++ show y
    show (Fx (x `Sub` y)) = show x ++ " - " ++ show y
    show (Fx (x `Mul` y)) = show x ++ " * " ++ show y
    show (Fx (x `Div` y)) = show x ++ " / " ++ show y
    show (Fx (x `Mod` y)) = show x ++ " % " ++ show y
    show (Fx (x `And` y)) = show x ++ " && " ++ show y
    show (Fx (x `Or` y)) = show x ++ " || " ++ show y
    show (Fx (Not x)) = "!" ++ (case x of
        (Fx (CBool b)) -> show b
        (Fx (CVar s)) -> s
        _ -> "(" ++ show x ++ ")")
    show (Fx (x `Equal` y)) = show x ++ " = " ++ show y
    show (Fx (x `Less` y)) = show x ++ " < " ++ show y
    show (Fx (x `LessEq` y)) = show x ++ " <= " ++ show y
    show (Fx (x `Great` y)) = show x ++ " > " ++ show y
    show (Fx (x `GreatEq` y)) = show x ++ " >= " ++ show y
    show (Fx Empty) = "[]"
    show (Fx (x `Cons` y)) = showCons x y
    show (Fx (If p x y)) = "If " ++ show p ++ " Then " ++ show x ++ " Else " ++ show y
    show (Fx (Function x p)) = "Function " ++ x ++ " -> " ++ show p
    show (Fx (Appl f x)) = (case f of
        (Fx (CInt n)) -> show n ++ " "
        (Fx (CBool b)) -> show b ++ " "
        (Fx (CVar s)) -> s ++ " "
        (Fx (Appl _ _)) -> show f ++ " "
        _ -> "(" ++ show f ++ ") ") ++ (case x of
            (Fx (CInt n)) -> show n
            (Fx (CBool b)) -> show b
            (Fx (CVar s)) -> s
            (Fx (Appl _ _)) -> show x
            _ -> "(" ++ show x ++ ")")
    show (Fx (Let f a p e))
        = "Let " ++ f ++ show_args ++ " = " ++ show p ++ " In " ++ show e
        where show_args = foldr (\x s -> " " ++ x ++ s) "" a
    show (Fx (Case p x s t y)) = "Case " ++ show x ++ " Of [] -> " ++ show x
        ++ " | (" ++ s ++ ", " ++ t ++ ") -> " ++ show y
