require! <[fs]>
party = JSON.parse(fs.read-file-sync '../dist/政黨票.json' .toString!)
president = JSON.parse(fs.read-file-sync '../dist/總統票.json' .toString!)

hash = {}
for town of party =>
  hash[town] = do
    dpp: party[town][\民主進步黨] - president[town]["3"]
    kmt: party[town][\中國國民黨] - president[town]["2"]
    pfp: party[town][\親民黨] - president[town]["1"]

fs.write-file-sync '../dist/政黨總統票差距.json', JSON.stringify(hash)
