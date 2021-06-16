import Text.Printf
import Data.Time

type Point    = (Float, Float)
type Rect     = (Point,Float,Float)
type Triangle = (Point, Point, Point)

--Cores
-------------------------------------------------------------------------

gradientPalette :: Int -> Float -> [(Int,Int,Int,Float)]
gradientPalette n opacity
    | nrandom == 0 = [(r,g,b,o) | r <- increaselist, g <- [0], b <- decreaselist, o <- [opacity]]
    | nrandom == 1 = [(r,g,b,o) | r <- decreaselist, g <- [0], b <- increaselist, o <- [opacity]]
    | nrandom == 2 = [(r,g,b,o) | r <- [0], g <- increaselist, b <- decreaselist, o <- [opacity]]
    | nrandom == 3 = [(r,g,b,o) | r <- [0], g <- decreaselist, b <- increaselist, o <- [opacity]]
    | nrandom == 4 = [(r,g,b,o) | r <- increaselist, g <- decreaselist, b <- [0], o <- [opacity]]
    | otherwise = [(r,g,b,o) | r <- decreaselist, g <- increaselist, b <- [0], o <- [opacity]]
    where gap = 255 `div` n
          nrandom = n `mod` 6
          decreaselist = [0, gap..255]
          increaselist = reverse decreaselist
        

--Posicionamento
-------------------------------------------------------------------------

mirrorPos :: Char -> Point -> [Triangle] -> [Triangle]
mirrorPos position (w,h) triangles
    | position == 'x' = map (\((a,b), (c,d), (e,f)) -> (((w-a),b), ((w-c),d), ((w-e),f))) triangles --Mirror in x
    | position == 'y' = map (\((a,b), (c,d), (e,f)) -> ((a,(h-b)), (c,(h-d)), (e,(h-f)))) triangles --Mirror in y


genTriangles :: Int -> Point -> [Triangle]
genTriangles n (w,h) = xlist ++ ylist ++ (mirrorPos 'x' (w,h) xlist) ++ (mirrorPos 'y' (w,h) ylist)
    where xlist = [((a,b), center, (a,b/2)) | a <- [0], b <- [0, h/(fromIntegral (n-1)).. h - h/(fromIntegral (n-1))], center <- [(w/2, h/2)]]
          ylist = [((a,b), center, (a/2,b)) | a <- [0, w/(fromIntegral (n-1)).. w - w/(fromIntegral (n-1))], b <- [0], center <- [(w/2, h/2)]]

--Strings SVG
-------------------------------------------------------------------------
svgBegin :: Float -> Float -> String
svgBegin w h = printf "<svg width='%.2f' height='%.2f' xmlns='http://www.w3.org/2000/svg'>\n" w h 

svgEnd :: String
svgEnd = "</svg>"

svgStyle :: (Int,Int,Int,Float) -> String
svgStyle (r,g,b,o) = printf "fill:rgb(%d,%d,%d,%f); mix-blend-mode: screen;" r g b o

svgTriangle :: Triangle -> String -> String
svgTriangle ((a,b), (c,d), (e,f)) style =
    printf "<polygon points='%.3f,%.3f %.3f,%.3f %.3f,%.3f' style='%s' />\n" a b c d e f style

svgRect :: Rect -> String -> String 
svgRect ((x,y),w,h) style = 
  printf "<rect x='%.3f' y='%.3f' width='%.2f' height='%.2f' style='%s' />\n" x y w h style

svgElements :: (a -> String -> String) -> [a] -> [String] -> String
svgElements func elements styles = concat $ zipWith func elements styles

--Main
-------------------------------------------------------------------------
main :: IO ()
main = do
    writeFile "fig.svg" $ svgstrs
    where svgstrs = svgBegin w h ++ svgbackground ++ svgtriangles ++ svgEnd
          svgbackground = svgElements svgRect [((0.0, 0.0), w, h)] [svgStyle (head trianglespalette)]
          svgtriangles = svgElements svgTriangle triangles (map svgStyle trianglespalette)
          triangles = genTriangles n (w,h)
          trianglespalette = gradientPalette n 0.8  --Aqui é possivel ajustar a opacidade do desenho
          n = 7
          (w,h) = (1200, 500)
