#!/bin/bash
## EXPORT environment variables for concourse ##
export CONCOURSE_ADD_LOCAL_USER=xiguazhi:hello123
export CONCOURSE_MAIN_TEAM_LOCAL_USER=xiguazhi
export CONCOURSE_SESSION_SIGNING_KEY=path/to/session_signing_key
export CONCOURSE_TSA_HOST_KEY=path/to/tsa_host_key
export CONCOURSE_TSA_AUTHORIZED_KEYS=path/to/authorized_worker_keys
export CONCOURSE_POSTGRES_HOST=127.0.0.1 # default
export CONCOURSE_POSTGRES_PORT=5432      # default
export CONCOURSE_POSTGRES_DATABASE=atc   # default
export CONCOURSE_POSTGRES_USER=concourse
export CONCOURSE_POSTGRES_PASSWORD=hello123
export CONCOURSE_POSTGRES_SOCKET=/var/run/postgresql
export CONCOURSE_EXTERNAL_URL=https://concourse.bs-autocount.com/
export CONCOUSRE_X_FRAME_OPTIONS=sameorigin
export CONCOURSE_CLUSTER_NAME=ansible_poc
export CONCOURSE_TLS_BIND_PORT=443
export COURSE_ENABLE_LETS_ENCRYPT
# Enable auditing for all api requests connected to builds.
export CONCOURSE_ENABLE_BUILD_AUDITING=true
# Enable auditing for all api requests connected to containers.
export CONCOURSE_ENABLE_CONTAINER_AUDITING=true
# Enable auditing for all api requests connected to jobs.
export CONCOURSE_ENABLE_JOB_AUDITING=true
# Enable auditing for all api requests connected to pipelines.
export CONCOURSE_ENABLE_PIPELINE_AUDITING=true
# Enable auditing for all api requests connected to resources.
export CONCOURSE_ENABLE_RESOURCE_AUDITING=true
# Enable auditing for all api requests connected to system transactions.
export CONCOURSE_ENABLE_SYSTEM_AUDITING=true
# Enable auditing for all api requests connected to teams.
export CONCOURSE_ENABLE_TEAM_AUDITING=true
# Enable auditing for all api requests connected to workers.
export CONCOURSE_ENABLE_WORKER_AUDITING=true
# Enable auditing for all api requests connected to volumes.
export CONCOURSE_ENABLE_VOLUME_AUDITING=true
# install pre-reqs
sudo yum install -y openssl-devel readline-devel zlib-devel bzip2 gcc make git
# Clone git repos and setup path
sudo git clone git://github.com/rbenv/rbenv.git /usr/local/rbenv
sudo mkdir /usr/local/rbenv/plugins
sudo git clone git://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build
sudo tee /etc/profile.d/rbenv.sh <<< 'export PATH="/usr/local/rbenv/plugins/ruby-build/bin:/usr/local/rbenv/bin:$PATH"'
sudo tee -a /etc/profile.d/rbenv.sh <<< 'source <(rbenv init -)'
#restart bash
bash
rbenv install 2.7.1
rbenv global 2.7.1
# Install bundler gem
gem install bundler
bundle install

#kitchen init
# Download ConcourseCI
echo "Downloading Concourse"
curl -Lk https://github.com/concourse/concourse/releases/download/v6.3.1/concourse-6.3.1-linux-amd64.tgz -o /vagrant/concourse-6.3.1-linux-amd64.tgz
curl -Lk https://github.com/concourse/concourse/releases/download/v6.3.1/fly-6.3.1-linux-amd64.tgz -o /vagrant/fly-6.3.1-linux-amd64.tgz
sudo cp /vagrant/files/etc/yum.repos.d/CentOS-base.repo /etc/yum.repos.d/CentOS-Base.repo
# Install a Repository configuration package using the official PostgreSQL repo for CentOS:
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum install -y postgresql11-server 
# Create a new PostgreSQL database cluster with initdb:
sudo /usr/pgsql-11/bin/postgresql-11-setup initdb
# start and enable PostgreSQL using systemctl:
sudo systemctl start postgresql-11
sudo systemctl enable postgresql-11
# Create concourse user
sudo -u postgres createuser concourse
# Create postgresql ATC database
sudo -u postgres createdb --owner=concourse atc
# Extract concourse
sudo tar -zxf /vagrant/concourse-*.tgz -C /usr/local
# Extract fly
sudo tar -zxf /vagrant/fly-*.tgz -C /usr/local
# Create concourse Generate-Key
sudo mkdir -p /vagrant/concourse_keys/
sudo concourse generate-key -t rsa -f /vagrant/concourse_keys/session_signing_key
sudo concourse generate-key -t ssh -f /vagrant/concourse_keys/tsa_host_key
sudo concourse generate-key -t ssh -f /vagrant/concourse_keys/worker_key
# Set path for concourse
export PATH="/usr/local/concourse/bin:$PATH"
export PATH="/usr/local/fly/bin:$PATH"
# Start concourse web
concourse web
