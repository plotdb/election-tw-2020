(->
  patch = -> it.replace /臺/g, '台'
  inst = (opt = {}) ->
    @root = if typeof(opt.root) == typeof('') => document.querySelector(opt.root) else opt.root
    @ <<< {lc: {}, type: opt.type}
    @

  inst.prototype = Object.create(Object.prototype) <<< do
    init: ->
      {root, type} = @{root, type}
      ld$.fetch "assets/lib/pdmap.tw/#type.topo.json", {method: \GET}, {type: \json}
        .then (topo) ~>
          @lc.topo = topo
          ld$.fetch "assets/lib/pdmap.tw/#type.meta.json", {method: \GET}, {type: \json}
        .then (meta) ~>
          @lc.meta = meta
          @lc.features = features = topojson.feature(@lc.topo, @lc.topo.objects["pdmaptw"]).features
          @lc.path = path = d3.geoPath().projection(pdmaptw.projection)
          d3.select(root).append(\svg).append(\g)
            .selectAll \path
            .data features
            .enter!
              .append \path
              .attr \d, path

    fit: ->
      root = @root
      g = ld$.find root, \g, 0
      svg = d3.select(root).select(\svg)
      svg.attr \width, \100%
      svg.attr \height, \100%
      bcr = root.getBoundingClientRect!
      bbox = g.getBBox!
      [width,height] = [bcr.width,bcr.height]
      padding = 20
      scale = Math.min((width - 2 * padding) / bbox.width, (height - 2 * padding) / bbox.height)
      [w,h] = [width / 2, height / 2]
      g.setAttribute(
        \transform
        "translate(#w,#h) scale(#scale) translate(#{-bbox.x - bbox.width/2},#{-bbox.y - bbox.height/2})"
      )

  pdmaptw.create = (opt = {}) -> new inst opt

  lc = {map: {}}
  lc.map.kmt = pdmaptw.create {root: (ld$.find(document, \#kmt, 0)), type: \town}
  lc.map.dpp = pdmaptw.create {root: (ld$.find(document, \#dpp, 0)), type: \town}
  lc.map.kmt.init!
    .then -> lc.map.dpp.init!
    .then ->
      ld$.fetch "assets/election.json", {method: \GET}, {type: \json}
    .then (data) ->
      lc.data = data
      lc.stat = {}
      for item in lc.data => lc.stat[item.name] = item
      ld$.fetch "assets/kmt-diff.json", {method: \GET}, {type: \json}
    .then (data) ->
      lc.kmt = data
      ld$.fetch "assets/dpp-diff.json", {method: \GET}, {type: \json}
    .then (data) ->
      lc.dpp = data
    .then ->
      lc.range = {}
      for name in <[kmt dpp]> =>
        for k,v of lc[name] => v.diff = (v.party - v.president) / v.president #lc.stat[k].president
        list = [v.diff for k,v of lc[name]]
        lc.range[name] = do
          min: Math.min.apply null, list
          max: Math.max.apply null, list
        if lc.range[name].max > -lc.range[name].min => lc.range[name].min = -lc.range[name].max
        if lc.range[name].min < -lc.range[name].max => lc.range[name].max = -lc.range[name].min
        lc.range[name].size = lc.range[name].max - lc.range[name].min
      lc.range.max = Math.max lc.range.kmt.max, lc.range.dpp.max
      lc.range.min = Math.min lc.range.kmt.min, lc.range.dpp.min
      lc.range.size = lc.range.max - lc.range.min

    .then -> 
      for party in <[kmt dpp]> =>
        obj = lc.map[party]
        obj.fit!
        d3.select obj.root .selectAll \path
          .attr \fill, ->
            name = patch(obj.lc.meta.name[it.properties.c] + obj.lc.meta.name[it.properties.t])
            try
              u = v = lc[party][name].diff
              v = ( v - lc.range.min ) / lc.range.size
              #if u > 0 =>
              #  v = 1
              #  console.log name
              return d3.interpolateRdBu v
            catch e
              return 'rgba(0,0,0,.5)'
          .attr \stroke, -> \#000
          .attr \stroke-width, -> 0.00
        view = new ldView do
          root: "[ld-scope=#party]"
          handler:
            label: do
              list: -> [1 to 0 by -0.2]
              handle: ({data,node}) ->
                ld$.find(node, '.dot', 0).style.background = d3.interpolateRdBu data
                v = data * (lc.range.size) + lc.range.min
                ld$.find(node, '.name', 0).innerText = "#{Math.round(v * 100)}%"

)!
