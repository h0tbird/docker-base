#------------------------------------------------------------------------------
# docker build -rm -t registry.demo.lan:5000/base .
#------------------------------------------------------------------------------

FROM registry.demo.lan:5000/centos
MAINTAINER Marc Villacorta Morera <marc.villacorta@gmail.com>

#------------------------------------------------------------------------------
# Ready, set ...
#------------------------------------------------------------------------------

RUN yum update -y && \
    yum install -y http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm && \
    yum install -y git puppet rubygem-deep-merge

RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc && \
    gem install librarian-puppet

#------------------------------------------------------------------------------
# .. go!
#------------------------------------------------------------------------------

RUN rm -rf /etc/puppet && \
    git clone https://github.com/h0tbird/puppet.git /etc/puppet && \
    rm -rf /etc/puppet/modules /etc/puppet/roles

ADD Puppetfile /etc/puppet/Puppetfile
ADD site.pp /etc/puppet/manifests/site.pp

RUN cd /etc/puppet && \
    librarian-puppet install && \
    puppet apply /etc/puppet/manifests/site.pp
