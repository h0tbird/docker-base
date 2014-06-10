#------------------------------------------------------------------------------
# BUILD: docker build --rm -t fedora-base .
# RUN:   docker run --privileged -d -P -v /sys/fs/cgroup:/sys/fs/cgroup:ro fedora-base
#------------------------------------------------------------------------------

FROM fedora:latest
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Setup environment variables:
#------------------------------------------------------------------------------

ENV container docker

#------------------------------------------------------------------------------
# Update the system and install git and puppet:
#------------------------------------------------------------------------------

RUN yum update -y && \
    yum install -y http://yum.puppetlabs.com/puppetlabs-release-fedora-20.noarch.rpm && \
    yum install -y git puppet rubygem-deep-merge && \
    yum clean all

#------------------------------------------------------------------------------
# Setup systemd:
#------------------------------------------------------------------------------

RUN (cd /lib/systemd/system/sysinit.target.wants && \
    for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*

#------------------------------------------------------------------------------
# Install librarian puppet to manage isolated project dependencies:
#------------------------------------------------------------------------------

RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc && \
    gem install librarian-puppet

#------------------------------------------------------------------------------
# Setup puppet:
#------------------------------------------------------------------------------

RUN rm -rf /etc/puppet && \
    git clone https://github.com/h0tbird/puppet.git /etc/puppet && \
    rm -rf /etc/puppet/environments/production/*

ADD puppet /etc/puppet

#------------------------------------------------------------------------------
# Get the isolated puppet modules and apply the manifest:
#------------------------------------------------------------------------------

RUN cd /etc/puppet && \
    librarian-puppet install && \
    puppet apply /etc/puppet/environments/production/manifests/site.pp

#------------------------------------------------------------------------------
# Require the /sys/fs/cgroup volume mounted and execute the init command:
#------------------------------------------------------------------------------

EXPOSE 22
VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/sbin/init"]
