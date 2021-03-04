#!/bin/bash
set -e

#Create a scratch directory
docker cp create_scratch.sh slurmctld:/
docker exec slurmctld bash -c "/usr/bin/bash create_scratch.sh"

#Copy the XALT2 configuration script into the 'login' node and set root as owner
docker cp XALT2/mycluster_xalt2_config.py slurmctld:/data
docker cp relocate_xaltjson.py slurmctld:/data

docker cp XALT2/2.9.8.tcl slurmctld:/data
docker exec slurmctld bash -c "/usr/bin/chown root:root /data/mycluster_xalt2_config.py"
docker exec slurmctld bash -c "/usr/bin/chown root:root /data/relocate_xaltjson.py"
docker exec slurmctld bash -c "/usr/bin/chown root:root /data/2.9.8.tcl"
docker exec slurmctld bash -c "mkdir /data/xalt2_json_moved && chmod o+w /data/xalt2_json_moved"

#Install XALT2
docker exec slurmctld bash -c \
	' \
        export xalt2_dir=/data/xalt2 && \
        export xalt2_output=/data/xalt2_json && \  
	export XALT_SAMPLING=yes && \
	export XALT_SCALAR_AND_SPSR_SAMPLING=yes && \
	cd /data && \
	git clone --depth 1 --branch xalt-2.9.8 https://github.com/xalt/xalt.git && \
	cd /data/xalt && \
	./configure --prefix=$xalt2_dir --with-syshostConfig=hardcode:mycluster --with-transmission=file --with-config=/data/mycluster_xalt2_config.py --with-systemPath=/usr/bin:/bin:/usr/local/bin --with-xaltFilePrefix=$xalt2_output --with-trackScalarPrgms=yes && \
	make install && \
	mkdir $xalt2_output && \
        chmod o+w $xalt2_output && \
	rm -rf /data/xalt && \
        echo 'installation complete' \
        '

docker cp XALT2/conf_create_mod.py slurmctld:/data/xalt2/xalt/xalt/sbin/
docker cp XALT2/db_credentials.txt slurmctld:/data/
docker cp XALT2/xalt_file_to_db_mod.py slurmctld:/data/xalt2/xalt/xalt/sbin/
docker cp XALT2/move_json_to_sql.sh slurmctld:/data/
docker exec slurmctld bash -c \
        " \
        cd /data/xalt2/xalt/xalt/sbin && \
        python conf_create_mod.py \
        "

#Everything below this fails, need to run manually.
docker exec slurmctld bash -c \
        " \
        source /etc/profile && \
        cd /data/xalt2/xalt/xalt/sbin && \
        python3 createDB.py --confFn xalt_mycluster_db.conf \        
        "

docker exec slurmctld bash -c \
        ' \
        source /etc/profile && \
        bash /data/module_check.sh && \
        module_check=$(cat /tmp/module_check) && \
        if [ $module_check -eq 102 ]; then mkdir /data/modulefiles/xalt2 && cp /data/2.9.8.tcl /data/modulefiles/xalt2/; fi 
	'
