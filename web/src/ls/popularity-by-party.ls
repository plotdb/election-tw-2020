(->
  lc = {target: '中華統一促進黨'}
  colorscale = d3.interpolateInferno
  move = -> if window.innerWidth < 768 => scrollto \#popularity-by-party-anchor

  legendView = new ldView do
    root: 'div[ld-scope="popularity-by-party-map"]'
    init-render: false
    handler: do
      label: do
        list: -> ([1] ++ [lc.range.max to lc.range.min by -lc.range.size / 6]).sort((a,b) -> b - a)
        handle: ({data,node,idx}) ->
          v = (data - lc.range.min) / lc.range.size
          node.style.order = idx
          ld$.find(node, '.dot', 0).style.background = colorscale v
          ld$.find(node, '.name', 0).innerHTML = (
            """#{if data == 1 => "<span class='text-sm'>(全國平均)</span>" else ''}""" + 
            "#{Math.round(data * 100)/100}<span class='text-sm'>倍</span>"
          )

  render = debounce 50, ->
    lc.map.fit!
    lc.rate = rate = {}
    for k,v of lc.data =>
      if k == \全國 => continue
      rate[k] = (v[lc.target]/v["總計"]) / (lc.data["全國"][lc.target]/lc.data["全國"]["總計"])
    list = [v for k,v of rate]
    lc.range = do
      min: Math.min.apply null, list
      max: Math.max.apply null, list
    lc.range.size = lc.range.max - lc.range.min
    legendView.render!

    d3.select lc.map.root .selectAll \path
      .attr \stroke, -> \#fff
      .attr \stroke-width, -> 0.001
      .transition!duration 350
      .attr \fill, ->
        r = rate[it.properties.name]
        v = (r - lc.range.min) / (lc.range.max - lc.range.min)
        colorscale (v)
  lc.map = pdmaptw.create {
    root: ld$.find(document, '#map-popularity-by-party-map', 0)
    type: \town
    popup: popup-wrap (({data, evt, node}) ->
      node.innerHTML += """
      <div>#{Math.round(lc.rate[data.properties.name]*100)/100}<span class='text-sm'>倍</span></div>
      """
    )
  }
  lc.map.init!
    .then ->
      ld$.fetch "assets/data/政黨票.json", {method: \GET}, {type: \json}
    .then (data) ->
      lc.data = data
      lc.party = [k for k of lc.data["台東縣成功鎮"]].filter -> it != '總計'
    .then ->
      view = new ldView do
        root: '[ld-scope="popularity-by-party"]'
        action: do
          input: do
            "party-select": ({node}) ->
              lc.target = node.value
              view.getAll(\party-select).map -> it.value = node.value
              move!
              render!
          click: do
            "setparty": ({node}) ->
              view.get(\party-select).value = lc.target = node.getAttribute \data-value
              move!
              render!

        handler: do
          "party-option": do
            list: -> lc.party
            handle: ({data, node}) ->
              node.innerText = data
              node.setAttribute \value, data
      view.getAll(\party-select).map -> it.value = "中華統一促進黨"
    .then ->
      render!
)!
