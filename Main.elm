-- Imports

import Html
import Html.Attributes

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
     selected_service_index = -1
  }

-- Update

type Message = NoOp

update message model =
  case message of
    NoOp ->
      model

-- View
view model =
  Html.div [ Html.Attributes.class "container" ] [
    Html.p [ ] [ Html.text "Choose a service to run:" ],
    Html.ul [ Html.Attributes.class "collection" ] (
      List.map (\
        service ->
          Html.li [ Html.Attributes.class "collection-item" ] [
            Html.a [
              Html.Attributes.href(
                String.concat(["http://localhost:6080/vnc_auto.html?host=localhost&port=", toString(service.websockify_port)])
              )
            ] [ Html.text service.name ]
          ]
      ) model.services
    )
  ]

main =
  Html.beginnerProgram
    {
      model = initialModel,
      view = view,
      update = update
    }
