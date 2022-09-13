local fs = require "nixio.fs"
local conffile = "/etc/dnsfilter/ip.list"

f = SimpleForm("custom")
t = f:field(TextValue, "conf")
t.rmempty = true
t.rows = 13
t.description = translate("Will Always block IP/IPs of here. Can use 10.1.1.0/24")

function t.cfgvalue()
	return fs.readfile(conffile) or ""
end

function f.handle(self,state,data)
	if state == FORM_VALID then
		if data.conf then
			fs.writefile(conffile,data.conf:gsub("\r\n","\n"))
		end
		luci.sys.exec("ipset -F blackips 2>/dev/null && for i in $(cat /etc/dnsfilter/ip.list);do ipset add blackips $i 2>/dev/null;done")
	end
	return true
end

return f
