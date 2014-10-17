#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

# Date
# https://help.ubuntu.com/community/UbuntuTime
TIMEZONE=$(head -n 1 "/etc/timezone")
if [ $TIMEZONE != "Europe/Oslo" ]; then
    echo "Europe/Oslo" | sudo tee /etc/timezone
    sudo dpkg-reconfigure --frontend noninteractive tzdata
fi

if [ ! -d "/opt/provisioned" ]; then
  mkdir /opt/provisioned
  apt-get -qq update

  # Install all kinds of useful stuff
  echo 'mysql-server-5.1 mysql-server/root_password password vagrant' | debconf-set-selections
  echo 'mysql-server-5.1 mysql-server/root_password_again password vagrant' | debconf-set-selections
  apt-get -qq -y install build-essential git curl vim apache2 php5 libapache2-mod-php5 mysql-server php-pear php5-gd php5-mysql libpcre3-dev php5-dev
  printf "\n" | pecl install apc
  mkdir /var/log/xdebug
  chown www-data:www-data /var/log/xdebug

  # Install xdebug
  printf "\n" | pecl install xdebug

  echo '' >> /etc/php5/apache2/php.ini
  echo ';;;;;;;;;;;;;;;;;;;;;;;;;;' >> /etc/php5/apache2/php.ini
  echo '; Added to enable Xdebug ;' >> /etc/php5/apache2/php.ini
  echo ';;;;;;;;;;;;;;;;;;;;;;;;;;' >> /etc/php5/apache2/php.ini
  echo '' >> /etc/php5/apache2/php.ini
  echo 'zend_extension="'$(find / -name 'xdebug.so' 2> /dev/null)'"' >> /etc/php5/apache2/php.ini
  echo 'xdebug.remote_enable = 1' >> /etc/php5/apache2/php.ini
  echo 'xdebug.remote_connect_back = 1' >> /etc/php5/apache2/php.ini
  echo 'xdebug.idekey = "vagrant"' >> /etc/php5/apache2/php.ini
  echo 'xdebug.remote_log="/var/log/xdebug/xdebug.log"' >> /etc/php5/apache2/php.ini

  echo '' >> /etc/php5/cli/php.ini
  echo ';;;;;;;;;;;;;;;;;;;;;;;;;;' >> /etc/php5/cli/php.ini
  echo '; Added to enable Xdebug ;' >> /etc/php5/cli/php.ini
  echo ';;;;;;;;;;;;;;;;;;;;;;;;;;' >> /etc/php5/cli/php.ini
  echo '' >> /etc/php5/cli/php.ini
  echo 'zend_extension="'$(find / -name 'xdebug.so' 2> /dev/null)'"' >> /etc/php5/cli/php.ini
  echo 'xdebug.remote_enable = 1' >> /etc/php5/cli/php.ini
  echo 'xdebug.remote_connect_back = 1' >> /etc/php5/cli/php.ini
  echo 'xdebug.idekey = "vagrant"' >> /etc/php5/cli/php.ini
  echo 'xdebug.remote_log="/var/log/xdebug/xdebug.log"' >> /etc/php5/cli/php.ini

  a2enmod rewrite
  cp /vagrant/apache/drupal.conf /etc/apache2/sites-available/
  a2ensite drupal
  a2dissite 000-default
  usermod -a -G vagrant www-data
  /etc/init.d/apache2 restart

  # Use wget to install composer, to avoid SlowTimer errors
  wget -q "https://getcomposer.org/composer.phar"
  mv composer.phar /usr/local/bin/composer

  # Do some preperation, pretending we are the vagrant user.
  HOME=/home/vagrant
  sed -i '1i export PATH="$HOME/.composer/vendor/bin:$PATH"' $HOME/.bashrc
  chmod uog+x /usr/local/bin/composer

  # Download drush
  /usr/local/bin/composer global require drush/drush:dev-master
  chown vagrant /home/vagrant/.composer* -R

  # Install drupal
  cd /drupal
  $HOME/.composer/vendor/bin/drush si --db-url=mysql://drupal:drupal@localhost/drupal --db-su=root --db-su-pw=vagrant
fi
