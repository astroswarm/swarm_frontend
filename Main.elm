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
    port_offset: Int
  }

initialModel : Model
initialModel =
  {
    services =
      [
        {
          name = "Lin Guider (Autoguider)",
          port_offset = 2
        },
        {
          name = "PHD2 (Autoguider)",
          port_offset = 1
        },
        {
          name = "Open Sky Imager (Camera Controller)",
          port_offset = 3
        }
      ],
     selected_service_index = -1
  }

-- Update

-- View
view =
  Html.div [ Html.Attributes.class "container" ] [
    Html.ul [ Html.Attributes.class "collection" ] (
      List.map (\
        service ->
          Html.li [ Html.Attributes.class "collection-item" ] [ Html.text service.name ]
      ) initialModel.services
    )
  ]

main =
  view
