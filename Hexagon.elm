module Hexagon exposing (Point, Hexagon, p, hex, svgHexagon)

{-| Create SVG hexagons with rounded corners

# Definition
@docs Point, Hexagon

# Common Helpers
@docs p, hex

# Rendering
@docs svgHexagon

-}

import List
import String
import Svg exposing (..)
import Svg.Attributes exposing (..)

{-| Point definition to define hexagon center & corner points |-}
type alias Point =
    { x : Float
    , y : Float
    }

{-| Hexagon definition to generate SVG tags from |-}
type alias Hexagon =
    { center : Point
    , rotation : Float
    , radius : Float
    }

{-| Shortcut to create a `Point` |-}
p : Float -> Float -> Point
p =
    Point

{-| Shortcut to create a `Hexagon` |-}
hex : Point -> Float -> Float -> Hexagon
hex =
    Hexagon


calculateCorners : Hexagon -> List Point
calculateCorners hexagon =
    let
        rotate =
            pi / 180 * hexagon.rotation

        radius =
            hexagon.radius

        center =
            hexagon.center

        pointFor t =
            p (radius * (sin t) + center.x) (radius * (cos t) + center.y)

        calculatePoint corner =
            pointFor (pi / 3 * corner + rotate)
    in
        List.map calculatePoint [0..5]


calculateRounding : Point -> Point -> Point -> ( Point, Point, Point )
calculateRounding right current left =
    let
        percentage =
            0.18

        adapt point =
            { point
                | x = ((point.x - current.x) * percentage) + current.x
                , y = ((point.y - current.y) * percentage) + current.y
            }
    in
        ( adapt right, current, adapt left )


drawRounding : String -> ( Point, Point, Point ) -> String
drawRounding prefix ( start, control, end ) =
    String.concat
        [ prefix ++ (String.join "," (List.map toString [ start.x, start.y ]))
        , "Q" ++ (String.join "," (List.map toString [ control.x, control.y, end.x, end.y ]))
        ]

{-| Create a SVG path for a `Hexagon` definition |-}
svgHexagon : List (Attribute msg) -> Hexagon -> Svg msg
svgHexagon attrs hexagon =
    let
        corners =
            calculateCorners hexagon

        toEnd n xs =
            (List.drop n xs) ++ (List.take n xs)

        roundings =
            List.map3 calculateRounding corners (toEnd 1 corners) (toEnd 2 corners)

        sections =
            Maybe.map2 (,) (List.head roundings) (List.tail roundings)
    in
        case sections of
            Just (x, xs) ->
                Svg.path
                    ([ d (String.concat ((drawRounding "M" x) :: (List.map (drawRounding "L") xs)))] ++ attrs)
                    []

            Nothing ->
                text ""
