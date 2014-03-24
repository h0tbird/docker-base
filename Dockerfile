#------------------------------------------------------------------------------
# docker build -rm -t registry.demo.lan:5000/base .
#------------------------------------------------------------------------------

FROM registry.demo.lan:5000/centos
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Update the system and install git and puppet:
#------------------------------------------------------------------------------

RUN yum update -y && \
    yum install -y http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm && \
    yum install -y git puppet rubygem-deep-merge

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
    rm -rf /etc/puppet/modules /etc/puppet/roles

ADD puppet /etc/puppet

#------------------------------------------------------------------------------
# Get the isolated puppet modules and apply the manifest:
#------------------------------------------------------------------------------

RUN cd /etc/puppet && \
    librarian-puppet install && \
    puppet apply /etc/puppet/manifests/site.pp
