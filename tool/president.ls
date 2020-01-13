require! <[fs cheerio request progress colors chainify]>

patch = -> it.replace /臺/g, '台'

fetch = (code) -> new Promise (res, rej) ->
  (e,r,b) <- request {
    # president
    url: "https://www.cec.gov.tw/pc/zh_TW/P1/n#{code}0000000.html"
    method: \GET
  }, _
  #fs.write-file-sync 'sample.html', b
  #b = fs.read-file-sync 'sample.html' .toString!
  $ = cheerio.load(b)
  ret = []
  n = $('table b').text!split(/\s/)
  # president
  town = patch("#{n.2.trim!}#{n.3.replace('得票數','').trim!}".trim!)
  Array.from($('.tableT .trT')).map ->
    tds = Array.from($(it).find('td'))
    # president
    idx = +($(tds.1).text!trim!replace(/,/g,''))
    vote = +($(tds.4).text!trim!replace(/,/g,''))
    ret.push {idx: idx, vote}
  res {name: town, list: ret}

list = JSON.parse(fs.read-file-sync "town-code.json" .toString!)

bar = new progress(
  "   fetching [#{':bar'.yellow}] #{':percent'.cyan} :etas",
  { total: list.length, width: 60, complete: '#' }
)

chainify list, ({item}) -> bar.tick!; fetch item
  .then (ret) ->
    hash = {}
    sum = {}
    ret.data.map ({data}) ->
      lc = {}
      total = 0
      for p in data.list =>
        lc[p.idx] = p.vote
        total += p.vote
        sum[p.idx] = (sum[p.idx] or 0) +  p.vote
      lc["總計"] = total
      hash[data.name] = lc
    total = [v for k,v of sum].reduce(((a,b) -> a + b),0)
    sum["總計"] = total
    hash["全國"] = sum
    fs.write-file-sync '../dist/總統票.json', JSON.stringify(hash)
