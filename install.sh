#!/bin/bash

echo "安装依赖（ rely ）"
if [ $USER == 'root' ]
then
    add=''
else
    add='sudo'
fi
if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ]
then
    $add apt-get install libstdc++6:i386 libgcc1:i386 libcurl4-gnutls-dev:i386
else
    $add apt-get install libstdc++6 libgcc1 libcurl4-gnutls-dev
fi

steamcmd_dir="$HOME/steamcmd"
install_dir="$HOME/dontstarvetogether_dedicated_server"
cluster_name="MyDediServer"
dontstarve_dir="$HOME/.klei/DoNotStarveTogether"
caves_start="$HOME/caves_start.sh"
master_start="$HOME/master_start.sh"

mkdir "$steamcmd_dir"
cd "$steamcmd_dir"
if [ ! -f steamcmd_linux.tar.gz ]
then
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xvzf steamcmd_linux.tar.gz
fi
mkdir -p $dontstarve_dir/$cluster_name/Master
mkdir -p $dontstarve_dir/$cluster_name/Caves

function del_file()
{
    if [ -e "$1" ]; then
        rm "$1"
    fi
}

echo "请输入安装模式（ install mode 1 / 2 / 3 ）"
echo "1、将主服务器和地穴都安装到此（mster and caves）"
echo "2、安装主服务器（master）"
echo "3、安装地穴服务器(caves)"
read mode_s

bind_ip='127.0.0.1'
master_ip='127.0.0.1'

echo "请输入你的token( Server Token )："
read token
cat > $dontstarve_dir/$cluster_name/cluster_token.txt <<EOF
$token
EOF
echo "请输入服务器名( Server Name )："
read ser_name
echo "请输入服务器描述( Server Description )："
read ser_desc
echo "请输入服务器密码( Server Password )："
read ser_passwd
echo '请输入需要的 modid（ 各id间使用,分隔 eg. 374550642,378160973,375850593,458587300,375859599 ） :'
read modid_list
case $mode_s in
    1 )
        cat > $master_start <<EOF
#!/bin/bash
cd $install_dir/bin
./dontstarve_dedicated_server_nullrenderer -console -cluster "$cluster_name" -shard Master
EOF
        chmod +x $master_start
        cat > $dontstarve_dir/$cluster_name/Master/server.ini <<EOF
[NETWORK]
server_port = 11000

[SHARD]
is_master = true

[STEAM]
master_server_port = 27018
authentication_port = 8768
EOF
        cat > $caves_start <<EOF
#!/bin/bash
cd $install_dir/bin
./dontstarve_dedicated_server_nullrenderer -console -cluster "$cluster_name" -shard Caves
EOF
        chmod +x $caves_start
        cat > $dontstarve_dir/$cluster_name/Caves/server.ini <<EOF
[NETWORK]
server_port = 11001

[SHARD]
is_master = false
name = Caves

[STEAM]
master_server_port = 27019
authentication_port = 8769
EOF
        cat > $dontstarve_dir/$cluster_name/Caves/worldgenoverride.lua <<EOF
return {
    override_enabled = true,
    preset = "DST_CAVE",
}
EOF
        ;;
    2 ) 
        cat > $master_start <<EOF
#!/bin/bash
cd $install_dir/bin
./dontstarve_dedicated_server_nullrenderer -console -cluster "$cluster_name" -shard Master
EOF
        chmod +x $master_start
        bind_ip='0.0.0.0'
        cat > $dontstarve_dir/$cluster_name/Master/server.ini <<EOF
[NETWORK]
server_port = 11000

[SHARD]
is_master = true

[STEAM]
master_server_port = 27018
authentication_port = 8768
EOF
        ;;
    3 ) 
        cat > $caves_start <<EOF
#!/bin/bash
cd $install_dir/bin
./dontstarve_dedicated_server_nullrenderer -console -cluster "$cluster_name" -shard Caves
EOF
        chmod +x $caves_start
        echo '请输入服务器ip（server ip）'
        read master_ip
        cat > $dontstarve_dir/$cluster_name/Caves/server.ini <<EOF
[NETWORK]
server_port = 11001

