local config = {}

config.alpha = function()
  local alpha = require("alpha")
  local dashboard = require("alpha.themes.dashboard")
  local headers = nil

  if __editor_config.background == "dark" then
    headers = {
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠉⠉⠀⠀⠉⠛⠻⢿⡿⢟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⡄⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⣰⣦⣄⣈⣛⣿⣶⣦⣀⣀⣤⡾⠟⠛⠻⣿⡘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⣿⣿⣥⣋⣉⣤⣤⣽⣿⣿⡟⣷⠾⠛⠉⢛⠃⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⣯⣣⣟⣉⠉⠉⠭⢉⡛⢛⣁⠡⣀⣠⣿⣿⡇⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢫⠐⢤⠈⣭⣟⣉⢰⣦⣴⣿⣿⡇⣿⣿⡄⢛⣛⣭⣥⣴⠸⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠃⣿⢂⡅⣿⣽⣿⣜⣛⣛⣭⣭⣴⣿⣿⡿⢸⣿⣿⣿⣿⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢻⣿⣬⡻⡜⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣷⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣝⡫⠴⣃⢸⣿⣿⣿⣿⣿⣿⣿⠟⣛⣛⣭⣿⣿⣿⢇⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢋⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣶⣬⣉⡛⠻⠿⣿⣿⡿⠿⢟⣡⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢋⠁⣾⣿⣿⣿⣿⣿⣶⣶⣶⣶⡆⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠱⣿⣷⣮⣙⠿⣿⣿⣿⣿⣿⣿⣿⠃⣴⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠈⠻⣿⣿⣿⣶⣭⠛⠿⣿⠟⠱⣿⡿⠀⠈⠙⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⠏⠀⠁⠀⠀⠀⠈⠃⠀⠀⠀⠀⠀⠀⠈⠉⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿]],
      [[⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿]],
    }
  else
    headers = {
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣶⣶⣿⣿⣶⣤⣄⡀⢀⡠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⢻⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⠏⠙⠻⠷⠤⠀⠉⠙⠿⠿⠛⢁⣠⣤⣄⠀⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠚⠴⠶⠛⠛⠂⠀⠀⢠⠈⣁⣤⣶⡤⣼⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⠐⠜⠠⠶⣶⣶⣒⡶⢤⡤⠾⣞⠿⠟⠀⠀⢸⡀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡔⣯⡛⣷⠒⠠⠶⡏⠙⠋⠀⠀⢸⠀⠀⢻⡤⠤⠒⠚⠋⣇⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣼⠀⡽⢺⠀⠂⠀⠣⠤⠴⠒⠒⠋⠀⠀⢀⡇⠀⠀⠀⠀⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡄⠀⠓⢌⢣⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠈⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠢⢔⣋⠼⡇⠀⠀⠀⠀⠀⠀⠀⣠⠤⠤⠒⠀⠀⠀⡸⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠉⠓⠶⢤⣄⣀⠀⠀⢀⣀⡠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⣾⠁⠀⠀⠀⠀⠀⠉⠉⠉⠉⢹⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣎⠀⠈⠑⠦⣀⠀⠀⠀⠀⠀⠀⠀⣼⠋⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣿⣿⣿⣷⣄⠀⠀⠀⠉⠒⣤⣀⠀⣠⣎⠀⢀⣿⣷⣦⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣤⣀⣰⣿⣾⣿⣿⣿⣷⣼⣿⣿⣿⣿⣿⣿⣷⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀]],
      [[⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀]],
    }
  end

  local button = function(sc, txt, leader_txt, keybind, keybind_opts)
    local sc_after = sc:gsub("%s", ""):gsub(leader_txt, "<leader>")

    local on_press = function()
      -- local key = vim.api.nvim_replace_termcodes(keybind .. '<Ignore>', true, false, true)
      local key = vim.api.nvim_replace_termcodes(sc_after .. "<Ignore>", true, false, true)
      vim.api.nvim_feedkeys(key, "t", false)
    end

    local opts = {
      position = "center",
      shortcut = sc,
      cursor = 5,
      width = 50,
      align_shortcut = "right",
      hl_shortcut = "Keyword",
    }

    if nil == keybind then
      keybind = sc_after
    end
    keybind_opts = vim.F.if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
    opts.keymap = { "n", sc_after, keybind, keybind_opts }

    return {
      type = "button",
      val = txt,
      on_press = on_press,
      opts = opts,
    }
  end

  dashboard.section.header.val = headers
  local leader = "comma"
  local lleader = "kplus"
  dashboard.section.buttons.val = {
    button("comma f r", "  File frecency", leader, "<cmd>Telescope frecency<cr>"),
    button("comma f e", "  File history", leader, "<cmd>Telescope oldfiles<cr>"),
    button("comma f w", "  Word find", leader, "<cmd>Telescope live_grep<cr>"),
    button("comma f f", "  File find", leader, "<cmd>Telescope find_files<cr>"),
    button("kplus e c", "  Editor", lleader, "<cmd>e ~/.editor.lua<cr>"),
    button("kplus e s", "  Settings", lleader, ":e $MYVIMRC | :cd %:p:h <CR>"),
    button("kplus e r", "  NVIM access", lleader, "<cmd>Telescope find_files {cwd = vim.fn.stdpath('config')}<cr>"),
  }

  dashboard.section.buttons.opts.hl = "String"
  local footer = function()
    local stats = require("lazy").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    return "🍱 github.com/aarnphm"
      .. "   v"
      .. vim.version().major
      .. "."
      .. vim.version().minor
      .. "."
      .. vim.version().patch
      .. "   "
      .. stats.count
      .. " plugins in "
      .. ms
      .. "ms"
  end

  dashboard.section.footer.val = footer()
  dashboard.section.footer.opts.hl = "Function"

  local head_butt_padding = 2
  local occu_height = #dashboard.section.header.val + 2 * #dashboard.section.buttons.val + head_butt_padding
  local header_padding = math.max(0, math.ceil((vim.fn.winheight("$") - occu_height) * 0.25))
  local foot_butt_padding = 1

  dashboard.config.layout = {
    { type = "padding", val = header_padding },
    dashboard.section.header,
    { type = "padding", val = head_butt_padding },
    dashboard.section.buttons,
    { type = "padding", val = foot_butt_padding },
    dashboard.section.footer,
  }

  alpha.setup(dashboard.opts)

  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    callback = function()
      dashboard.section.footer.val = footer()
      pcall(vim.cmd.AlphaRedraw)
    end,
  })
