{% set source_url = 'http://www.observium.org/observium-community-latest.tar.gz' %}
{% set source_hash = 'md5=ec77e72d006a615550f18d6ef96791e6' %}
{% set base_path = '/opt/observium' %}

include:
  - apache
  - apache.vhosts.standard
  - repo.dotdeb
  - php
  - php.mysql
  - php.gd
  - php.snmp
  - php.pear
  - php.mcrypt
  - php.json
observium:
  pkg.installed:
    - pkgs:
      - snmp
      - graphviz
      - rrdtool
      - fping
      - imagemagick
      - whois
      - mtr-tiny
      - nmap
      - ipmitool
      - mysql-client
      - python-mysqldb

  archive:
    - extracted
    - name: /opt/
    - source: {{ source_url }}
    - source_hash: {{ source_hash }}
    - tar_options: xf
    - archive_format: tar
    - if_missing: {{ base_path }}

  # This is a "dumb" command run on every highstate.
  # Script should be written to make sure it only runs if needed
  # using the "onlyif" functionality. -Thomas
  cmd.run:
    - name: 'a2enmod rewrite; a2enmod php5; apache2ctl restart'

/opt/observium/config.php:
  file:
    - managed
    - template: jinja
    - source: salt://observium/files/config.php.jinja
    - user: www-data
    - group: www-data
    - mode: 644

/etc/cron.d/observium:
  file:
    - managed
    - source: salt://observium/files/cron.d/observium


{{ base_path }}/rrd:
  file.directory:
    - user: www-data
    - group: www-data
    - makedirs: True

  # This should probably also have some sort of check added so
  # it only runs if neccecary. A script comes to mind - Thomas
  cmd.run:
    - name: 'php /opt/observium/includes/update/update.php'
    - cwd: /opt/observium
    - user: www-data

