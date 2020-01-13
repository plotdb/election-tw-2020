require! <[fs]>
party = JSON.parse(fs.read-file-sync '../dist/政黨票.json' .toString!)

rate = {}
for town,obj of party => 
  for p,vote of obj =>
    rate{}[town][p] = vote / obj["總計"]
all = party["全國"]
fs.write-file-sync '../dist/政黨票得票率.json', JSON.stringify(rate)

extreme = {}
avg = rate["全國"]
for town,obj of rate =>
  if town == \全國 => continue
  list = [[p,r] for p,r of obj]
    .filter(-> it.0 != "總計")
    .map -> [it.0, (it.1 - avg[it.0])]
  list.sort (a,b) -> b.1 - a.1
  extreme[town] = win: list.0, lose: list[* - 1]

fs.write-file-sync '../dist/政黨票相對全國落差.json', JSON.stringify(extreme)
