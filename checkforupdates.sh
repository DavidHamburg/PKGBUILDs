#!/bin/bash
if [ $# -lt 1 ]; then
    echo "usage: ${0##*/} <repo>"
    exit 1
fi

repo="$1"
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHTBLUE='\033[1;34m'
NC='\033[0m'

# _update_git <dir_name>
_update_git() {
    cd $1
    sudo -u $SUDO_USER git checkout master > /dev/null 2> /dev/null
    sudo -u $SUDO_USER git pull origin master > /dev/null 2> /dev/null
    cd - > /dev/null
}

# _repo_contains <pkgname> <pkgver> <pkgrel>"
_repo_contains() {
    pkgname="$1"
    pkgver="$2"
    pkgrel="$3"
    sudo -u $SUDO_USER /usr/bin/bsdtar -xOqf $repo "$pkgname-$pkgver-$pkgrel" 2> /dev/null
    if [ $? -eq 1 ]; then
        return 1 # false
    else
        return 0 # true
    fi
}

_make_package() {
    cd $1
    HOMEDIR="$(eval echo "~$SUDO_USER")"
    /usr/bin/makechrootpkg -c -r $HOMEDIR/chroot -- -i
    if [ $? -ne 0 ]; then
        echo "makechrootpkg failed." >&2
        exit 1
    fi
    cd - > /dev/null
}

# _pkg_build_srcinfo <packagedir>
_pkg_build_srcinfo() {
    cd $1
    gitsrcinfo="$(sudo -u $SUDO_USER /usr/bin/makepkg --printsrcinfo > /tmp/mypkgsrcinfo)"
    #echo "$gitsrcinfo"
    cd - > /dev/null
}

#_pkg_grep <key>
_pkg_grep() {
    local _ret
    _ret="$(/usr/bin/cat /tmp/mypkgsrcinfo | grep -m 1 "${1} = ")"
    echo "${_ret#${1} = }"
}
#| pcregrep -M --only-matching=1 "\%VERSION\%\n([0-9\-\.]*)"

for i in */
do
    dir=${i::-1}
    if [ "$dir" != "testing" ] && [ "$dir" != "patches" ] && [ "$dir" != "packages" ]; then
        if [ -f "$dir/.git" ] && [ -f "$dir/PKGBUILD" ]; then
            _update_git $dir
            _pkg_build_srcinfo $dir
            pkgname="$(_pkg_grep "pkgname")"
            pkgver="$(_pkg_grep "	pkgver")"
            pkgrel="$(_pkg_grep "	pkgrel")"

            if _repo_contains $pkgname $pkgver $pkgrel ; then
                printf "${GREEN}$dir is up to date.${NC}\n"
            else
                printf "${LIGHTBLUE}$dir is *not* up to date.${NC}\n"
                _make_package $dir
            fi
        else
            printf "${RED}'$dir' is not a valid package directory.${NC}\n" >&2
            exit 1
        fi
    fi
done

