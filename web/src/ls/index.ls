popup-node = ld$.find(document.body, '#popup', 0)
popup = ({evt, data}) ->
  popup-node.style.top = "#{10 + evt.clientY + document.scrollingElement.scrollTop}px"
  popup-node.style.left = "#{10 + evt.clientX + document.scrollingElement.scrollLeft}px"
  popup-node.innerText = data.properties.name
popup-wrap = (cb) -> ({evt, data}) -> popup {evt, data}; cb {evt, data, node: popup-node}
