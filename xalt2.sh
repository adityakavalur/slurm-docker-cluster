#!/bin/bash
set -e

#Copy the XALT2 configuration script into the 'login' node and set root as owner
docker cp XALT2/mycluster_xalt2_config.py slurmctld:/data
docker cp XALT2/2.9.8.tcl slurmctld:/data
docker exec slurmctld bash -c "/usr/bin/chown root:root /data/mycluster_xalt2_config.py"
docker exec slurmctld bash -c "/usr/bin/chown root:root /data/2.9.8.tcl"

#Install XALT2
docker exec slurmctld bash -c \
	' \
        export xalt2_dir=/data/xalt2 && \
        export xalt2_output=/data/xalt2_json && \  
	cd /data && \
	git clone --depth 1 --branch xalt-2.9.8 https://github.com/xalt/xalt.git && \
	cd /data/xalt && \
	./configure --prefix=$xalt2_dir --with-syshostConfig=hardcode:mycluster --with-transmission=file --with-config=/data/mycluster_xalt2_config.py --with-systemPath=/usr/bin:/bin:/usr/local/bin --with-xaltFilePrefix=$xalt2_output --with-trackScalarPrgms=no && \
	make install && \
	mkdir $xalt2_output
        chmod o+w $xalt2_output 
	rm -rf /data/xalt
	'
