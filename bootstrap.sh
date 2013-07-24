#!/usr/bin/env bash
 
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get install -q -y build-essential libxml2-dev libxslt1-dev ruby1.9.1 ruby1.9.1-dev rubygems1.9.1 
gem1.9.1 install bundler nokogiri
rm -rf /var/www
ln -fs /vagrant /var/www

