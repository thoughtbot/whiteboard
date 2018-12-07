port module Main exposing (main)

import Browser
import Browser.Dom
import Browser.Events
import Html exposing (..)
import Html.Attributes exposing (id, style)
import Html.Events exposing (onClick, onMouseDown)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Random
import Svg exposing (Svg, polyline)
import Svg.Attributes exposing (fill, points, stroke)
import Task
import Time
import Uuid exposing (Uuid)


type alias Point =
    ( Float, Float )


type alias Path =
    { id : Uuid
    , points : List Point
    }


type alias State =
    { existing : List Path
    , svgElement : Browser.Dom.Element
    }


type Model
    = Loading (List Path)
    | Stable State
    | Recording Path State


toList : Model -> List Path
toList model =
    case model of
        Loading paths ->
            paths

        Recording head state ->
            head :: state.existing

        Stable state ->
            state.existing


type alias Flags =
    Decode.Value


drawingSurface : String
drawingSurface =
    "drawing-surface"


initialize : Flags -> ( Model, Cmd Msg )
initialize flags =
    case Decode.decodeValue (Decode.list pathDecoder) flags of
        Err _ ->
            ( Loading [], fetchSvgCoords )

        Ok initialPaths ->
            ( Loading initialPaths, fetchSvgCoords )


fetchSvgCoords : Cmd Msg
fetchSvgCoords =
    Task.attempt ReceiveSvgCoords <| Browser.Dom.getElement drawingSurface


svgPoint : Point -> String
svgPoint ( x, y ) =
    String.fromFloat x ++ "," ++ String.fromFloat y


svgPathString : Path -> String
svgPathString path =
    String.join " " (List.map svgPoint path.points)


startRecording : Uuid -> Model -> Model
startRecording uuid model =
    case model of
        Loading _ ->
            model

        Recording _ _ ->
            model

        Stable paths ->
            Recording { id = uuid, points = [] } paths


addForeignPath : Path -> Model -> Model
addForeignPath path model =
    case model of
        Loading paths ->
            Loading (path :: paths)

        Recording current state ->
            Recording current (addPath path state)

        Stable state ->
            Stable (addPath path state)


addPath : Path -> State -> State
addPath path state =
    { state | existing = path :: state.existing }


stopRecording : Model -> Model
stopRecording model =
    case model of
        Loading _ ->
            model

        Recording _ state ->
            Stable { state | existing = toList model }

        Stable _ ->
            model


addPoint : Point -> Model -> Model
addPoint point model =
    case model of
        Loading _ ->
            model

        Recording current rest ->
            Recording { current | points = offsetPoint rest.svgElement point :: current.points } rest

        Stable _ ->
            model


offsetPoint : Browser.Dom.Element -> Point -> Point
offsetPoint { element, viewport } ( x, y ) =
    ( x - element.x + viewport.x, y - element.y + viewport.y )


addCoords : Browser.Dom.Element -> Model -> Model
addCoords element model =
    case model of
        Loading existing ->
            Stable { svgElement = element, existing = existing }

        Recording current state ->
            Recording current { state | svgElement = element }

        Stable state ->
            Stable { state | svgElement = element }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveSvgCoords (Err _) ->
            ( model, Cmd.none )

        ReceiveSvgCoords (Ok element) ->
            ( addCoords element model, Cmd.none )

        DrawStarted ->
            ( model, Random.generate UuuidCreated Uuid.uuidGenerator )

        UuuidCreated uuid ->
            ( startRecording uuid model, Cmd.none )

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

        UserScrolled ->
            ( model, fetchSvgCoords )

        WindowResized ->
            ( model, fetchSvgCoords )


sendBuildingPoints : Model -> Cmd a
sendBuildingPoints model =
    buildingPoints model
        |> Maybe.map (sendPoints << encodePath)
        |> Maybe.withDefault Cmd.none


buildingPoints : Model -> Maybe Path
buildingPoints model =
    case model of
        Loading _ ->
            Nothing

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
        , onMouseDown DrawStarted
        , id drawingSurface
        ]
        (List.map viewPath <| toList model)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Loading _ ->
            incomingPaths (RemotePathReceived << Decode.decodeValue pathDecoder)

        Recording _ _ ->
            Sub.batch
                [ Browser.Events.onMouseUp (Decode.succeed DrawEnded)
                , Sub.map PointAdded (Browser.Events.onMouseMove mousePositionDecoder)
                , Time.every 50 (\_ -> NetworkClockTick)
                , incomingPaths (RemotePathReceived << Decode.decodeValue pathDecoder)
                , scrollEvents (always UserScrolled)
                , Browser.Events.onResize (\_ _ -> WindowResized)
                ]

        Stable _ ->
            Sub.batch
                [ Browser.Events.onMouseDown (Decode.succeed DrawStarted)
                , incomingPaths (RemotePathReceived << Decode.decodeValue pathDecoder)
                , scrollEvents (always UserScrolled)
                , Browser.Events.onResize (\_ _ -> WindowResized)
                ]


mousePositionDecoder : Decoder Point
mousePositionDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "clientX" Decode.float)
        (Decode.field "clientY" Decode.float)


type Msg
    = DrawStarted
    | DrawEnded
    | PointAdded Point
    | NetworkClockTick
    | RemotePathReceived (Result Decode.Error Path)
    | UuuidCreated Uuid
    | ReceiveSvgCoords (Result Browser.Dom.Error Browser.Dom.Element)
    | UserScrolled
    | WindowResized


port sendPoints : Decode.Value -> Cmd a


port incomingPaths : (Decode.Value -> a) -> Sub a


port scrollEvents : (Decode.Value -> a) -> Sub a


encodePath : Path -> Decode.Value
encodePath path =
    Encode.object
        [ ( "id", Uuid.encode path.id )
        , ( "points", Encode.list encodePoint path.points )
        ]


encodePoint : Point -> Decode.Value
encodePoint ( x, y ) =
    Encode.object
        [ ( "x", Encode.float x )
        , ( "y", Encode.float y )
        ]


pathDecoder : Decoder Path
pathDecoder =
    Decode.map2 (\id points -> { id = id, points = points })
        (Decode.field "id" Uuid.decoder)
        (Decode.field "points" (Decode.list pointDecoder))


pointDecoder : Decoder Point
pointDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "x" Decode.float)
        (Decode.field "y" Decode.float)


main : Program Flags Model Msg
main =
    Browser.element
        { init = initialize
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
