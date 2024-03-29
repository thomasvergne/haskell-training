{-# LANGUAGE GADTs, StandaloneDeriving #-}
module Complex.Quaternion where
  data Quaternion a = Quaternion a a a a

  deriving instance (Show a) => Show (Quaternion a)
  deriving instance (Eq a) => Eq (Quaternion a)

  instance Functor Quaternion where
    fmap f (Quaternion a b c d) = Quaternion (f a) (f b) (f c) (f d)

  instance Applicative Quaternion where
    pure x = Quaternion x x x x
    (Quaternion f g h j) <*> (Quaternion a b c d) = Quaternion (f a) (g b) (h c) (j d)

  instance Monad Quaternion where
    (Quaternion a b c d) >>= f = Quaternion a' b' c' d'
      where Quaternion a' _ _ _ = f a
            Quaternion _ b' _ _ = f b
            Quaternion _ _ c' _ = f c
            Quaternion _ _ _ d' = f d

  instance (RealFloat a, Num a, Fractional a) => Fractional (Quaternion a) where
    (Quaternion a b c d) / z@(Quaternion a' b' c' d') =
      Quaternion ((a * a' + b * b' + c * c' + d * d') / zNorm)
                 ((-a * b' + b * a' - c * d' + d * c') / zNorm)
                 ((-a * c' + b * d' + c * a' - d * b') / zNorm)
                 ((-a * d' - b * c' + c * b' + d * a') / zNorm)
      where
        zNorm = norm z

    fromRational a = Quaternion (fromRational a) 0 0 0

  instance RealFloat a => Floating (Quaternion a) where
    pi = (Quaternion pi 0 0 0)

    exp q@(Quaternion a b c d) =
      (Quaternion (exp a) 0 0 0) * (cosV + (v / normV) * sinV)
      where normV = abs v
            v = Quaternion 0 b c d
            realNormV = sqrt (norm v)
            cosV = (Quaternion (cos realNormV) 0 0 0)
            sinV = (Quaternion (sin realNormV) 0 0 0)

  instance (RealFloat a) => Num (Quaternion a) where
    (Quaternion a b c d) + (Quaternion a' b' c' d') =
      Quaternion (a + a') (b + b') (c + c') (d + d')

    (Quaternion a b c d) - (Quaternion a' b' c' d') =
      Quaternion (a - a') (b - b') (c - c') (d - d')

    (Quaternion a b c d) * (Quaternion a' b' c' d') =
      Quaternion (a * a' - b * b' - c * c' - d * d')
                 (a * b' + b * a' + c * d' - d * c')
                 (a * c' - b * d' + c * a' + d * b')
                 (a * d' + b * c' - c * b' + d * a')

    abs z = Quaternion (sqrt (norm z)) 0 0 0
    fromInteger a = Quaternion (fromInteger a) 0 0 0
    signum z = z / abs z

  norm :: (Num a, Floating a) => Quaternion a -> a
  norm (Quaternion a b c d) = (a**2) + (b**2) + (c**2) + (d**2)

  non :: (Num a) => Quaternion a -> Quaternion a
  non (Quaternion a b c d) = Quaternion a (-b) (-c) (-d)

  realPart :: Quaternion a -> a
  realPart (Quaternion a _ _ _) = a

  imagPart :: Quaternion a -> Int -> a
  imagPart (Quaternion _ a b c) y = case y of
    0 -> a
    1 -> b
    2 -> c
