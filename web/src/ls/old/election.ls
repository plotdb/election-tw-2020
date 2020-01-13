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

  lc = {}
  lc.obj1 = pdmaptw.create {root: (ld$.find(document, \#map1, 0)), type: \town}
  lc.obj2 = pdmaptw.create {root: (ld$.find(document, \#map2, 0)), type: \town}
  lc.obj1.init!
    .then -> lc.obj2.init!
    .then ->
      ld$.fetch "assets/election.json", {method: \GET}, {type: \json}
    .then (data) ->
      lc.data = data
      lc.hash = {}
      list = lc.data.map -> it.vote / it.total
      lc.min = Math.min.apply null, list
      lc.max = Math.max.apply null, list
      invalid-list = lc.data.map -> (it.vote - it.valid) / it.vote
      lc.invalid = do
        min: Math.min.apply null, invalid-list
        max: Math.max.apply null, invalid-list
      for item in data => lc.hash[item.name] = item
      console.log lc.invalid
    .then -> 
      obj = lc.obj1
      obj.fit!
      data = lc.data[* - 1]
      max = Math.max.apply null, obj.lc.meta.name.map(-> data[it] or 0)
      d3.select obj.root .selectAll \path
        .attr \fill, ->
          name = patch(obj.lc.meta.name[it.properties.c] + obj.lc.meta.name[it.properties.t])
          v = lc.hash[name].vote / lc.hash[name].total
          #v = lc.hash[name].valid / lc.hash[name].total
          v = (v - lc.min ) / (lc.max - lc.min)
          #v = (lc.hash[name].vote - lc.hash[name].valid) / lc.hash[name].total
          #d3.interpolateLab('#2b7','#fff')(v)
          d3.interpolateRdBu v
        .attr \stroke, -> \#000
        .attr \stroke-width, -> 0.00
      view = new ldView do
        root: '[ld-scope=vote]'
        handler:
          label: do
            list: -> [1 to 0 by -0.2]
            handle: ({data,node}) ->
              ld$.find(node, '.dot', 0).style.background = d3.interpolateRdBu data
              v = data * (lc.max - lc.min) + lc.min
              ld$.find(node, '.name', 0).innerText = "#{Math.round(v * 100)}%"

    .then -> 
      obj = lc.obj2
      obj.fit!
      data = lc.data[* - 1]
      d3.select obj.root .selectAll \path
        .attr \fill, ->
          name = patch(obj.lc.meta.name[it.properties.c] + obj.lc.meta.name[it.properties.t])
          v = (lc.hash[name].vote - lc.hash[name].valid) / lc.hash[name].vote
          #v = lc.hash[name].valid / lc.hash[name].total
          v = 1 - (v - lc.invalid.min ) / (lc.invalid.max - lc.invalid.min)
          #v = (lc.hash[name].vote - lc.hash[name].valid) / lc.hash[name].total
          #d3.interpolateLab('#2b7','#fff')(v)
          d3.interpolatePiYG v
        .attr \stroke, -> \#000
        .attr \stroke-width, -> 0.00
      view = new ldView do
        root: '[ld-scope=invalid]'
        handler:
          label: do
            list: -> [1 to 0 by -0.2]
            handle: ({data,node}) ->
              ld$.find(node, '.dot', 0).style.background = d3.interpolatePiYG 1 - data
              v = data * (lc.invalid.max - lc.invalid.min) + lc.invalid.min
              ld$.find(node, '.name', 0).innerText = "#{Math.round(v * 1000)/10}%"

)!
