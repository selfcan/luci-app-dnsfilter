local fs = require "nixio.fs"
local conffile = "/etc/dnsfilter/white.list"

f = SimpleForm("custom")
t = f:field(TextValue, "conf")
t.rmempty = true
t.rows = 13
t.description = translate("Do NOT filter these Domain. abc.xyz same as *.abc.xyz")

function t.cfgvalue()
	return fs.readfile(conffile) or ""
end

function f.handle(self,state,data)
	if state == FORM_VALID then
		if data.conf then
			fs.writefile(conffile,data.conf:gsub("\r\n","\n"))
		end
		luci.sys.exec("for i in $(cat /etc/dnsfilter/white.list);do [ -s /tmp/dnsfilter/rules.conf ] && sed -i -e \"/\\/$i\\//d\" -e \"/\\.$i\\//d\" /tmp/dnsfilter/rules.conf 2>/dev/null;\\\
		[ -s /etc/dnsfilter/rules/rules.conf ] && sed -i -e \"/\\/$i\\//d\" -e \"/\\.$i\\//d\" /etc/dnsfilter/rules/rules.conf;done;\\\
		/etc/init.d/dnsmasq restart")
	end
	return true
end

return f
