-- Imports

import Html
import Html.Attributes
import Html.Events
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
    hostname: String
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
       hostname = hostname
    },
    Cmd.none
  )

-- Update

type Message = NoOp | ServiceSelect String

update: Message -> Model -> (Model, Cmd msg)

update message model =
  case message of
    NoOp ->
      (model, Cmd.none)
    ServiceSelect new_service ->
      ({ model | selected_service_name = new_service }, Cmd.none)


viewServicesList model =
  Html.div [] [
    Html.p [ ] [ Html.text "Choose a service to run:" ],
    Html.ul [ Html.Attributes.class "collection" ] (
      List.map (\
        service ->
          Html.li [ Html.Attributes.class "collection-item" ] [
            if service.name == model.selected_service_name then
              Html.text service.name
            else
              Html.a [
                Html.Attributes.href "javascript: return false;",
                Html.Events.onClick (ServiceSelect service.name)
              ] [ Html.text service.name ]
          ]) model.services
      )
  ]


viewStatusInfo model =
  Html.div [] [
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
        Html.text(
          String.concat([
            "URL: ",
            model.hostname
          ])
        )
      ]
  ]


viewServiceEmbed model =
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


-- View
view model =
  Html.div [ Html.Attributes.class "container" ] [
    viewServicesList model,
    viewStatusInfo model,
    viewServiceEmbed model
  ]

main =
  Html.programWithFlags
    {
      init = init,
      view = view,
      update = update,
      subscriptions = \_ -> Sub.none
    }
