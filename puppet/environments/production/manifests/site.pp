#------------------------------------------------------------------------------
# Stages:
#------------------------------------------------------------------------------

stage { 'pre':  before  => Stage['main'] }
stage { 'post': require => Stage['main'] }

#------------------------------------------------------------------------------
# Enable the Puppet 4 behavior today:
#------------------------------------------------------------------------------

Package { allow_virtual => true }

#------------------------------------------------------------------------------
# Include:
#------------------------------------------------------------------------------

include "::r_base::${::virtual}"
