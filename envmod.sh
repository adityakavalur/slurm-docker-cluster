#!/bin/bash
set -e

#Install TCL
docker exec slurmctld bash -c \
	' \
	export Prefix=/data/tcl/8.6.10 && \
	wget https://prdownloads.sourceforge.net/tcl/tcl8.6.10-src.tar.gz -P /data/ && \
	tar -xzf /data/tcl8.6.10-src.tar.gz -C /data/ && \
	rm -rf /data/tcl8.6.10-src.tar.gz && \
	cd /data/tcl8.6.10/unix && \
	./configure --prefix=$Prefix && \
	make && \
	make install && \
	cd $Prefix/../ && \
	ln -s 8.6.10 tcl && \
	rm -rf /data/tcl8.6.10 \
	'

#Install environment module
docker exec slurmctld bash -c \
	' \
	git clone --depth 1 --branch v4.6.0 https://github.com/cea-hpc/modules.git && \
	cd modules && \
	export Prefix=/data/envmod/4.6.0 && \
	export Modulefiles=/data/modulefiles && \
	./configure --prefix=$Prefix --modulefilesdir=$Modulefiles && \
	make && \
	make install && \
	cd $Prefix/../ && \
	ln -s 4.6.0 envmod && \
	rm -rf /data/modules && \
	cd /etc/profile.d/ && \
	ln -s $Prefix/init/profile.sh modules.sh && \
	ln -s $Prefix/init/profile.csh modules.csh \
	'
#Add the links to /usr/local of all compute nodes so that you don't have to export PATH for it in all modulefiles
for i in $(seq 1 $ncompute); do \
	docker exec compute$i bash -c \
		" \
		export Prefix=/data/envmod/4.6.0 && \
		cd /etc/profile.d/ && \
		ln -s $Prefix/init/profile.sh modules.sh && \
		ln -s $Prefix/init/profile.csh modules.csh \
		";
done

