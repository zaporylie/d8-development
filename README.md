Drupal 8 development
===============

Use this repo to create your own Drupal Development Environmet.

# Instalation

- go to /drupal and clone drupal repo inside (into "drupal" folder, instructions in separate README file)
- go to /vagrant and build your vagrant provision with vagrant up

# Next steps:

- login to vagrant with 
    vagrant ssh
- go to /drupal to work on drupal folder
- use 
    drush <command>
- your site is available under localhost:8888 
- enjoy!

# Data

- ssh port - 2888
- drupal database - drupal:drupal@localhost/drupal

# PhpStorm
Open project based on top level of this repo to have access to php remote interpreter, xdebug and and similar already configured.
