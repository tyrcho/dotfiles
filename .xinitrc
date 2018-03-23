#!/bin/sh

userresources=/root/.Xresources
usermodmap=/root/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f  ]; then
    xrdb -merge 
fi

if [ -f  ]; then
    xmodmap 
fi

if [ -f "" ]; then
    xrdb -merge ""
fi

if [ -f "" ]; then
    xmodmap ""
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "" ] && . ""
 done
 unset f
fi

exec i3
#!/bin/sh

userresources=/home/vagrant/.Xresources
usermodmap=/home/vagrant/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f  ]; then
    xrdb -merge 
fi

if [ -f  ]; then
    xmodmap 
fi

if [ -f "" ]; then
    xrdb -merge ""
fi

if [ -f "" ]; then
    xmodmap ""
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "" ] && . ""
 done
 unset f
fi

exec i3
