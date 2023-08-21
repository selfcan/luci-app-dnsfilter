local SYS = require "luci.sys"
local UCI = require"luci.model.uci".cursor()

m = Map("dnsfilter")
m.title = translate("DNS Filter")
m.description = translate("Support filtering unscientific, fraudulent and custom domains. Support third-party rules. Lightweight.").." <a href=\"https://github.com/kongfl888/luci-app-dnsfilter/blob/main/README.cn\" target=\"_blank\" style=\"color:mediumturquoise\" >GITHUB</a>"
m:section(SimpleSection).template = "dnsfilter/dnsfilter_status"

s = m:section(TypedSection, "dnsfilter")
s.anonymous = true

o = s:option(Flag, "enable", translate("Enable"))
o.rmempty = false

o = s:option(Flag, "block_ios", translate("Block Apple iOS OTA update"))
o.rmempty = false
o.default = 0

o = s:option(Flag, "block_cnshort", translate("Block CNshort APP and Website"))
o.rmempty = false
o.default = 0

o = s:option(Flag, "easy_github", translate("Easy to Visit GitHub Website"))
o.rmempty = false
o.default = 0

o = s:option(Flag, "safe_search", translate("Safe Search"))
o.description = translate("Enforcing SafeSearch for Google Bing Duckduckgo Yandex and Youtube.")
o.rmempty = false
o.default = 0

o = s:option(Flag, "cron_mode", translate("Enable automatic update rules"))
o.rmempty = false
o.default = 1

o = s:option(Flag, "app_test", translate("Check After Update"))
o.rmempty = false
o.default = 1
o:depends("cron_mode",1)

o = s:option(ListValue, "time_update", translate("Update time (every day)"))
for s = 0,23 do
o:value(s, s .. ':00')
end
o.default = 7
o:depends("cron_mode",1)

tmp_rule = 0
if nixio.fs.access("/tmp/dnsfilter/rules.conf") then
tmp_rule = 1
UD = SYS.exec("cat /tmp/dnsfilter/dnsfilter.updated 2>/dev/null")
rule_count = tonumber(SYS.exec("sed -r '/^$/d' /tmp/dnsmasq.dnsfilter/rules.conf 2>/dev/null | wc -l"))
o = s:option(DummyValue, "1", translate("Subscribe Rules Data"))
o.rawhtml = true
o.template = "dnsfilter/dnsfilter_refresh"
o.value = rule_count.." "..translate("Records")
o.description = string.format(translate("AdGuardHome / Host / DNSMASQ / Domain rules auto-convert").."<br/><strong>"..translate("Last Update Checked")..":</strong> %s<br/>",UD)
end

o = s:option(Flag, "flash", translate("Save rules to flash"))
o.description = translate("Should be enabled when rules addresses are slow to download")
o.rmempty = false
o.default = 0

if tmp_rule == 1 then
	o = s:option(Button, "delete", translate("Delete All Subscribe Rules"))
	o.inputstyle = "reset"
	o.description = translate("Delete rules files and delete the subscription link<br/>There is no need to click for modify the subscription link,The script will automatically replace the old rule file")
	o.write = function()
		SYS.exec("[ -d /etc/dnsfilter/rules ] && rm -rf /etc/dnsfilter/rules")
		SYS.exec("echo -n > /tmp/dnsfilter/rules.conf")
		SYS.exec("echo -n > /tmp/dnsfilter/url")
		SYS.exec("/etc/init.d/dnsmasq restart 2>&1 &")
		luci.http.redirect(luci.dispatcher.build_url("admin", "services", "dnsfilter", "base"))
	end
end

o = s:option(DynamicList, "url", translate("Filter Rules Subscription URL"))
o:value("https://cdn.jsdelivr.net/gh/privacy-protection-tools/anti-AD@master/adblock-for-dnsmasq.conf", translate("anti-AD (Privacy-Protect|Preferred)"))
o:value("https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt", translate("AdGuard"))
o:value("https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt", translate("Easylistchina+Easylist"))
o:value("https://anti-ad.net/easylist.txt", translate("anti-AD"))
o:value("https://cats-team.coding.net/p/adguard/d/AdRules/git/raw/main/adguard.txt", translate("cats-team"))
o:value("https://cdn.jsdelivr.net/gh/sbwml/halflife-list@master/ad-pc.txt", translate("halflife"))
o:value("https://anti-ad.net/anti-ad-for-dnsmasq.conf", translate("adti-ad"))


local dnsn=UCI:get("dhcp","@dnsmasq[0]","cachesize") or "150"

o = s:option(Value, "dns_cache", translate("DNS Cache"))
o.description = translate("DNS Cache Now:").."<b><span style=\"color:green\"> "..dnsn.."</span></b><br />"..translate("Set DNS cache, 150 by default (range 0-10000, 0 not cached).")
o.datatype = "range(0,10000)"
o.default = 600

local apply =luci.http.formvalue("cbi.apply")
if apply then
    if SYS.init.index("dnsfilter") then
        SYS.exec("/usr/share/dnsfilter/apply &")
    end
end

return m
