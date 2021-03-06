#!/bin/bash

diff_file ()
{
    if [ -e /usr/bin/md5sum ]
    then
        file1=($(md5sum $1))
        file2=($(md5sum $2))
        if [ "$file1" = "$file2" ]
        then
            return 0
        else
            return 1
        fi
    else
        echo -e "Please install md5..."
        return 1
    fi

}

backup ()
{
    if [ -e $1.bak ] || [ -d $1.bak ]
    then
        $2 rm -rf $1.bak
    fi

    if [ -e $1 ] || [ -d $1 ]
    then
        $2 mv $1 $1.bak
        echo -e "$1 already exists moved to $1.bak"
    fi
}

install_file ()
{
    if [ "$FORCE" == "YES" ]
    then
        backup $2 $3
    fi

    if [ -f $2 ]
    then
        diff_file $1 $2
        if [ $? -ne 0 ]
        then
            backup $2 $3
            $3 cp $1 $2
            echo -e "$2 updated\r\n"
        else
            echo -e "$2 up to date\r\n"
        fi
    else
        $3 cp $1 $2
        echo -e "$2 installed\r\n"
    fi
}

EXEC_PATH=$(cd "$( dirname "$0")" && pwd)

# gitconfig
install_file $EXEC_PATH/.gitconfig $HOME/.gitconfig

# bashrc
install_file $EXEC_PATH/.bashrc $HOME/.bashrc

