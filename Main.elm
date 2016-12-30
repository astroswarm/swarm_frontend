-- Imports

import Html
import Html.Attributes
import Html.Events
import Maybe

-- Model
type alias Model =
  {
    services: List Service,
    selected_service_index: Int
  }
type alias Service =
  {
    name: String,
    websockify_port: Int
  }

initialModel : Model
initialModel =
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
     selected_service_index = 1
  }

-- Update

type Message = NoOp | ServiceSelectIndex Int

update message model =
  case message of
    NoOp ->
      model
    ServiceSelectIndex new_service_index ->
      { model | selected_service_index = new_service_index }

-- View
view model =
  Html.div [ Html.Attributes.class "container" ] [
    Html.p [ ] [ Html.text "Choose a service to run:" ],
    Html.ul [ Html.Attributes.class "collection" ] (
      List.map (\
        service ->
          Html.li [ Html.Attributes.class "collection-item" ] [
            Html.a [
              Html.Attributes.href( "javascript: return false;" ),
              Html.Events.onClick(
                ServiceSelectIndex(service.websockify_port - 6100)
              )
            ] [ Html.text service.name ]
          ]
      ) model.services
    ),
    Html.p [ ] [
      Html.text(
        String.concat([
          "Selected service index: ",
          toString(
            model.selected_service_index
          )
        ])
      )
    ],
    Html.p [ ] [
      Html.text(
        String.concat([
          "Selected service: ",
          List.filter (\n -> n.websockify_port == 6100 + model.selected_service_index) model.services
            |> List.map (\n -> n.name)
            |> List.head
            |> Maybe.withDefault ""
        ])
      )
    ],
    Html.iframe [
      Html.Attributes.src(
        String.concat(
          [
            "http://localhost:6080/vnc_auto.html?host=localhost&port=", toString(
              List.filter (\n -> n.websockify_port == 6100 + model.selected_service_index) model.services
                |> List.map (\n -> n.websockify_port)
                |> List.head
                |> Maybe.withDefault 0
            )
          ]
        )
      ),
      Html.Attributes.height 600,
      Html.Attributes.width 800
    ] []
  ]

main =
  Html.beginnerProgram
    {
      model = initialModel,
      view = view,
      update = update
    }
