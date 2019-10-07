
include:
  - nginx


bootrap-deps:
  pkg.installed:
    - pkgs:
      - git
      - curl


/srv/bootstrap/www:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 755
    - makedirs: True


/etc/nginx/sites.d/bootstrap.pypa.io.conf:
  file.managed:
    - source: salt://pypa/bootstrap/config/nginx.conf.jinja
    - template: jinja
    - require:
      - file: /etc/nginx/sites.d/
      - file: /srv/bootstrap/www


pip-clone:
  git.latest:
    - name: https://github.com/pypa/get-pip.git
    - rev: master
    - target: /srv/bootstrap/pip
    - user: nginx
    - force_clone: True
    - force_checkout: True
    - require:
      - pkg: bootrap-deps


setuptools-clone:
  git.latest:
    - name: https://github.com/pypa/setuptools
    - rev: bootstrap
    - target: /srv/bootstrap/setuptools
    - user: nginx
    - force_clone: True
    - force_checkout: True
    - require:
      - pkg: bootrap-deps


buildout-clone:
  git.latest:
    - name: https://github.com/buildout/buildout.git
    - rev: bootstrap-release
    - target: /srv/bootstrap/buildout
    - user: nginx
    - force_clone: True
    - force_checkout: True
    - require:
      - pkg: bootrap-deps


/srv/bootstrap/www/get-pip.py:
  file.symlink:
    - target: /srv/bootstrap/pip/get-pip.py
    - require:
      - git: pip-clone


/srv/bootstrap/www/3.2/:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 755
    - makedirs: True


/srv/bootstrap/www/3.2/get-pip.py:
  file.symlink:
    - target: /srv/bootstrap/pip/3.2/get-pip.py
    - require:
      - git: pip-clone


/srv/bootstrap/www/3.3/:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 755
    - makedirs: True


/srv/bootstrap/www/3.3/get-pip.py:
  file.symlink:
    - target: /srv/bootstrap/pip/3.3/get-pip.py
    - require:
      - git: pip-clone


/srv/bootstrap/www/3.4/:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 755
    - makedirs: True


/srv/bootstrap/www/3.4/get-pip.py:
  file.symlink:
    - target: /srv/bootstrap/pip/3.4/get-pip.py
    - require:
      - git: pip-clone


/srv/bootstrap/www/2.6/:
  file.directory:
    - user: nginx
    - group: nginx
    - mode: 755
    - makedirs: True


/srv/bootstrap/www/2.6/get-pip.py:
  file.symlink:
    - target: /srv/bootstrap/pip/2.6/get-pip.py
    - require:
      - git: pip-clone


/srv/bootstrap/www/ez_setup.py:
  file.symlink:
    - target: /srv/bootstrap/setuptools/ez_setup.py
    - require:
      - git: setuptools-clone


/srv/bootstrap/www/bootstrap-buildout.py:
  file.symlink:
    - target: /srv/bootstrap/buildout/bootstrap/bootstrap.py
    - require:
      - git: buildout-clone


refresh-pip:
  cmd.run:
    - name: 'curl -X PURGE https://bootstrap.pypa.io/get-pip.py'
    - require:
      - file: /srv/bootstrap/www/get-pip.py
    - onchanges:
      - git: pip-clone

refresh-pip-26:
  cmd.run:
    - name: 'curl -X PURGE https://bootstrap.pypa.io/2.6/get-pip.py'
    - require:
      - file: /srv/bootstrap/www/2.6/get-pip.py
    - onchanges:
      - git: pip-clone

refresh-pip-32:
  cmd.run:
    - name: 'curl -X PURGE https://bootstrap.pypa.io/3.2/get-pip.py'
    - require:
      - file: /srv/bootstrap/www/3.2/get-pip.py
    - onchanges:
      - git: pip-clone

refresh-pip-33:
  cmd.run:
    - name: 'curl -X PURGE https://bootstrap.pypa.io/3.3/get-pip.py'
    - require:
      - file: /srv/bootstrap/www/3.3/get-pip.py
    - onchanges:
      - git: pip-clone

refresh-pip-34:
  cmd.run:
    - name: 'curl -X PURGE https://bootstrap.pypa.io/3.4/get-pip.py'
    - require:
      - file: /srv/bootstrap/www/3.4/get-pip.py
    - onchanges:
      - git: pip-clone

refresh-setuptools:
  cmd.run:
    - name: 'curl -X PURGE https://bootstrap.pypa.io/ez_setup.py'
    - require:
      - file: /srv/bootstrap/www/ez_setup.py
    - onchanges:
      - git: setuptools-clone


refresh-buildout:
  cmd.run:
    - name: 'curl -X PURGE https://bootstrap.pypa.io/bootstrap-buildout.py'
    - require:
      - file: /srv/bootstrap/www/bootstrap-buildout.py
    - onchanges:
      - git: buildout-clone


/etc/consul.d/service-pypa-bootstrap.json:
  file.managed:
    - source: salt://consul/etc/service.jinja
    - template: jinja
    - context:
        name: pypa-bootstrap
        port: 9000
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: consul-pkgs
