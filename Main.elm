-- Imports

import Bootstrap.Alert
import Bootstrap.Button
import Bootstrap.ListGroup
import Bootstrap.CDN
import Html
import Html.Attributes
import Html.Events
import Http
import Json.Decode
import Json.Encode
import Maybe

-- Model

type alias Flags =
  {
    hostname: String
  }
type alias Service =
  {
    name: String,
    websockify_port: Int
  }
type alias Model =
  {
    services: List Service,
    selected_service_name: String,
    hostname: String,
    uploaded_log_url: String
  }

-- Model Initialization

init : Flags -> (Model, Cmd Msg)
init {hostname} =
  (
    {
      services =
        [
          Service "Lin Guider (Autoguider)" 6101,
          Service "PHD2 (Autoguider)" 6102,
          Service "Open Sky Imager (Camera Controller)" 6103
        ],
       selected_service_name = "Lin Guider (Autoguider)",
       hostname = hostname,
       uploaded_log_url = ""
    },
    Cmd.none
  )

-- Update

type Msg = NoOp | ServiceSelect String | UploadLogs | LogsUploaded (Result Http.Error String)

update: Msg -> Model -> (Model, Cmd Msg)

update message model =
  case message of
    NoOp ->
      (model, Cmd.none)
    ServiceSelect new_service ->
      ({ model | selected_service_name = new_service }, Cmd.none)
    UploadLogs ->
      (model, uploadLogs model)
    LogsUploaded (Ok output) ->
      let
        url =
          output
          |> String.filter (\c -> c /= '\n')
      in
        ({ model | uploaded_log_url = url }, Cmd.none)
    LogsUploaded (Err error) ->
      ({ model | uploaded_log_url = (toString error) }, Cmd.none)


-- DECODERS

logsUploadedDecoder : Json.Decode.Decoder String
logsUploadedDecoder =
  Json.Decode.field "output" Json.Decode.string


-- COMMANDS

uploadLogs : Model -> Cmd Msg
uploadLogs model =
  let
    body = Json.Encode.object [
      ("command", Json.Encode.string "pastebinit"),
      ("args", Json.Encode.list(
        [
          Json.Encode.string "-b",
          Json.Encode.string "sprunge.us",
          Json.Encode.string "/mnt/host/var/log/syslog"
        ]
      ))]
      |> Http.jsonBody
    url = "http://" ++ model.hostname ++ ":8001/api/execute_command"
  in
    Http.post url body logsUploadedDecoder
      |> Http.send LogsUploaded


-- VIEW

view : Model -> Html.Html Msg
view model =
  let
    viewServicesList =
      Html.div [] [
        Bootstrap.ListGroup.ul (
          List.map (
            \service ->
              if service.name == model.selected_service_name then
                Bootstrap.ListGroup.li [ Bootstrap.ListGroup.active ] [ Html.text service.name ]
              else
                Bootstrap.ListGroup.li [] [ Html.a [ Html.Events.onClick (ServiceSelect service.name) ] [ Html.text service.name] ]
          ) model.services
        )
      ]


    viewStatusInfo =
      Html.div [] [
        Bootstrap.Alert.info [
          Html.text ("Using host: " ++ model.hostname)
        ]
      ]

    viewUploadLogs =
      Html.div [] [
        Bootstrap.Button.button [
          Bootstrap.Button.warning, Bootstrap.Button.attrs [
            Html.Attributes.class "ml-1",
            Html.Events.onClick UploadLogs
          ]
        ] [ Html.text "Having trouble? Click here to upload your logs." ],

          if String.length(model.uploaded_log_url) > 0 then
            Bootstrap.Alert.info [
            Html.div [ ] [
              Html.text "Your logs have been uploaded: ",
              Html.a [
                Html.Attributes.href model.uploaded_log_url,
                Html.Attributes.target "_blank"
              ] [ Html.text model.uploaded_log_url ]
            ]
            ]
          else
            Html.text ""
      ]
      

    viewServiceEmbed =
      Html.iframe [
        Html.Attributes.src(
          "http://" ++ model.hostname ++ ":6080/vnc_auto.html?host=" ++ model.hostname ++ "&port=" ++ (
            List.filter (\n -> n.name == model.selected_service_name) model.services
              |> List.map .websockify_port
              |> List.head
              |> Maybe.withDefault 0
              |> toString
          )
        ),
        Html.Attributes.height 600,
        Html.Attributes.width 1000
      ] []
  in
    Html.div [ Html.Attributes.class "container" ] [
      Bootstrap.CDN.stylesheet,
      viewServicesList,
      viewStatusInfo,
      viewUploadLogs,
      viewServiceEmbed
    ]


main : Program Flags Model Msg
main =
  Html.programWithFlags
    {
      init = init,
      view = view,
      update = update,
      subscriptions = \_ -> Sub.none
    }
