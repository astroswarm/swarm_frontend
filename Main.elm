-- Imports

import Array
import Html
import Html.Attributes
import Html.Events
import Http
import HttpBuilder
import Json.Encode
import Json.Decode
import Maybe

-- Model

type alias Flags =
  {
    hostname: String
  }
type alias Model =
  {
    services: List Service,
    selected_service_name: String,
    hostname: String,
    uploaded_logs_url: String
  }
type alias Service =
  {
    name: String,
    websockify_port: Int
  }

-- Model Initialization

init : Flags -> (Model, Cmd Message)
init {hostname} =
  (
    {
      services =
        [
          {
            name = "Lin Guider (Autoguider)",
            websockify_port = 6101
          },
          {
            name = "PHD2 (Autoguider)",
            websockify_port = 6102
          },
          {
            name = "Open Sky Imager (Camera Controller)",
            websockify_port = 6103
          }
        ],
       selected_service_name = "Lin Guider (Autoguider)",
       hostname = hostname,
       uploaded_logs_url = ""
    },
    Cmd.none
  )

-- Update

type Message = NoOp | ServiceSelect String | UploadLogs | UpdateUploadedLogsUrl String

update: Message -> Model -> (Model, Cmd msg)

update message model =
  case message of
    NoOp ->
      (model, Cmd.none)
    ServiceSelect new_service ->
      ({ model | selected_service_name = new_service }, Cmd.none)
    UploadLogs ->
      let
        url = "http://localhost:8081/api/execute_command"
        request = Http.post (succeed "") url
        cmd = request.
      in
        (model, cmd)
    UpdateUploadedLogsUrl url ->
      ({ model | uploaded_logs_url = url}, Cmd.none)

uploadLogsParams = Json.Encode.object
  [
    ("command", Json.Encode.string("pastebinit")),
    ("args", Json.Encode.list(
      [
        Json.Encode.string("-b"),
        Json.Encode.string("sprunge.us"),
        Json.Encode.string("/mnt/host/var/log/syslog")
      ]
    ))
  ]

-- View
view model =
  Html.div [ Html.Attributes.class "container" ] [
    Html.p [ ] [ Html.text "Choose a service to run:" ],
    Html.ul [ Html.Attributes.class "collection" ] (
      List.map (\
        service ->
          Html.li [ Html.Attributes.class "collection-item" ] [
            if service.name == model.selected_service_name then
              Html.text service.name
            else
              Html.a [
                Html.Attributes.href( "javascript: return false;" ),
                Html.Events.onClick(
                  ServiceSelect service.name
                )
              ] [ Html.text service.name ]
          ]
      ) model.services
    ),
    Html.p [ ] [
      Html.text(
        String.concat([
          "Selected service: ",
          List.filter (\n -> n.name == model.selected_service_name) model.services
            |> List.map (\n -> n.name)
            |> List.head
            |> Maybe.withDefault ""
        ])
      )
    ],
    Html.p [ ] [
      Html.a [
        Html.Attributes.href( "javascript: return false;" ),
        Html.Events.onClick(
          UploadLogs
        )
      ] [ Html.text "Having trouble? Click here to submit your logs to a developer." ]
    ],
    Html.iframe [
      Html.Attributes.src(
        String.concat(
          [
            "http://",
            model.hostname,
            ":6080/vnc_auto.html?host=",
            model.hostname,
            "&port=", toString(
              List.filter (\n -> n.name == model.selected_service_name) model.services
                |> List.map (\n -> n.websockify_port)
                |> List.head
                |> Maybe.withDefault 0
            )
          ]
        )
      ),
      Html.Attributes.height 600,
      Html.Attributes.width 1000
    ] []
  ]
--
--handleUploadLogsComplete : Result Http.Error (List String) -> Html.Html msg
--handleUploadLogsComplete result = Html.text "foo"
--
--uploadLogs : Message
--uploadLogs =
--  HttpBuilder.post "http://localhost:8081/api/execute_command"
--    |> HttpBuilder.withJsonBody uploadLogsParams
--    |> HttpBuilder.send handleUploadLogsComplete

main =
  Html.programWithFlags
    {
      init = init,
      view = view,
      update = update,
      subscriptions = \_ -> Sub.none
    }
