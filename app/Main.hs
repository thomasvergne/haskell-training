import Tree

main :: IO()
main = do
  let tree = Node [Leaf 5, Node [Leaf 1]]
  print tree
  print $ tree >>= \x -> return (x + 5)
  print $ (Leaf 5) >>> (+5)
  print $ tree >>> (+5)