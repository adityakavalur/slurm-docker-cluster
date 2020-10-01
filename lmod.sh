#!/bin/bash
set -e

#Check number of compute nodes and exit if none found
ncompute=$(docker ps | awk '{print $11}' | tail -n+2 | grep -ir 'compute' | wc -l)
if [[ $ncompute == 0 ]]; then
	echo "No compute nodes found"
        exit 1
fi


#Install lua in the common /data
docker exec slurmctld bash -c \
	" \
	wget https://sourceforge.net/projects/lmod/files/lua-5.1.4.9.tar.bz2 -P /data/ && \
	tar -xf /data/lua-5.1.4.9.tar.bz2 -C /data/ && \
	rm -rf /data/lua-5.1.4.9.tar.bz2  && \
	cd /data/lua-5.1.4.9/  && \
	./configure --prefix=/data/lua/5.1.4.9  && \
	make  && \
	make install  && \
	cd /data/lua  && \
	ln -s 5.1.4.9 lua  && \
	rm -rf /data/lua-5.1.4.9/  && \
	cd /usr/local/bin  && \
	ln -s /data/lua/lua/bin/lua /usr/local/lua  && \
	cd /usr/include/  && \
	ln -s /data/lua/lua/include/ ./lua \
	"

#Add  the links to /usr/local of all compute nodes so that you don't have to export PATH for it in all modulefiles
for i in $(seq 1 $ncompute); do \
	docker exec compute$i bash -c \
		" \
		cd /usr/local/bin && \
		ln -s /data/lua/lua/bin/lua /usr/local/lua && \
		cd /usr/include/ && \
		ln -s /data/lua/lua/include/ ./lua \
		";
done



#Install lmod in the common /data
docker exec slurmctld bash -c \
	" \
	wget https://sourceforge.net/projects/lmod/files/Lmod-8.4.tar.bz2 -P /data/ && \
	tar -xf /data/Lmod-8.4.tar.bz2 -C /data/ && \
	rm -rf /data/Lmod-8.4.tar.bz2 && \
	cd /data/Lmod-8.4/ && \
	./configure --prefix=/data/ && \
	make install && \
	rm -rf /data/Lmod-8.4 && \
	mkdir /data/modulefiles && \
	echo '/data/modulefiles/' > /data/lmod/lmod/init/.modulespath && \
	ln -s /data/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh && \
	ln -s /data/lmod/lmod/init/cshrc /etc/profile.d/z00_lmod.csh \
	"

for i in $(seq 1 $ncompute); do \
	docker exec compute$i bash -c \
		" \
		echo '/data/modulefiles/' > /data/lmod/lmod/init/.modulespath && \
		ln -s /data/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh && \
		ln -s /data/lmod/lmod/init/cshrc /etc/profile.d/z00_lmod.csh \
		"
done