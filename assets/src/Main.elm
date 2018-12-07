port module Main exposing (main)

import Browser
import Browser.Events
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Svg exposing (Svg, polyline)
import Svg.Attributes exposing (fill, points, stroke)
import Time


type alias Point =
    ( Int, Int )


type alias Path =
    { id : Int
    , points : List Point
    }


type Model
    = Recording Path (List Path)
    | Stable (List Path)


toList : Model -> List Path
toList model =
    case model of
        Recording head tail ->
            head :: tail

        Stable list ->
            list


type alias Flags =
    ()


initialPaths : List Path
initialPaths =
    []


initialize : Flags -> ( Model, Cmd Msg )
initialize flags =
    ( Stable initialPaths, Cmd.none )


svgPoint : Point -> String
svgPoint ( x, y ) =
    String.fromInt x ++ "," ++ String.fromInt y


svgPathString : Path -> String
svgPathString path =
    String.join " " (List.map svgPoint path.points)


startRecording : Model -> Model
startRecording model =
    case model of
        Recording _ _ ->
            model

        Stable paths ->
            Recording { id = nextId paths, points = [] } paths


addForeignPath : Path -> Model -> Model
addForeignPath path model =
    case model of
        Recording current paths ->
            Recording current (path :: paths)

        Stable paths ->
            Stable (path :: paths)


nextId : List Path -> Int
nextId paths =
    paths
        |> List.map .id
        |> List.maximum
        |> Maybe.withDefault 0
        |> (+) 1


stopRecording : Model -> Model
stopRecording model =
    case model of
        Recording _ _ ->
            Stable (toList model)

        Stable _ ->
            model


addPoint : Point -> Model -> Model
addPoint point model =
    case model of
        Recording current rest ->
            Recording { current | points = point :: current.points } rest

        Stable _ ->
            model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DrawStarted ->
            ( startRecording model, Cmd.none )

        DrawEnded ->
            ( stopRecording model, sendBuildingPoints model )

        PointAdded point ->
            ( addPoint point model, Cmd.none )

        NetworkClockTick ->
            ( model, sendBuildingPoints model )

        RemotePathReceived (Ok path) ->
            ( addForeignPath path model, Cmd.none )

        RemotePathReceived (Err _) ->
            ( model, Cmd.none )


sendBuildingPoints : Model -> Cmd a
sendBuildingPoints model =
    buildingPoints model
        |> Maybe.map (sendPoints << encodePath)
        |> Maybe.withDefault Cmd.none


buildingPoints : Model -> Maybe Path
buildingPoints model =
    case model of
        Recording current _ ->
            Just current

        Stable _ ->
            Nothing


viewPath : Path -> Svg a
viewPath path =
    polyline [ points (svgPathString path), fill "none", stroke "black" ] []


view : Model -> Html Msg
view model =
    Svg.svg
        [ style "position" "absolute"
        , style "width" "100%"
        , style "height" "100%"
        ]
        (List.map viewPath <| toList model)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Recording _ _ ->
            Sub.batch
                [ Browser.Events.onMouseUp (Decode.succeed DrawEnded)
                , Sub.map PointAdded (Browser.Events.onMouseMove mousePositionDecoder)
                , Time.every 50 (\_ -> NetworkClockTick)
                , incomingPaths (RemotePathReceived << Decode.decodeValue pathDecoder)
                ]

        Stable _ ->
            Sub.batch
                [ Browser.Events.onMouseDown (Decode.succeed DrawStarted)
                , incomingPaths (RemotePathReceived << Decode.decodeValue pathDecoder)
                ]


mousePositionDecoder : Decoder Point
mousePositionDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "clientX" Decode.int)
        (Decode.field "clientY" Decode.int)


type Msg
    = DrawStarted
    | DrawEnded
    | PointAdded Point
    | NetworkClockTick
    | RemotePathReceived (Result Decode.Error Path)


port sendPoints : Decode.Value -> Cmd a


port incomingPaths : (Decode.Value -> a) -> Sub a


encodePath : Path -> Decode.Value
encodePath path =
    Encode.object
        [ ( "id", Encode.int path.id )
        , ( "points", Encode.list encodePoint path.points )
        ]


encodePoint : Point -> Decode.Value
encodePoint ( x, y ) =
    Encode.object
        [ ( "x", Encode.int x )
        , ( "y", Encode.int y )
        ]


pathDecoder : Decoder Path
pathDecoder =
    Decode.map2 (\id points -> { id = id, points = points })
        (Decode.field "id" Decode.int)
        (Decode.field "points" (Decode.list pointDecoder))


pointDecoder : Decoder Point
pointDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "x" Decode.int)
        (Decode.field "y" Decode.int)


main : Program Flags Model Msg
main =
    Browser.element
        { init = initialize
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
