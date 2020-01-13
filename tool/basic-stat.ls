require! <[fs fs-extra cheerio request chainify progress colors]>

fs-extra.ensure-dir-sync '../dist'

# 取得2020選舉基本資料: 鄉鎮分級之投票權人口數, 投票人數, 有效票數
fetch = (id) -> new Promise (res, rej) ->
  (e,r,code) <- request {
    url: "https://www.cec.gov.tw/pc/zh_TW/FP1/#{id}000000000000.html"
    method: \GET
  }, _
  $ = cheerio.load code
  county = $('table b').text!split(/\s/).1.trim!
  ret = []
  Array.from($('.tableT .trT')).map ->
    tds = $(it).find('td')
    name = "#{county}#{$(tds.0).text!}".replace(/臺/g,'台').replace(/總計$/,'')
    # 具投票權人口數
    total = +($(tds.1).text!replace(/,/g,''))
    # 投票人數
    vote = +($(tds.2).text!replace(/,/g,''))
    # 有效票數
    valid = +($(tds.3).text!replace(/,/g,''))
    ret.push {name, total, vote, valid}
  res ret

# 全台縣市代碼
list = <[
  63000 65000 68000 66000 67000 64000 09007 09020 10002 10004
  10005 10007 10008 10009 10010 10013 10015 10014 10016 10017
  10018 10020
]>
bar = new progress(
  "   fetching [#{':bar'.yellow}] #{':percent'.cyan} :etas",
  { total: list.length, width: 60, complete: '#' }
)

chainify list, ({item}) -> bar.tick!; fetch item
  .then (ret) ->
    list = []
    ret.data.map -> list ++= it.data
    hash = {}
    sum = {name: "全國"}
    list.map (item) ->
      hash[item.name] = item
      if item.name.length <= 4 => <[total vote valid]>.map (p) -> sum[p] = (sum[p] or 0) + item[p]
    hash["全國"] = sum
    fs.write-file-sync '../dist/投票數.json', JSON.stringify(hash)
