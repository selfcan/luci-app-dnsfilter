# OPEN SOURCE

This [K/luci-app-dnsfilter](https://github.com/kongfl888/luci-app-dnsfilter)

Base on [small_5/luci-app-adblock-plus](https://github.com/small-5/luci-app-adblock-plus). Fork form [kiddin9/luci-app-dnsfilter](https://github.com/kiddin9/luci-app-dnsfilter)

基于项目的背景，如果你需要再次开发，请保留本README及以上文字。遵循开源的协议，项目内包括我的代码（每个字）请随意处置。请记住开源协议为GPLv2。也不要用于商业用途。

If you need to develop again, please KEEP the above text.

LICENSE: GPLv2


# 基于 DNS 的域名过滤 for OpenWrt

## 说明

请把它当成一个域名过滤器，不要把它当成什么去广告插件，这很重要，所以强调，谢谢合作。

它就是dnsmasq的某个具体功能的LUCI APP/GUI，不涉及C语言这类高级语言的编写和编译。所有的功能都是方便设置，所有设置都基于dnsmasq自身，dnsmasq除非有代替否则它就是OP甚至Linux系不可或缺的DHCP/DNS工具。

属于路由器系统本身的功能。

所以没必要把它当成你懂的来隐晦和屏蔽。如同Windows系统自带的hosts一样，没有针对谁。

dnsmasq能用它就能用，出现突然不知道怎么回事请从系统日志和订阅规则上找问题。

DNS. Yep, you know.

## 功能

- 支持 AdGuardHome/Host/DNSMASQ/Domain 格式的第三方规则订阅

- 规则自动识别, 自动去重, 定时更新

- 自定义黑白名单

You know, DNS, yep!

## 编译说明

本项目依赖于```dnsmasq-full```，与OpenWrt默认的```dnsmasq```可能冲突，所以编译时请确保已经取消勾选```base-system -> dnsmasq```

Yep! DNS, you know.