end

config.catppuccin = function()
  local transparent_background = false -- Set background transparency here!

  require("catppuccin").setup({
    flavour = __editor_config.catppuccin.flavor, -- Can be one of: latte, frappe, macchiato, mocha
    background = { light = "latte", dark = "mocha" },
    dim_inactive = {
      enabled = false,
      -- Dim inactive splits/windows/buffers.
      -- NOT recommended if you use old palette (a.k.a., mocha).
      shade = "dark",
      percentage = 0.15,
    },
    transparent_background = transparent_background,
    show_end_of_buffer = false, -- show the '~' characters after the end of buffers
    term_colors = true,
    compile_path = __editor_global.cache_dir .. __editor_global.path_sep .. "catppuccin",
    styles = {
      comments = { "italic" },
      properties = { "italic" },
      functions = { "italic", "bold" },
      keywords = { "italic" },
      operators = { "bold" },
      conditionals = { "bold" },
      loops = { "bold" },
      booleans = { "bold", "italic" },
      numbers = {},
      types = {},
      strings = {},
      variables = {},
    },
    integrations = {
      treesitter = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
        },
      },
      aerial = false,
      barbar = false,
      beacon = false,
      cmp = true,
      coc_nvim = false,
      dap = { enabled = true, enable_ui = true },
      dashboard = false,
      fern = false,
      fidget = true,
      gitgutter = false,
      gitsigns = true,
      harpoon = false,
      hop = true,
      illuminate = true,
      indent_blankline = { enabled = true, colored_indent_levels = false },
      leap = false,
      lightspeed = false,
      lsp_saga = true,
      lsp_trouble = true,
      markdown = true,
      mason = true,
      mini = false,
      navic = { enabled = false },
      neogit = false,
      neotest = false,
      neotree = { enabled = false, show_root = true, transparent_panel = false },
      noice = false,
      notify = true,
      nvimtree = true,
      overseer = false,
      pounce = false,
      semantic_tokens = false,
      symbols_outline = false,
      telekasten = false,
      telescope = true,
      treesitter_context = false,
      ts_rainbow = true,
      vim_sneak = false,
      vimwiki = false,
      which_key = true,
    },
    color_overrides = {
      mocha = {
        rosewater = "#F5E0DC",
        flamingo = "#F2CDCD",
        mauve = "#DDB6F2",
        pink = "#F5C2E7",
        red = "#F28FAD",
        maroon = "#E8A2AF",
        peach = "#F8BD96",
        yellow = "#FAE3B0",
        green = "#ABE9B3",
        blue = "#96CDFB",
        sky = "#89DCEB",
        teal = "#B5E8E0",
        lavender = "#C9CBFF",

        text = "#D9E0EE",
        subtext1 = "#BAC2DE",
        subtext0 = "#A6ADC8",
        overlay2 = "#C3BAC6",
        overlay1 = "#988BA2",
        overlay0 = "#6E6C7E",
        surface2 = "#6E6C7E",
        surface1 = "#575268",
        surface0 = "#302D41",

        base = "#1E1E2E",
        mantle = "#1A1826",
        crust = "#161320",
      },
    },
    highlight_overrides = {
      all = function(cp)
        return {
          -- For lspsaga.nvim
          SagaBeacon = { bg = cp.surface0 },
        }
      end,
      mocha = function(cp)
        return {
          -- For base configs.
          NormalFloat = { fg = cp.text, bg = transparent_background and cp.none or cp.base },
          CursorLineNr = { fg = cp.green },
          Search = { bg = cp.surface1, fg = cp.pink, style = { "bold" } },
          IncSearch = { bg = cp.pink, fg = cp.surface1 },
          Keyword = { fg = cp.pink },
          Type = { fg = cp.blue },
          Typedef = { fg = cp.yellow },
          StorageClass = { fg = cp.red, style = { "italic" } },

          -- For native lsp configs.
          DiagnosticVirtualTextError = { bg = cp.none },
          DiagnosticVirtualTextWarn = { bg = cp.none },
          DiagnosticVirtualTextInfo = { bg = cp.none },
          DiagnosticVirtualTextHint = { fg = cp.rosewater, bg = cp.none },

          DiagnosticHint = { fg = cp.rosewater },
          LspDiagnosticsDefaultHint = { fg = cp.rosewater },
          LspDiagnosticsHint = { fg = cp.rosewater },
          LspDiagnosticsVirtualTextHint = { fg = cp.rosewater },
          LspDiagnosticsUnderlineHint = { sp = cp.rosewater },

          -- For fidget.
          FidgetTask = { bg = cp.none, fg = cp.surface2 },
          FidgetTitle = { fg = cp.blue, style = { "bold" } },

          -- For trouble.nvim
          TroubleNormal = { bg = cp.base },

          -- For treesitter.
          ["@field"] = { fg = cp.rosewater },
          ["@property"] = { fg = cp.yellow },

          ["@include"] = { fg = cp.teal },
          -- ["@operator"] = { fg = cp.sky },
          ["@keyword.operator"] = { fg = cp.sky },
          ["@punctuation.special"] = { fg = cp.maroon },

          -- ["@float"] = { fg = cp.peach },
          -- ["@number"] = { fg = cp.peach },
          -- ["@boolean"] = { fg = cp.peach },

          ["@constructor"] = { fg = cp.lavender },
          -- ["@constant"] = { fg = cp.peach },
          -- ["@conditional"] = { fg = cp.mauve },
          -- ["@repeat"] = { fg = cp.mauve },
          ["@exception"] = { fg = cp.peach },

          ["@constant.builtin"] = { fg = cp.lavender },
          -- ["@function.builtin"] = { fg = cp.peach, style = { "italic" } },
          -- ["@type.builtin"] = { fg = cp.yellow, style = { "italic" } },
          ["@type.qualifier"] = { link = "@keyword" },
          ["@variable.builtin"] = { fg = cp.red, style = { "italic" } },

          -- ["@function"] = { fg = cp.blue },
          ["@function.macro"] = { fg = cp.red, style = {} },
          ["@parameter"] = { fg = cp.rosewater },
          ["@keyword"] = { fg = cp.red, style = { "italic" } },
          ["@keyword.function"] = { fg = cp.maroon },
          ["@keyword.return"] = { fg = cp.pink, style = {} },

          -- @uncomment start
          ["@text.note"] = { fg = cp.base, bg = cp.blue },
          ["@text.warning"] = { fg = cp.base, bg = cp.yellow },
          ["@text.danger"] = { fg = cp.base, bg = cp.red },
          ["@constant.macro"] = { fg = cp.mauve },
          ["@label"] = { fg = cp.blue },
          -- @uncomment stop

          ["@method"] = { style = { "italic" } },
          ["@namespace"] = { fg = cp.rosewater, style = {} },

          ["@punctuation.delimiter"] = { fg = cp.teal },
          ["@punctuation.bracket"] = { fg = cp.overlay2 },

          -- @uncomment start
          ["@string"] = { fg = cp.green },
          ["@string.regex"] = { fg = cp.peach },
          -- @uncomment stop

          ["@type"] = { fg = cp.yellow },
          ["@variable"] = { fg = cp.text },
          ["@tag.attribute"] = { fg = cp.mauve, style = { "italic" } },
          ["@tag"] = { fg = cp.peach },
          ["@tag.delimiter"] = { fg = cp.maroon },
          ["@text"] = { fg = cp.text },

          -- @uncomment start
          ["@text.uri"] = { fg = cp.rosewater, style = { "italic", "underline" } },
          ["@text.literal"] = { fg = cp.teal, style = { "italic" } },
          ["@text.reference"] = { fg = cp.lavender, style = { "bold" } },
          ["@text.title"] = { fg = cp.blue, style = { "bold" } },
          ["@text.emphasis"] = { fg = cp.maroon, style = { "italic" } },
          ["@text.strong"] = { fg = cp.maroon, style = { "bold" } },
          ["@string.escape"] = { fg = cp.pink },

          ["@property.toml"] = { fg = cp.blue },
          ["@field.yaml"] = { fg = cp.blue },

          ["@label.json"] = { fg = cp.blue },
          -- @uncomment stop

          ["@function.builtin.bash"] = { fg = cp.red, style = { "italic" } },
          ["@parameter.bash"] = { fg = cp.yellow, style = { "italic" } },

          ["@field.lua"] = { fg = cp.lavender },
          ["@constructor.lua"] = { fg = cp.flamingo },

          ["@constant.java"] = { fg = cp.teal },

          ["@property.typescript"] = { fg = cp.lavender, style = { "italic" } },

          -- @uncomment start
          -- ["@constructor.typescript"] = { fg = cp.lavender },
          -- ["@constructor.tsx"] = { fg = cp.lavender },
          -- ["@tag.attribute.tsx"] = { fg = cp.mauve },
          -- @uncomment stop

          ["@type.css"] = { fg = cp.lavender },
          ["@property.css"] = { fg = cp.yellow, style = { "italic" } },

          ["@type.builtin.c"] = { fg = cp.yellow, style = {} },

          ["@property.cpp"] = { fg = cp.text },
          ["@type.builtin.cpp"] = { fg = cp.yellow, style = {} },

          ["@symbol"] = { fg = cp.flamingo },
        }
      end,
    },
  })
