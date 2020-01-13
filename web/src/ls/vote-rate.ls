(->

  get-handler = (range, colorspace, prec = 1, inverse = false, scale = d3.interpolateRdBu) ->
    label: do
      list: -> 
        a = [range.max to range.avg by -(range.max - range.avg) / 3]
        b = [range.avg to range.min by -(range.avg - range.min) / 3]
        a.splice a.length - 1, 1
        a ++ b
      handle: ({data,node}) ->
        v = colorspace(data)
        ld$.find(node, '.dot', 0).style.background = scale (if inverse => 1 - v else v)
        ld$.find(node, '.name', 0).innerHTML = (
          """#{if data == range.avg => "<span class='text-sm'>(全國平均)</span>" else ''}""" +
          """#{Math.round(data * 100 * prec) / prec}%"""
        )


  popup1 = popup-wrap (({data, evt, node}) ->
    obj = lc.hash[data.properties.name]
    node.innerHTML += """
    <div>#{Math.round(1000 * obj.vote / obj.total)/10}%</div>
    """
  )

  popup2 = popup-wrap (({data, evt, node}) ->
    obj = lc.hash[data.properties.name]
    node.innerHTML += """
    <div>#{Math.round(1000 * (obj.vote - obj.valid) / obj.vote)/10}%</div>
    """
  )

  lc = {}
  lc.obj1 = pdmaptw.create {root: (ld$.find(document, \#map-vote-rate, 0)), type: \town, popup: popup1}
  lc.obj2 = pdmaptw.create {root: (ld$.find(document, \#map-invalid-rate, 0)), type: \town, popup: popup2}
  lc.obj1.init!
    .then -> lc.obj2.init!
    .then ->
      ld$.fetch "assets/data/投票數.json", {method: \GET}, {type: \json}
    .then (data) ->
      lc.hash = data
      lc.list = [v for k,v of lc.hash]
      list = lc.list.map -> it.vote / it.total # 投票率
      lc.vote-rate = vr = do # 投票率極值
        min: Math.min.apply null, list
        max: Math.max.apply null, list
        avg: lc.hash["全國"].vote / lc.hash["全國"].total

      list = lc.list.map -> (it.vote - it.valid) / it.vote # 廢票率
      lc.invalid-rate = do # 廢票率極值
        min: Math.min.apply null, list
        max: Math.max.apply null, list
        avg: (lc.hash["全國"].vote - lc.hash["全國"].valid)/ lc.hash["全國"].vote
    .then -> 
      colorspace = (v) ->
        v = if v > range.avg => (0.5 * (v - range.avg) / (range.max - range.avg)) + 0.5
        else 0.5 * (v - range.min) / (range.avg - range.min)
      range = lc.vote-rate
      obj = lc.obj1
      obj.fit!
      d3.select obj.root .selectAll \path
        .attr \fill, ->
          name = it.properties.name
          d3.interpolateRdBu colorspace(lc.hash[name].vote / lc.hash[name].total)
        .attr \stroke, -> \#fff
        .attr \stroke-width, -> 0.005
      view = new ldView do
        root: '[ld-scope=vote-rate]'
        handler: get-handler range, colorspace, 1
    .then -> 
      colorspace = (v) ->
        v = if v > range.avg => (0.5 * (v - range.avg) / (range.max - range.avg)) + 0.5
        else 0.5 * (v - range.min) / (range.avg - range.min)
      range = lc.invalid-rate
      obj = lc.obj2
      obj.fit!
      d3.select obj.root .selectAll \path
        .attr \fill, ->
          name = it.properties.name
          d3.interpolatePiYG(1 - colorspace((lc.hash[name].vote - lc.hash[name].valid) / lc.hash[name].vote))
        .attr \stroke, -> \#000
        .attr \stroke-width, -> 0.00
      view = new ldView do
        root: '[ld-scope=invalid-rate]'
        handler: get-handler range, colorspace, 100, true, d3.interpolatePiYG

)!
