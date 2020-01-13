(->
  patch = -> it.replace /臺/g, '台'
  color = do
    "合一行動聯盟": null
    "中華統一促進黨": null
    "親民黨": \#f90
    "安定力量": null
    "台灣基進": \#984a34
    "時代力量": \#ff0
    "新黨": null
    "喜樂島聯盟": null
    "中國國民黨": \#00f
    "一邊一國行動黨": \#5bafb7
    "勞動黨": null
    "綠黨": \#7ac7a0
    "宗教聯盟": null
    "民主進步黨": \#0f0
    "台灣民眾黨": \#0ff
    "台灣維新": null
    "台澎黨": null
    "國會政黨聯盟": null
    "台灣團結聯盟": \#c6a260
  render = (type) ->
    obj = lc.map[type]
    obj.fit!
    d3.select obj.root .selectAll \path
      .attr \fill, ->
        party = lc.data[it.properties.name][type].0
        c = color[party] or \#ccc
        if lc.highlight and party != lc.highlight => c = '#ccc'
        return c
      .attr \stroke, -> \#000
      .attr \stroke-width, -> 0.00

  popup1 = popup-wrap ({data, evt, node}) ->
    node.innerHTML += "<div>#{lc.data.[data.properties.name].win.0}</div>"
  popup2 = popup-wrap ({data, evt, node}) ->
    node.innerHTML += "<div>#{lc.data.[data.properties.name].lose.0}</div>"

  lc = {map: {}}
  lc.map.win  = pdmaptw.create {root: (ld$.find(document, \#map-relative-party-positive, 0)), type: \town, popup: popup1}
  lc.map.lose = pdmaptw.create {root: (ld$.find(document, \#map-relative-party-negative, 0)), type: \town, popup: popup2}
  lc.map.win.init!
    .then -> lc.map.lose.init!
    .then ->
      ld$.fetch "assets/data/政黨票相對全國落差.json", {method: \GET}, {type: \json}
    .then (data) -> lc.data = data
    .then -> 
      for type in <[win lose]> =>
        render type
        view = new ldView do
          root: "[ld-scope=relative-party-#{if type == \win => \positive else \negative}]"
          handler:
            label: do
              list: -> [[k,v] for k,v of color].filter(->it.1).map(->it.0)
              handle: ({data,node}) ->
                ld$.find(node, '.dot', 0).style.background = color[data] or \#ccc
                ld$.find(node, '.name', 0).innerText = data
                node.setAttribute \data-name, data
                node.classList.add \clickable
      root = ld$.find document, '#map-relative-party', 0
      root.addEventListener \mousemove, (e) ->
        console.log ld$.parent(e.target, '.label', root)
        if !(n = ld$.parent e.target, '.label', root) =>
          if lc.highlight =>
            lc.highlight = null
            render \win
            render \lose
          return
        name = n.getAttribute \data-name
        lc.highlight = name
        render \win
        render \lose



)!
