// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import ClipboardJS from "clipboard"

let clipboard = new ClipboardJS(".copy-btn")

clipboard.on('success', function (e) {

  const prevClass = e.trigger.className

  let timeoutId = null
  let resetClass = () => {
    e.trigger.className = prevClass
    if (timeoutId) {
      window.clearTimeout(timeoutId)
    }
  }

  e.trigger.className += " tooltipped tooltipped-no-delay tooltipped-s"

  timeoutId = window.setTimeout(resetClass, 3000)
  e.trigger.addEventListener('mouseout', resetClass)

  e.clearSelection()
})
