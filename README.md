## Tennis Courts Harvester

This will download a cvs list of all tennis courts from tennis Australia.
I want to be able to find a tennis court when travelling around Australia and access to the internet is limited.

I might add more countries in the future.

### Requirements

* ruby 1.9.3
* nokogiri

### Before you start

Go to the Australia Post website and register to download the australian postcode data file.

<https://auspost.com.au/forms/postcode-data-registration.html>

Australia Post will send an email with two links in it.
Pick the postcode book extract.

Unzip the downloaded file and place it in some directory.
The file name will be something like:

pc-book_20130703.csv


### Usage
    ruby harvest_courts.rb -f <pc-book-file.csv> -o output.csv
    
### Vagrant

Running the script on a virtual machine powered by Vagrant. 

  * Download virtual box - <http://www.virtualbox.org/>
  * Download vagrant - <http://downloads.vagrantup.com/>
  
  ````
git clone git@github.com:eggplantbr/tennis-courts-harvester.git
cd tennis-courts-harvester
vagrant box add precise64 http://files.vagrantup.com/precise64.box
vagrant up
vagrant ssh
cd /vagrant
ruby harvest_courts.rb -f <pc-book-file.csv> -o output.csv
exit
vagrant halt
  ````
  