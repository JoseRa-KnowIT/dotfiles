return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#020309",
        dark_bg    = "#020207",
        darker_bg  = "#010205",
        lighter_bg = "#1b1c22",

        fg         = "#d2e9f6",
        dark_fg    = "#9eafb9",
        light_fg   = "#d9ecf7",
        bright_fg  = "#ddeff8",
        muted      = "#616369",

        red        = "#c35772",
        yellow     = "#65a3f7",
        orange     = "#cc7087",
        green      = "#5497e9",
        cyan       = "#569fef",
        blue       = "#5680e5",
        purple     = "#9b71ce",
        brown      = "#7a4351",

        bright_red    = "#f37697",
        bright_yellow = "#86c7ff",
        bright_green  = "#75baff",
        bright_cyan   = "#77c3ff",
        bright_blue   = "#78a1ff",
        bright_purple = "#c48fff",

        accent               = "#5680e5",
        cursor               = "#d2e9f6",
        foreground           = "#d2e9f6",
        background           = "#020309",
        selection             = "#1b1c22",
        selection_foreground = "#d2e9f6",
        selection_background = "#1b1c22",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
