{- This file re-implements the Elm Counter example (1 counter) with elm-mdl
   buttons. Use this as a starting point for using elm-mdl components in your own
   app.
-}


module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Material
import Material.Scheme
import Material.Button as Button
import Material.Options as Options exposing (css)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (..)
import Http


-- MODEL


type alias Model =
    { username: String,
    password: String,
    token: String,
    errorMsg: String,
    count : Int
    , mdl :
        Material.Model
        -- Boilerplate: model store for any and all Mdl components you use.
    }


model : Model
model =
    {
     username = "",
     password = "",
     token = "",
     errorMsg = "",
    count = 0
    , mdl =
        Material.model
        -- Boilerplate: Always use this initial Mdl model store.
    }

init : Maybe Model -> ( Model, Cmd Msg )
init model =
    case model of
        Just model ->
            ( model )

        Nothing ->
            ( Model "" "" "" "" "" "" )

-- ACTION, UPDATE


type Msg
    = Increase
    | Reset
    | Mdl (Material.Msg Msg)

-- API requests URLS

api : String
api =
    "http://localhost:3001/"

-- POST

registerUrl : String
registerUrl =
    api ++ "users"

authUser : Model -> String -> Http.Request String
authUser model apiUrl =
    let
        body =
            model
                |> userEncoder
                |> Http.jsonBody
    in
        Http.post apiUrl body tokenDecoder

-- Encode user to construct POST request body (for Register and Log In)

userEncoder : Model -> Encode.Value
userEncoder model =
    Encode.object
        [ ( "username", Encode.string model.username )
        , ( "password", Encode.string model.password )
        ]

-- Decode POST response to get access token
tokenDecoder : Decoder String
tokenDecoder =
    Decode.field "access_token" Decode.string

-- Boilerplate: Msg clause for internal Mdl messages.


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increase ->
            ( { model | count = model.count + 1 }
            , Cmd.none
            )

        Reset ->
            ( { model | count = 0 }
            , Cmd.none
            )

        -- Boilerplate: Mdl action handler.
        Mdl msg_ ->
            Material.update Mdl msg_ model



-- VIEW


type alias Mdl =
    Material.Model


view : Model -> Html Msg
view model =
    div
        [ style [ ( "padding", "2rem" ) ] ]
        [ text ("Current count: " ++ toString model.count)
          {- We construct the instances of the Button component that we need, one
             for the increase button, one for the reset button. First, the increase
             button. The first three arguments are:

               - A Msg constructor (`Mdl`), lifting Mdl messages to the Msg type.
               - An instance id (the `[0]`). Every component that uses the same model
                 collection (model.mdl in this file) must have a distinct instance id.
               - A reference to the elm-mdl model collection (`model.mdl`).

             Notice that we do not have to add fields for the increase and reset buttons
             separately to our model; and we did not have to add to our update messages
             to handle their internal events.

             Mdl components are configured with `Options`, similar to `Html.Attributes`.
             The `Options.onClick Increase` option instructs the button to send the `Increase`
             message when clicked. The `css ...` option adds CSS styling to the button.
             See `Material.Options` for details on options.
          -}
        , Button.render Mdl
            [ 0 ]
            model.mdl
            [ Options.onClick Increase
            , css "margin" "0 24px"
            ]
            [ text "Increase" ]
        , Button.render Mdl
            [ 1 ]
            model.mdl
            [ Options.onClick Reset ]
            [ text "Reset" ]
        ]
        |> Material.Scheme.top



-- Load Google Mdl CSS. You'll likely want to do that not in code as we
-- do here, but rather in your master .html file. See the documentation
-- for the `Material` module for details.


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , subscriptions = always Sub.none
        , update = update
        }