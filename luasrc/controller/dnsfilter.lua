module("luci.controller.dnsfilter", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/dnsfilter") then
		return
	end

	local page = entry({"admin", "services", "dnsfilter"}, alias("admin", "services", "dnsfilter", "base"), _("DNS Filter"), 9)
	page.dependent = true
	page.acl_depends = { "luci-app-dnsfilter" }

	entry({"admin", "services", "dnsfilter", "base"}, cbi("dnsfilter/base"), _("Base Setting"), 10).leaf = true
	entry({"admin", "services", "dnsfilter", "white"}, form("dnsfilter/white"), _("White Domain List"), 20).leaf = true
	entry({"admin", "services", "dnsfilter", "black"}, form("dnsfilter/black"), _("Block Domain List"), 30).leaf = true
	entry({"admin", "services", "dnsfilter", "ip"}, form("dnsfilter/ip"), _("Block IP List"), 40).leaf = true
	entry({"admin", "services", "dnsfilter", "log"}, form("dnsfilter/log"), _("Log"), 50).leaf = true
	entry({"admin", "services", "dnsfilter", "run"}, call("act_status")).leaf = true
	entry({"admin", "services", "dnsfilter", "refresh"}, call("refresh_data"))
end

function act_status()
	local e = {}
	e.running = luci.sys.call("[ -s /tmp/dnsmasq.d/dnsfilter.conf ]") == 0
	e.testdns = luci.sys.call("sh /usr/share/dnsfilter/testdns") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function refresh_data()
	local set = luci.http.formvalue("set")
	local icount = 0
	local icount1 = 0
	local icount2 = 0

	luci.sys.exec("/usr/share/dnsfilter/addown --down 1")
	icount1 = luci.sys.exec("find /tmp/dnsfilter -type f -name rules.conf -exec cat {} \\; 2>/dev/null | wc -l")
	icount2 = luci.sys.exec("find /etc/dnsfilter/rules/ -type f -name rules.conf -exec cat {} \\; 2>/dev/null | wc -l")
	if tonumber(icount1) == 0 then
		icount=icount2
	else
		icount=icount1
	end
	if tonumber(icount) > 0 then
		luci.sys.exec("/etc/init.d/dnsmasq restart &")
		retstring = tostring(math.ceil(tonumber(icount)))
	else
		retstring = "-1"
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=retstring,retcount=icount})
end
