{-# LANGUAGE GADTs #-}
module Complex.Complex where
data Complex a where
  Complex :: (Num a) => a -> a -> Complex a

instance (Show a, Ord a) => Show (Complex a) where
  show (Complex a b) =
     (if a /= 0 then show a else "")
     ++
     (if b /= 0 then
       if b > 0 then
         if a /= 0 then " + " ++ show b ++ "i" else show b ++ "i"
       else
         if a == 0 then "-" ++ show (abs b) ++ "i" else " - " ++ show (abs b) ++ "i"
     else
      "")

instance (Num a, Fractional a, RealFloat a) => Fractional (Complex a) where
  (Complex a b) / (Complex c d) = (Complex ((a*c + b*d) / k) ((b*c - a*d) / k))
    where k = c^2 + d^2
  fromRational a = Complex (fromRational a) 0

instance (Num a, Eq a) => Eq (Complex a) where
  (Complex a b) == (Complex c d) = a == c && b == d
  (Complex a b) /= (Complex c d) = a /= c || b /= d

instance (RealFloat a) => Floating (Complex a) where
  pi = Complex pi 0
  exp (Complex a b) = Complex (xp * cos b) (xp * sin b)
    where xp = exp a
  log z = Complex (log (realPart (abs z))) (phase z)

  a ** b | (realPart b) == 1 = a
         | (realPart b) == 0 = 1
         | otherwise = exp (log a * b)

  sqrt a = complexRoot a 2

  sin (Complex a b) = Complex (sin a * cosh b) (cos a * sinh b)
  cos (Complex a b) = Complex (cos a * cosh b) (- sin a * sinh b)
  tan z = sin z / cos z

  sinh (Complex a b) = Complex (cos b * sinh a) (sin b * cosh a)
  cosh (Complex a b) = Complex (cos b * cosh a) (sin b * sinh a)
  tanh z = sinh z / cosh z

  asin z@(Complex a b) = Complex a' (-b')
    where (Complex a' b') = log (Complex (-b) a) + sqrt (1 - z**2)

  acos z = Complex b'' (-a'')
    where (Complex a'' b'') = log (z + (Complex (-b') a'))
          (Complex a' b') = sqrt (1 - z**2)

  atan z@(Complex a b) = Complex b' (-a')
    where (Complex a' b') = log (Complex (1 - b') a) / sqrt (1 + z**2)

  asinh z = log (z + sqrt (1 + z**2))
  acosh z = log (z + (sqrt (z + 1)) * (sqrt (z-1)))
  atanh z = 0.5 * log ((1.0 + z) / (1.0 - z))

instance (RealFloat a) => Num (Complex a) where
  (Complex a b) * (Complex c d) = (Complex (a * c - b * d) (a * d + b * c))
  (Complex a b) + (Complex c d) = (Complex (a + c) (b + d))
  (Complex a b) - (Complex c d) = (Complex (a - c) (b - d))

  abs (Complex a b) = Complex (sqrt (a^2 + b^2)) 0
  fromInteger b = Complex (fromInteger b) 0

  signum (Complex 0 0) = 0
  signum (Complex a b) = z / (abs z)
    where z = (Complex a b)

non :: (Num a) => Complex a -> Complex a
non (Complex a b) = (Complex a (-b))

phase :: (RealFloat a) => Complex a -> a
phase (Complex a b) = atan2 b a

realPart :: (Num a) => Complex a -> a
realPart (Complex a _) = a

imaginaryPart :: (Num a) => Complex a -> a
imaginaryPart (Complex a _) = a

complexRoot :: (Num a, Fractional a, RealFloat a) => Complex a -> a -> Complex a
complexRoot z n | n == 0 = 1
                | n == 1 = z
                | otherwise = z**(Complex (1/n) 0)

cmap :: (Num a) => (a -> a) -> Complex a -> Complex a
cmap f (Complex a b) = (Complex (f a) (f b))