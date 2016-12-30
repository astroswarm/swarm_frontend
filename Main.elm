-- Imports

import Html
import Html.Attributes

-- Model

-- Update

-- View
view =
  Html.div [ Html.Attributes.class "container" ] [
    Html.ul [ Html.Attributes.class "collection" ] [
      Html.li [ Html.Attributes.class "collection-item" ] [ Html.text "PHD2 (Autoguider)" ],
      Html.li [ Html.Attributes.class "collection-item" ] [ Html.text "Lin Guider (Autoguider)" ],
      Html.li [ Html.Attributes.class "collection-item" ] [ Html.text "Open Sky Imager (Camera Control)"]
    ]
  ]

main =
  view
