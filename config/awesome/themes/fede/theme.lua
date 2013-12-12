color="#008080"

theme                               = {}

theme.dir                           = os.getenv("HOME") .. "/.config/awesome/themes/fede"
theme.wallpaper                     = theme.dir .. "/wall.png"
theme.topbar_path                   = "png:" .. theme.dir .. "/icons/topbar/"

theme.font                          = "Tamsyn 10.5"
theme.taglist_font                  = "Tamsyn 10.5"
theme.fg_normal                     = "#D7D7D7"
theme.fg_focus                      = color
theme.bg_normal                     = "#060606"
theme.bg_focus                      = "#060606"
theme.fg_urgent                     = "#CC9393"
theme.bg_urgent                     = "#2A1F1E"
theme.border_width                  = "2"
theme.border_normal                 = "#0E0E0E"
theme.border_focus                  = "#BBBBBB"

theme.taglist_fg_focus              = color
theme.taglist_bg_focus              = "#060606"
theme.tasklist_fg_focus             = color
theme.tasklist_bg_focus             = "#060606"
theme.menu_height                   = "16"
theme.menu_width                    = "140"

theme.menu_submenu_icon             = theme.dir .. "/icons/submenu.png"
theme.taglist_squares_sel           = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel         = theme.dir .. "/icons/square_unsel.png"
theme.arrl_lr_pre                   = theme.dir .. "/icons/arrl_lr_pre.png"
theme.arrl_lr_post                  = theme.dir .. "/icons/arrl_lr_post.png"

-- From Copland
theme.widget_bg                     = theme.dir .. "/icons/widget_bg.png"
theme.vol                           = theme.dir .. "/icons/vol.png"
theme.vol_low                       = theme.dir .. "/icons/vol_low.png"
theme.vol_no                        = theme.dir .. "/icons/vol_no.png"
theme.vol_mute                      = theme.dir .. "/icons/vol_mute.png"
theme.disk                          = theme.dir .. "/icons/disk.png"
theme.play                          = theme.dir .. "/icons/play.png"
theme.pause                         = theme.dir .. "/icons/pause.png"
-- End From Copland

theme.layout_tile                   = theme.dir .. "/icons/tile.png"
theme.layout_tileleft               = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom             = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                  = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                  = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                 = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                = theme.dir .. "/icons/dwindle.png"
theme.layout_max                    = theme.dir .. "/icons/max.png"
theme.layout_fullscreen             = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier              = theme.dir .. "/icons/magnifier.png"
theme.layout_floating               = theme.dir .. "/icons/floating.png"

theme.tasklist_disable_icon         = true
theme.tasklist_ontop                = "[t] "
theme.tasklist_floating             = "[f] "
theme.tasklist_maximized_horizontal = "[m] "
theme.tasklist_maximized_vertical   = ""

-- lain related
theme.useless_gap_width             = 10
theme.layout_uselesstile            = theme.dir .. "/icons/uselesstile.png"
theme.layout_uselesstileleft        = theme.dir .. "/icons/uselesstileleft.png"
theme.layout_uselesstiletop         = theme.dir .. "/icons/uselesstiletop.png"

return theme
