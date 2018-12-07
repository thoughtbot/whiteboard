// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import {Socket} from "phoenix"
let socket = new Socket("/socket", {params: {}})
socket.connect()

let channel = socket.channel(`board:${window.boardId}`, {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

import { Elm } from "../src/Main.elm";

var app = Elm.Main.init({
    node: document.getElementById('elm-main')
});

app.ports.sendPoints.subscribe(function(point) {
  channel.push("new_event", point)
});

channel.on("new_event", payload => {
  app.ports.incomingPaths.send(payload)
})
window.addEventListener('scroll', function() {
  app.ports.scrollEvents.send({})
});