[SHARD]
is_master = false
name = Caves

[STEAM]
master_server_port = 27019
authentication_port = 8769
EOF
        cat > $dontstarve_dir/$cluster_name/Caves/worldgenoverride.lua <<EOF
return {
    override_enabled = true,
    preset = "DST_CAVE",
}
EOF
        ;;
esac

cat > $dontstarve_dir/$cluster_name/cluster.ini <<EOF
[GAMEPLAY]
game_mode = survival
max_players = 6
pvp = false
pause_when_empty = true

[NETWORK]
cluster_description = $ser_name
cluster_name = $ser_desc
cluster_intention = cooperative
cluster_password = $ser_passwd

[MISC]
console_enabled = true

[SHARD]
shard_enabled = true
bind_ip = $bind_ip
master_ip = $master_ip
master_port = 10889
cluster_key = supersecretkey
EOF

function fail()
{
        echo Error: "$@" >&2
        exit 1
}

cd "$steamcmd_dir" || fail "Missing $steamcmd_dir directory!"

./steamcmd.sh +force_install_dir "$install_dir" +login anonymous +app_update 343050 validate +quit

# mod安装
del_file "$install_dir/mods/dedicated_server_mods_setup.lua"

case $mode_s in
    1 )
        echo ' return {' > $dontstarve_dir/$cluster_name/Master/modoverrides.lua
        echo ' return {' > $dontstarve_dir/$cluster_name/Caves/modoverrides.lua
        ;;
    2 )
        echo ' return {' > $dontstarve_dir/$cluster_name/Master/modoverrides.lua
        ;;
    3 )
        echo ' return {' > $dontstarve_dir/$cluster_name/Caves/modoverrides.lua
        ;;    
esac
if [[ $modid_list != '' ]]; then
    IFS=',' mod_list=($modid_list)
    for mod_id in ${mod_list[@]}; do
        echo "ServerModSetup(\"$mod_id\")" >> $install_dir/mods/dedicated_server_mods_setup.lua
        case $mode_s in
            1 )
                echo "[\"workshop-$mod_id\"] = { enabled = true }," >> $dontstarve_dir/$cluster_name/Master/modoverrides.lua
                echo "[\"workshop-$mod_id\"] = { enabled = true }," >> $dontstarve_dir/$cluster_name/Caves/modoverrides.lua
                ;;
            2 )
                echo "[\"workshop-$mod_id\"] = { enabled = true }," >> $dontstarve_dir/$cluster_name/Master/modoverrides.lua    
                ;;
            3 )
                echo "[\"workshop-$mod_id\"] = { enabled = true }," >> $dontstarve_dir/$cluster_name/Caves/modoverrides.lua
                ;;    
        esac      
    done
fi
case $mode_s in
    1 )
        echo ' }' >> $dontstarve_dir/$cluster_name/Master/modoverrides.lua  
        echo ' }' >> $dontstarve_dir/$cluster_name/Caves/modoverrides.lua
        echo ' 你已经成功在此电脑安装 主服务器与地穴服务器 '
        echo '  ------  开启主服务器可用  ------ '
        echo ' '
        echo " screen -S \"world\" $master_start "
        echo ' '
        echo '  ----------------------------- '
        echo '  ------ 开启地穴服务器可用 ------ '
        echo ' '
        echo " screen -S \"caves\" $caves_start "
        echo ' '
        echo '  ----------------------------- '
        echo 
        ;;
    2 )
        echo ' }' >> $dontstarve_dir/$cluster_name/Master/modoverrides.lua
        echo ' 你已经成功在此电脑安装 主服务器 '
        echo '  ------  开启主服务器可用  ------ '
        echo ' '
        echo " screen -S \"world\" $master_start "
        echo ' '
        echo '  ----------------------------- '   
        ;;
    3 )
        echo ' }' >> $dontstarve_dir/$cluster_name/Caves/modoverrides.lua
        echo ' 你已经成功在此电脑安装 地穴服务器 '
        echo '  ------ 开启地穴服务器可用 ------ '
        echo ' '
        echo " screen -S \"caves\" $caves_start "
        echo ' '
        echo '  ----------------------------- '
        ;;    
esac
