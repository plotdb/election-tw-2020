require! <[fs]>

json = JSON.parse(fs.read-file-sync 'town.topo.json' .toString!)
list = json.objects.out.geometries.map ->
  "#{it.properties.TOWNCODE.substring(0,5)}00#{it.properties.TOWNCODE.substring(5,8)}"

# 金門縣烏坵鄉
if !("0902000060" in list) => list.push "0902000060"
fs.write-file-sync 'town-code.json', JSON.stringify(list)
