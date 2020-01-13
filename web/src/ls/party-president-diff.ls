(->
  lc = {map: {}}
  popup1 = popup-wrap ({data, evt, node}) ->
    node.innerHTML += "<div>#{Math.round(1000 * lc.rate[data.properties.name].kmt)/10}%</div>"
  popup2 = popup-wrap ({data, evt, node}) ->
    node.innerHTML += "<div>#{Math.round(1000 * lc.rate[data.properties.name].dpp)/10}%</div>"

  lc.map.kmt = pdmaptw.create {root: (ld$.find(document, \#map-diff-kmt, 0)), type: \town, popup: popup1}
  lc.map.dpp = pdmaptw.create {root: (ld$.find(document, \#map-diff-dpp, 0)), type: \town, popup: popup2}
  lc.map.kmt.init!
    .then -> 
      lc.map.dpp.init!

    .then ->
      ld$.fetch "assets/data/政黨總統票差距.json", {method: \GET}, {type: \json}
    .then (data) ->
      lc.data = data
      ld$.fetch "assets/data/總統票.json", {method: \GET}, {type: \json}
    .then (data) ->
      lc.president = president = data
      lc.rate = {}
      lc.range = {}
      for town,obj of lc.data =>
        lc.rate[town] = do
          pfp: obj.pfp / president[town].1
          kmt: obj.kmt / president[town].2
          dpp: obj.dpp / president[town].3
      for p in <[kmt dpp pfp]> =>
        list = [v[p] for k,v of lc.rate]
        lc.range[p] = do
          min: Math.min.apply null, list
          max: Math.max.apply null, list
        #if lc.range[p].max > -lc.range[p].min => lc.range[p].min = -lc.range[p].max
        #if lc.range[p].min < -lc.range[p].max => lc.range[p].max = -lc.range[p].min
        lc.range[p].size = lc.range[p].max - lc.range[p].min

      lc.range.max = Math.max lc.range.kmt.max, lc.range.dpp.max
      lc.range.min = Math.min lc.range.kmt.min, lc.range.dpp.min
      lc.range.size = lc.range.max - lc.range.min

    .then -> 
      for party in <[kmt dpp]> =>
        obj = lc.map[party]
        obj.fit!
        d3.select obj.root .selectAll \path
          .attr \fill, ->
            v = lc.rate[it.properties.name][party]
            v = if v > 0 => 0.5 + (0.5 * v / (lc.range.max)) else (0.5 * ( v - lc.range.min ) / -lc.range.min)
            v = 0.1 + v * 0.8
            return d3.interpolateRdBu v
          .attr \stroke, -> \#fff
          .attr \stroke-width, -> 0.001
        view = new ldView do
          root: "[ld-scope=diff-#party]"
          handler:
            label: do
              list: ->
                b = [0 to lc.range.min by lc.range.min / 3]
                [lc.range.max] ++ b
              handle: ({data,node}) ->
                v = data
                v = if v > 0 => 0.5 + (0.5 * v / (lc.range.max)) else (0.5 * ( v - lc.range.min ) / -lc.range.min)
                v = 0.1 + v * 0.8
                ld$.find(node, '.dot', 0).style.background = d3.interpolateRdBu v
                ld$.find(node, '.name', 0).innerText = "#{Math.round(data * 1000)/10}%"

)!
