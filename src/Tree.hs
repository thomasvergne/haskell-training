module Tree where
  data Tree a
    = Node [Tree a]
    | Leaf a
    deriving (Show)

  instance Functor Tree where
    fmap f (Leaf a) = Leaf $ f a
    fmap f (Node list) = Node $ map (fmap f) list

  instance Applicative Tree where
    pure = Leaf
    (Leaf f) <*> something = f <$> something
    (Node xs) <*> something = Node [ f <*> something | f <- xs ]

  instance Monad Tree where
    return = Leaf
    Leaf item >>= f = f item
    Node list >>= f = Node [ el >>= f | el <- list ]

  class TreeApplication f where
    (>>>) :: f a -> (a -> b) -> f b

  instance TreeApplication Tree where
    Leaf item >>> f = Leaf (f item)
    Node list >>> f = Node [ el >>> f | el <- list ]