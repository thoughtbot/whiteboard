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
import Svg.Attributes exposing (fill, points, stroke, strokeWidth)
import Task
import Time
import Uuid exposing (Uuid)


type alias Point =
    ( Float, Float )


type Email
    = Email String


type alias Path =
    { id : Uuid
    , points : List Point
    , email : Email
    }


type alias State =
    { existing : List Path
    , svgElement : Browser.Dom.Element
    , email : Email
    }


type Model
    = Loading Email (List Path)
    | Stable State
    | Recording Path State


toList : Model -> List Path
toList model =
    case model of
        Loading _ paths ->
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


flagDecoder : Decoder ( Email, List Path )
flagDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "email" emailDecoder)
        (Decode.field "paths" <| Decode.list pathDecoder)


initialize : Flags -> ( Model, Cmd Msg )
initialize flags =
    case Decode.decodeValue flagDecoder flags of
        Err _ ->
            ( Loading (Email "i failed") [], fetchSvgCoords )

        Ok ( email, initialPaths ) ->
            ( Loading email initialPaths, fetchSvgCoords )


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
        Loading _ _ ->
            model

        Recording _ _ ->
            model

        Stable state ->
            Recording { email = state.email, id = uuid, points = [] } state


addForeignPath : Path -> Model -> Model
addForeignPath path model =
    case model of
        Loading email paths ->
            Loading email (path :: paths)

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
        Loading _ _ ->
            model

        Recording _ state ->
            Stable { state | existing = toList model }

        Stable _ ->
            model


addPoint : Point -> Model -> Model
addPoint point model =
    case model of
        Loading _ _ ->
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
        Loading email existing ->
            Stable { email = email, svgElement = element, existing = existing }

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
        Loading _ _ ->
            Nothing

        Recording current _ ->
            Just current

        Stable _ ->
            Nothing


strokeColorFor : Email -> String
strokeColorFor (Email email) =
    case email of
        "joelq@thoughtbot.com" ->
            "purple"

        "alex@thoughtbot.com" ->
            "blue"

        "german@thoughtbot.com" ->
            "green"

        "chris@thoughtbot.com" ->
            "orange"

        _ ->
            "black"


viewPath : Path -> Svg a
viewPath path =
    polyline
        [ points (svgPathString path)
        , fill "none"
        , stroke (strokeColorFor path.email)
        , strokeWidth "10px"
        ]
        []


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
        Loading _ _ ->
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
    Decode.map3 Path
        (Decode.field "id" Uuid.decoder)
        (Decode.field "points" (Decode.list pointDecoder))
        (Decode.field "email" emailDecoder)


emailDecoder : Decoder Email
emailDecoder =
    Decode.map Email Decode.string


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