end

config.lualine = function()
  local icons = {
    diagnostics = require("modules.ui.icons").get("diagnostics", true),
    misc = require("modules.ui.icons").get("misc", true),
    ui = require("modules.ui.icons").get("ui", true),
  }

  local escape_status = function()
    local ok, m = pcall(require, "better_escape")
    return ok and m.waiting and icons.misc.EscapeST or ""
  end

  local _cache = { context = "", bufnr = -1 }
  local lspsaga_symbols = function()
    local exclude = {
      ["terminal"] = true,
      ["toggleterm"] = true,
      ["prompt"] = true,
      ["NvimTree"] = true,
      ["help"] = true,
    }
    if vim.api.nvim_win_get_config(0).zindex or exclude[vim.bo.filetype] then
      return "" -- Excluded filetypes
    else
      local currbuf = vim.api.nvim_get_current_buf()
      local ok, lspsaga = pcall(require, "lspsaga.symbolwinbar")
      if ok and lspsaga:get_winbar() ~= nil then
        _cache.context = lspsaga:get_winbar()
        _cache.bufnr = currbuf
      elseif _cache.bufnr ~= currbuf then
        _cache.context = "" -- Reset [invalid] cache (usually from another buffer)
      end

      return _cache.context
    end
  end

  local diff_source = function()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
      return {
        added = gitsigns.added,
        modified = gitsigns.changed,
        removed = gitsigns.removed,
      }
    end
  end

  local get_cwd = function()
    local cwd = vim.fn.getcwd()
    local home = os.getenv("HOME")
    if cwd:find(home, 1, true) == 1 then
      cwd = "~" .. cwd:sub(#home + 1)
    end
    return icons.ui.RootFolderOpened .. cwd
  end

  local mini_sections = {
    lualine_a = { "filetype" },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  }
  local outline = {
    sections = mini_sections,
    filetypes = { "lspsagaoutline" },
  }
  local diffview = {
    sections = mini_sections,
    filetypes = { "DiffviewFiles" },
  }

  local python_venv = function()
    local function env_cleanup(venv)
      if string.find(venv, "/") then
        local final_venv = venv
        for w in venv:gmatch("([^/]+)") do
          final_venv = w
        end
        venv = final_venv
      end
      return venv
    end

    if vim.bo.filetype == "python" then
      local venv = os.getenv("CONDA_DEFAULT_ENV")
      if venv then
        return string.format("%s", env_cleanup(venv))
      end
      venv = os.getenv("VIRTUAL_ENV")
      if venv then
        return string.format("%s", env_cleanup(venv))
      end
    end
    return ""
  end

  require("lualine").setup({
    options = {
      icons_enabled = true,
      theme = "catppuccin",
      disabled_filetypes = {},
      component_separators = "|",
      section_separators = { left = " ", right = " " },
    },
    sections = {
      lualine_a = { { "mode" } },
      lualine_b = { { "branch" }, { "diff", source = diff_source } },
      lualine_c = { lspsaga_symbols },
      lualine_x = {
        { escape_status },
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = {
            error = icons.diagnostics.Error,
            warn = icons.diagnostics.Warning,
            info = icons.diagnostics.Information,
          },
        },
        { get_cwd },
      },
      lualine_y = {
        { "filetype", colored = true, icon_only = true },
        { python_venv },
        { "encoding" },
        {
          "fileformat",
          icons_enabled = true,
          symbols = {
            unix = "LF",
            dos = "CRLF",
            mac = "CR",
          },
        },
      },
      lualine_z = { "progress", "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    extensions = {
      "quickfix",
      "nvim-tree",
      "nvim-dap-ui",
      "toggleterm",
      "fugitive",
      outline,
      diffview,
    },
  })

  -- Properly set background color for lspsaga
  local winbar_bg = require("modules.utils").hl_to_rgb("StatusLine", true, "#000000")
  for _, hlGroup in pairs(require("lspsaga.lspkind").get_kind()) do
    require("modules.utils").extend_hl("LspSagaWinbar" .. hlGroup[1], { bg = winbar_bg })
  end
  require("modules.utils").extend_hl("LspSagaWinbarSep", { bg = winbar_bg })
end

config.nvim_tree = function()
  require("nvim-tree").setup({
    disable_netrw = true,
    hijack_cursor = true,
    sort_by = "extensions",
    reload_on_bufenter = true,
    prefer_startup_root = true,
    respect_buf_cwd = true,
    view = {
      adaptive_size = false,
      width = 16,
      side = "right",
    },
    renderer = {
      root_folder_modifier = ":e",
      icons = {
        padding = " ",
        symlink_arrow = "  ",
        glyphs = {
          ["default"] = "", --
          ["symlink"] = "",
          ["git"] = {
            ["unstaged"] = "",
            ["staged"] = "", --
            ["unmerged"] = "שׂ",
            ["renamed"] = "", --
            ["untracked"] = "ﲉ",
            ["deleted"] = "",
            ["ignored"] = "", --◌
          },
          ["folder"] = {
            ["arrow_open"] = "",
            ["arrow_closed"] = "",
            ["default"] = "",
            ["open"] = "",
            ["empty"] = "",
            ["empty_open"] = "",
            ["symlink"] = "",
            ["symlink_open"] = "",
          },
        },
      },
      indent_markers = {
        enable = true,
        icons = {
          corner = "└ ",
          edge = "│ ",
          none = "  ",
        },
      },
    },
    hijack_directories = { enable = true, auto_open = true },
    update_focused_file = {
      enable = true,
      update_root = true,
      ignore_list = {},
    },
    system_open = { cmd = "open", args = {} },
    filters = { dotfiles = false, custom = { "^.git$", ".DS_Store", "__pycache__", "*/packer_compiled.lua" } },
    git = { timeout = 500, ignore = false },
    trash = { cmd = "rip", require_confirm = true },
    filesystem_watchers = {
      enable = true,
      debounce_delay = 50,
    },
    actions = {
      open_file = {
        resize_window = false,
        window_picker = {
          enable = true,
          chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
          exclude = {
            filetype = { "notify", "qf", "diff", "fugitive", "fugitiveblame" },
            buftype = { "nofile", "terminal", "help" },
          },
        },
      },
    },
  })
end

config.gitsigns = function()
  require("gitsigns").setup({
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,
      ["n <LocalLeader>]g"] = {
        expr = true,
        "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'",
      },
      ["n <LocalLeader>[g"] = {
        expr = true,
        "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'",
      },
      ["v <LocalLeader>hs"] = '<cmd>lua require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
      ["v <LocalLeader>hr"] = '<cmd>lua require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
      ["n <LocalLeader>hs"] = '<cmd>lua require("gitsigns").stage_hunk()<CR>',
      ["n <LocalLeader>hu"] = '<cmd>lua require("gitsigns").undo_stage_hunk()<CR>',
      ["n <LocalLeader>hr"] = '<cmd>lua require("gitsigns").reset_hunk()<CR>',
      ["n <LocalLeader>hR"] = '<cmd>lua require("gitsigns").reset_buffer()<CR>',
      ["n <LocalLeader>hp"] = '<cmd>lua require("gitsigns").preview_hunk()<CR>',
      ["n <LocalLeader>hb"] = '<cmd>lua require("gitsigns").blame_line({full = true})<CR>',
      -- Text objects
      ["o ih"] = ':<C-U>lua require("gitsigns").text_object()<CR>',
      ["x ih"] = ':<C-U>lua require("gitsigns").text_object()<CR>',
    },
    numhl = true,
    word_diff = true,
    current_line_blame = true,
    current_line_blame_opts = { delay = 1000, virtual_text_pos = "eol" },
    diff_opts = { internal = true },
  })
