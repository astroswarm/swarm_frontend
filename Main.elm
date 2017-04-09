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
type alias Service =
  {
    name: String,
    websockify_port: Int
  }
type alias Model =
  {
    services: List Service,
    selected_service_name: String,
    hostname: String
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
       hostname = hostname
    },
    Cmd.none
  )

-- Update

type Msg = NoOp | ServiceSelect String

update: Msg -> Model -> (Model, Cmd msg)

update message model =
  case message of
    NoOp ->
      (model, Cmd.none)
    ServiceSelect new_service ->
      ({ model | selected_service_name = new_service }, Cmd.none)


-- VIEW

view : Model -> Html.Html Msg
view model =
  let
    viewServicesList =
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
              ]
          ) model.services
        )
      ]


    viewStatusInfo =
      Html.div [] [
        Html.p [ ] [
          Html.text(
            "Selected service: " ++ (
              List.filter (\n -> n.name == model.selected_service_name) model.services
                |> List.map .name
                |> List.head
                |> Maybe.withDefault ""
            )
          )
        ],
        Html.p [ ] [ Html.text ("URL: " ++ model.hostname) ]
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
      viewServicesList,
      viewStatusInfo,
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
