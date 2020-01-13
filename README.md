# election-2020

cec crawler for 2020 election and visualization


# Usage

利用 tool/ 下的 livecsript 來撈取中選會有關 2020 選舉的資料 ( 不包含分區立委 )

 * basic-stat.ls
   - 基本統計 ( 投票權人口數, 投票人數, 有效票數 )
 * dominant-party.ls
   - 相對最支持 / 最不支持政黨計算.
 * fetch-town-code.ls
   - 利用 town.topo.json 轉出鄉鎮代碼, 用於爬取網頁
 * party-president-diff.ls
   - 計算政黨與總統票的差異
 * party.ls
   - 政黨票資訊. 從線上爬取
 * president.ls
   - 總統票資訊. 從線上爬取

預覽圖表:

```
    npm start
```

然後開啟 http://localhsot:3000/


# License

MIT
