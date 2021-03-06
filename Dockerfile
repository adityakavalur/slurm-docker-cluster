FROM centos:7

LABEL org.opencontainers.image.source="https://github.com/giovtorres/slurm-docker-cluster" \
      org.opencontainers.image.title="slurm-docker-cluster" \
      org.opencontainers.image.description="Slurm Docker cluster on CentOS 7" \
      org.label-schema.docker.cmd="docker-compose up -d" \
      maintainer="Giovanni Torres"

ARG SLURM_TAG=slurm-20-02-4-1
ARG GOSU_VERSION=1.11

RUN set -ex \
    && yum makecache fast \
    && yum -y update \
    && yum -y install epel-release \
    && yum -y install \
       wget \
       bzip2 \
       perl \
       gcc \
       gcc-c++\
       gcc-gfortran \
       git \
       gnupg \
       make \
       munge \
       munge-devel \
       python-devel \
       python-pip \
       python3 \
       python3-devel \
       python3-pip \
       mariadb-server \
       mariadb-devel \
       psmisc \
       bash-completion \
       vim-enhanced \
       patch \
    && yum clean all \
    && rm -rf /var/cache/yum


#Xalt2 dependencies (Optional)
RUN \
    pip3 install mysqlclient && \
    yum -y install mysql-devel uuid-devel libuuid-devel curl-devel \
		   elfutils-libelf-devel bc && \
    yum -y group install "Development Tools"


#MPICH (optional)
RUN \
    yum -y install mpich-3.2-devel && \
    ln -s /usr/lib64/mpich-3.2/bin/* /usr/bin/ && \
    pip install --global-option=build_ext --global-option="-I/usr/include/mpich-3.2-x86_64/" --global-option="-L/usr/lib64/mpich-3.2/lib/" --global-option="-L/usr/lib/mpich-3.2/lib/" mpi4py
#Python package above is optional 

#Lmod/Tcl dependencies (Optional)
RUN \
    yum -y install tcl-8.5.13-8.el7.x86_64  \
                   tcl-devel-8.5.13-8.el7.x86_64 \
                   lua-posix \
		   dejagnu man-db sphinx-build dh-autoreconf
		   
# Add `jq` json query, for parsing XALT-json output
RUN \
    yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install jq

RUN  \
       useradd user_xalt \
    && useradd user1 \
    && useradd user2 
    
RUN pip install Cython nose && pip3 install Cython nose

RUN set -ex \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

RUN set -x \
    && git clone https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && git checkout tags/$SLURM_TAG \
    && ./configure --enable-debug --prefix=/usr --sysconfdir=/etc/slurm \
        --with-mysql_config=/usr/bin  --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && popd \
    && rm -rf slurm \
    && groupadd -r --gid=995 slurm \
    && useradd -r -g slurm --uid=995 slurm \
    && mkdir /etc/sysconfig/slurm \
        /var/spool/slurmd \
        /var/run/slurmd \
        /var/run/slurmdbd \
        /var/lib/slurmd \
        /var/log/slurm \
        /data \
    && touch /var/lib/slurmd/node_state \
        /var/lib/slurmd/front_end_state \
        /var/lib/slurmd/job_state \
        /var/lib/slurmd/resv_state \
        /var/lib/slurmd/trigger_state \
        /var/lib/slurmd/assoc_mgr_state \
        /var/lib/slurmd/assoc_usage \
        /var/lib/slurmd/qos_usage \
        /var/lib/slurmd/fed_mgr_state \
    && chown -R slurm:slurm /var/*/slurm* \
    && /sbin/create-munge-key

COPY slurm.conf /etc/slurm/slurm.conf
COPY slurmdbd.conf /etc/slurm/slurmdbd.conf

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["slurmdbd"]
