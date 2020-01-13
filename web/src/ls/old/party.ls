(->
  patch = -> it.replace /臺/g, '台'
  color = do
    "合一行動聯盟": null
    "中華統一促進黨": null
    "親民黨": \#f90
    "安定力量": null
    "台灣基進": null
    "時代力量": \#ff0
    "新黨": null
    "喜樂島聯盟": null
    "中國國民黨": \#00f
    "一邊一國行動黨": null
    "勞動黨": null
    "綠黨": null
    "宗教聯盟": null
    "民主進步黨": \#0f0
    "台灣民眾黨": \#0ff
    "台灣維新": null
    "台澎黨": null
    "國會政黨聯盟": null
    "台灣團結聯盟": null

  lc = {map: {}}
  lc.map.win  = pdmaptw.create {root: (ld$.find(document, \#win, 0)), type: \town}
  lc.map.lose = pdmaptw.create {root: (ld$.find(document, \#lose, 0)), type: \town}
  lc.map.win.init!
    .then -> lc.map.lose.init!
    .then ->
      ld$.fetch "assets/party-rank.json", {method: \GET}, {type: \json}
    .then (data) -> lc.data = data
    .then -> 
      for type in <[win lose]> =>
        obj = lc.map[type]
        obj.fit!
        d3.select obj.root .selectAll \path
          .attr \fill, ->
            name = patch(obj.lc.meta.name[it.properties.c] + obj.lc.meta.name[it.properties.t])
            try
              c = color[lc.data[name][type].0] or \#ccc
            catch e
              c = 'rgba(0,0,0,.5)'
            return c
          .attr \stroke, -> \#000
          .attr \stroke-width, -> 0.00
        view = new ldView do
          root: "[ld-scope=#type]"
          handler:
            label: do
              list: -> [[k,v] for k,v of color].filter(->it.1).map(->it.0) ++ ["其它"]
              handle: ({data,node}) ->
                ld$.find(node, '.dot', 0).style.background = color[data] or \#ccc
                ld$.find(node, '.name', 0).innerText = data

)!
