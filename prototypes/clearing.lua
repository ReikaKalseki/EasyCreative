require "__DragonIndustries__.registration"

addDerivative("deconstruction-item", "deconstruction-planner", {
    name = "inventory-emptier",
    icon = "__EasyCreative__/graphics/icons/emptier.png",
    icon_size = 32,
    order = "c[automated-construction]-d[emptier]",
    select = {
      border_color = {255, 202, 3, 77},
      mode = {"any-entity"},
      cursor_box_type = "entity",
    },
    alt_select = {
      border_color = {255, 182, 2, 0},
      mode = {"any-entity"},
      cursor_box_type = "entity",
    },
    super_forced_select = "nil",
    reverse_select = {
      border_color = {255, 204, 51, 0},
      mode = {"any-entity"},
      cursor_box_type = "entity",
    },
    alt_reverse_select = {
      border_color = {255, 204, 51, 0},
      mode = {"any-entity"},
      cursor_box_type = "entity",
    },
    tile_filter_count = "nil",
})