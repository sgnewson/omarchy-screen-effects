.pragma library

var catalog = [
  { id: "fireworks", label: "Fireworks", icon: "󰂪" },
  { id: "stars", label: "Stars", icon: "󰙴" },
  { id: "flowers", label: "Flowers", icon: "󰧱" },
  { id: "embers", label: "Embers", icon: "󰈸" },
  { id: "meteors", label: "Meteors", icon: "󰖒" },
  { id: "fireflies", label: "Fireflies", icon: "󰌵" },
  { id: "confetti", label: "Confetti", icon: "󰝶" },
  { id: "snow", label: "Snow", icon: "󰼶" },
  { id: "rain", label: "Rain", icon: "󰖗" },
  { id: "aurora", label: "Aurora", icon: "󰔏" },
  { id: "bokeh", label: "Bokeh", icon: "󰽢" },
  { id: "heat", label: "Heat", icon: "󰜬" },
  { id: "off", label: "Off", icon: "󰂲" }
]

function canonical(name) {
  var value = String(name || "").replace(/\s+/g, "")
  if (value === "sparkle") return "stars"
  if (value === "flower") return "flowers"
  if (value === "none") return "off"
  return value || "off"
}

function parseCurrent(text) {
  var value = canonical(text)
  for (var i = 0; i < catalog.length; i++) {
    if (catalog[i].id === value) return value
  }
  return "off"
}

function entryFor(id) {
  var value = parseCurrent(id)
  for (var i = 0; i < catalog.length; i++) {
    if (catalog[i].id === value) return catalog[i]
  }
  return catalog[catalog.length - 1]
}

function iconFor(id) {
  return entryFor(id).icon
}

function labelFor(id) {
  return entryFor(id).label
}
