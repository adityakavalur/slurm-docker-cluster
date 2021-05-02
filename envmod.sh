#!/bin/bash
set -e

#Copy the module check script
docker cp module_check.sh slurmctld:/data
docker exec slurmctld bash -c "chmod 777 /data/module_check.sh"

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
	ln -sfn 8.6.10 tcl && \
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
	ln -sfn 4.6.0 envmod && \
	rm -rf /data/modules && \
	cd /etc/profile.d/ && \
	ln -sfn $Prefix/init/profile.sh modules.sh && \
	ln -sfn $Prefix/init/profile.csh modules.csh && \
	chmod 777 /data/modulefiles \
        '
#Add the links to /usr/local of all compute nodes so that you don't have to export PATH for it in all modulefiles
#Check number of compute nodes and exit if none found
ncompute=$(docker ps | awk '{print $NF}' | tail -n+2 | grep -ir 'compute' | wc -l)
if [[ $ncompute == 0 ]]; then
        echo "No compute nodes found"
        exit 1
fi

for i in $(seq 1 $ncompute); do \
	docker exec compute$i bash -c \
		' \
		export Prefix=/data/envmod/4.6.0 && \
		cd /etc/profile.d/ && \
		ln -sfn $Prefix/init/profile.sh modules.sh && \
		ln -sfn $Prefix/init/profile.csh modules.csh \
		';
done