end

config.nvim_bufferline = function()
  local icons = { ui = require("modules.ui.icons").get("ui") }

  local options = {
    options = {
      number = nil,
      modified_icon = icons.ui.Modified,
      buffer_close_icon = icons.ui.Close,
      left_trunc_marker = icons.ui.Left,
      right_trunc_marker = icons.ui.Right,
      max_name_length = 14,
      max_prefix_length = 13,
      tab_size = 20,
      show_buffer_close_icons = true,
      show_buffer_icons = true,
      show_tab_indicators = true,
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      separator_style = "thin",
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "center",
          padding = 1,
        },
        {
          filetype = "undotree",
          text = "Undo Tree",
          text_align = "center",
          highlight = "Directory",
          separator = true,
        },
      },
      diagnostics_indicator = function(count)
        return "(" .. count .. ")"
      end,
    },
    -- Change bufferline's highlights here! See `:h bufferline-highlights` for detailed explanation.
    highlights = {},
  }

  if vim.g.colors_name == "catppuccin" then
    local cp = require("modules.utils").get_palette()
    cp.none = "NONE" -- Special setting for complete transparent fg/bg.

    local catppuccin_hl_overwrite = {
      highlights = require("catppuccin.groups.integrations.bufferline").get({
        styles = { "italic", "bold" },
        custom = {
          mocha = {
            -- Hint
            hint = { fg = cp.rosewater },
            hint_visible = { fg = cp.rosewater },
            hint_selected = { fg = cp.rosewater },
            hint_diagnostic = { fg = cp.rosewater },
            hint_diagnostic_visible = { fg = cp.rosewater },
            hint_diagnostic_selected = { fg = cp.rosewater },
          },
        },
      }),
    }

    options = vim.tbl_deep_extend("force", options, catppuccin_hl_overwrite)
  end

  require("bufferline").setup(options)
end

config.indent_blankline = function()
  require("indent_blankline").setup({
    char = "│",
    show_first_indent_level = true,
    filetype_exclude = {
      "startify",
      "dashboard",
      "alpha",
      "log",
      "fugitive",
      "gitcommit",
      "vimwiki",
      "markdown",
      "json",
      "txt",
      "vista",
      "help",
      "todoist",
      "NvimTree",
      "peekaboo",
      "git",
      "TelescopePrompt",
      "undotree",
      "flutterToolsOutline",
      "", -- for all buffers without a file type
    },
    buftype_exclude = { "terminal", "nofile" },
    show_trailing_blankline_indent = false,
    show_current_context = true,
    context_patterns = {
      "class",
      "function",
      "method",
      "block",
      "list_literal",
      "selector",
      "^if",
      "^table",
      "if_statement",
      "while",
      "for",
      "type",
      "var",
      "import",
    },
    space_char_blankline = " ",
  })
end

return config
