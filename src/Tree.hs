module Tree where
  data Tree a = Node [(Tree a)] | Leaf a deriving (Show)

  instance Functor Tree where
    fmap f (Leaf a) = Leaf (f a)
    fmap f (Node list) = Node (map (fmap f) list)

  instance Applicative Tree where
    pure = Leaf
    (Leaf list) <*> something = fmap list something
    (Node list) <*> something = Node [ el <*> something | el <- list ]