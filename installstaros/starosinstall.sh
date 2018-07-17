#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi
source ./version.sh
help()
{
echo ===============================================================================
echo StarOS installer usage:
echo ===============================================================================
echo "./staros-install.sh [type]"
echo "[type]:"
echo "          install    		: Install StarOS Platform" 
echo "          uninstall       : Uninstall StarOS Platform"
echo ===============================================================================
}

if [ "$1" == "help" ] || [ "$1" == "" ]
then
	help
	exit 1
fi

function install_ld() {
	echo "/opt/staros.xyz/stardlls/libs"> /etc/ld.so.conf.d/stardlls-x86_64.conf
	echo "/opt/staros.xyz/stardlls/python/lib/"> /etc/ld.so.conf.d/stardllspython-x86_64.conf
	echo "/opt/staros.xyz/protocol/libs"> /etc/ld.so.conf.d/staros_protocol-x86_64.conf
	echo "/opt/staros.xyz/dipc/libs"> /etc/ld.so.conf.d/dipc-x86_64.conf
	cp -rf /opt/staros.xyz/dipc/bin/dipcctl /usr/local/bin
	cp -rf /opt/staros.xyz/staros/bin/staros /usr/local/bin
	chmod a+x /usr/local/bin/dipcctl
	chmod a+x /usr/local/bin/staros
	echo "/opt/staros.xyz/starcore/libs"> /etc/ld.so.conf.d/starcore-x86_64.conf
	echo "/opt/staros.xyz/staros/libs"> /etc/ld.so.conf.d/staros-x86_64.conf
	ldconfig
}

function uninstall_ld() {
	rm -rf /etc/ld.so.conf.d/stardlls-x86_64.conf
	rm -rf /etc/ld.so.conf.d/stardllspython-x86_64.conf
	rm -rf /etc/ld.so.conf.d/staros_protocol-x86_64.conf
	rm -rf /etc/ld.so.conf.d/dipc-x86_64.conf
	rm -rf /usr/local/bin/dipcctl
	rm -rf /usr/local/bin/staros
	rm -rf /etc/ld.so.conf.d/starcore-x86_64.conf
	ldconfig
}

function install_package() {
	#if the staros.xyz dir is not exist,create it
	if [ -d /opt/staros.xyz ];then
		echo /opt/staros.xyz check!
	else
		mkdir -p /opt/staros.xyz
	fi
	#check system version
	if [ -d /opt/staros.xyz/stardlls ];then
		echo Stardlls check!
	else
		if [ -f ../package/$CPUTYPE/stardlls_release-$STARDLLS_VERSION.$CPUTYPE.tar.bz2 ];then
			echo install stardlls ...
			tar jxf ../package/$CPUTYPE/stardlls_release-$STARDLLS_VERSION.$CPUTYPE.tar.bz2
			mv stardlls_release-$STARDLLS_VERSION.$CPUTYPE /opt/staros.xyz/stardlls
			mkdir -p /opt/staros.xyz/stardlls/logs
		fi
	fi
	
	#check protocol
	if [ -d /opt/staros.xyz/protocol ];then
		echo protocol check!
	else
		if [ -f ../package/$CPUTYPE/protocol_release-$PROTOCOL_VERSION.$CPUTYPE.tar.bz2 ];then
			echo install protocol ...
			tar jxf ../package/$CPUTYPE/protocol_release-$PROTOCOL_VERSION.$CPUTYPE.tar.bz2
			mv protocol_release-$PROTOCOL_VERSION.$CPUTYPE /opt/staros.xyz/protocol
		fi
	fi
	

	#check dipc
	if [ -d /opt/staros.xyz/dipc ];then
		echo DIPC check!
	else
		if [ -f ../package/$CPUTYPE/dipc_release-$DIPC_VERSION.$CPUTYPE.tar.bz2 ];then
			echo install dipc ...
			tar jxf ../package/$CPUTYPE/dipc_release-$DIPC_VERSION.$CPUTYPE.tar.bz2
			mv dipc_release-$DIPC_VERSION.$CPUTYPE /opt/staros.xyz/dipc
		fi
	fi
	
	#check starcore
	if [ -d /opt/staros.xyz/starcore ];then
		echo StarCore check!
	else
		if [ -f ../package/$CPUTYPE/starcore_release-$STARCORE_VERSION.$CPUTYPE.tar.bz2 ];then
			echo install starcore ...
			tar jxf ../package/$CPUTYPE/starcore_release-$STARCORE_VERSION.$CPUTYPE.tar.bz2
			mv starcore_release-$STARCORE_VERSION.$CPUTYPE /opt/staros.xyz/starcore
		fi
	fi
	
	#check staros
	if [ -d /opt/staros.xyz/staros ];then
		echo StarOS check!
	else
		if [ -f ../package/$CPUTYPE/staros_release-$STAROS_VERSION.$CPUTYPE.tar.bz2 ];then
			echo install staros ...
			tar jxf ../package/$CPUTYPE/staros_release-$STAROS_VERSION.$CPUTYPE.tar.bz2
			mv staros /opt/staros.xyz/staros
		fi
	fi
	
	rm -rf /opt/staros.xyz/dipc/scripts/startup.xml
	cp /opt/staros.xyz/staros/scripts/startup.xml /opt/staros.xyz/dipc/scripts/
	
	
	echo Install END ...
}

function uninstall_package() {
	echo uninstall platform will cause application not avaliable, are you sure want uninstall platform?
	read -s -n1 -p "Press any key to continue ..."
	rm -rf /opt/staros.xyz/*
	
	echo UnInstall END ...
}

if [ "$1" == "install" ]
then
	install_package
	install_ld
elif [ "$1" == "uninstall" ]
then
	uninstall_package
	uninstall_ld
else
	help
	exit 1
fi
