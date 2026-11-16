# dogbrew shell-hooks: if you don't want this to be called, comment it out and dogbrew will honour that on subsequent updates.  See also the more dangerous `dogbrew self setup --disable-shell-hooks`.
test -f "/opt/dogbrew/share/etc/dogbrew/init.fish" && source "/opt/dogbrew/share/etc/dogbrew/init.fish"
