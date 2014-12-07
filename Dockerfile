#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------

FROM h0tbird/centos
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Setup environment variables:
#------------------------------------------------------------------------------

ENV container docker
ENV FACTER_is_virtual true
ENV FACTER_virtual docker

#------------------------------------------------------------------------------
# Update the system and install git, puppet and rubygems:
#------------------------------------------------------------------------------

RUN yum update -y && rpm --import \
    http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs \
    http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 && \
    yum install -y http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm \
    http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm && \
    yum install -y git wget puppet rubygems rubygem-deep-merge && \
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
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    rm -f /etc/systemd/system/default.target; \
    ln -s /usr/lib/systemd/system/multi-user.target /etc/systemd/system/default.target

#------------------------------------------------------------------------------
# Install r10k to manage isolated project dependencies:
#------------------------------------------------------------------------------

RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc && gem install r10k

#------------------------------------------------------------------------------
# Setup puppet:
#------------------------------------------------------------------------------

RUN rm -rf /etc/puppet && \
    git clone https://github.com/h0tbird/puppet.git /etc/puppet

ADD puppet /etc/puppet

#------------------------------------------------------------------------------
# Get the isolated puppet modules and apply the manifest:
#------------------------------------------------------------------------------

RUN cd /etc/puppet/environments/production && \
    r10k puppetfile install && \
    FACTER_docker_build=true \
    FACTER_fqdn=base00.demo.lan \
    puppet apply /etc/puppet/environments/production/manifests/site.pp

#------------------------------------------------------------------------------
# Expose ports and set systemd as default process:
#------------------------------------------------------------------------------

CMD ["/usr/sbin/init"]
