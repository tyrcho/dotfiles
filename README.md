# Setup
From home folder (windows / linux)
    
    git init
    git remote add origin  git@github.com:tyrcho/dotfiles.git
    git pull origin master
    echo * > .git/info/exclude

Why ? 
- can't `git clone` into an existing folder
- want all other files in ~ to be ignore by default
  * will use `git add -f` to force add new dotfiles
