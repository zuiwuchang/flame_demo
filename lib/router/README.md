# router

flame 允許使用 name 註冊路由，然後就可以使用 pushNamed/pop 管理路由棧

路由默認不透明的這會阻止後方路由的顯示和事件接收。但可以將其設置爲透明這樣後方路由將繼續顯示和接收事件

# overlays

也可以使用 pushOverlay/pop 管理 overlays，但不要和 overlays.add/remove 混用

add/remove 不會進入路由棧，混用可能產生 bug

# ValueRoute

使用 pushAndWait 可以用於等待一個 ValueRoute 返回一個值