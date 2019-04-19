{%- macro x509_certificate(name, config, state='present') -%}
{%- set path = config.get('path', '/etc/ssl') %}
{%- set days = config.get('days', 3654) %}
{%- set country = config.get('country', 'FR') %}
{%- set state = config.get('state', 'Nord') %}
{%- set locality = config.get('locality', 'Lille') %}
{%- set organization = config.get('organization', 'Alkivi') %}
{%- set unit = config.get('unit', 'Alkivi') %}
{%- set commonname = config.get('commonname', grains['id']) %}
{%- set email = config.get('email', 'admin@alkivi.fr') %}
{%- set key = path ~ '/' ~ name ~ '.key' %}
{%- set cert = path ~ '/' ~ name ~ '.crt' %}
{%- set require_in = config.get('require_in', False) %}
{{ path }}:
  file.directory:
    - user: {{ config.get('user', 'root') }}
    - group: {{ config.get('group', 'ssl-cert') }}
    - makedirs: True
    - dir_mode: {{ config.get('mode', 755) }}
    - file_mode: {{ config.get('file_mode', 644) }}
    - recurse:
      - user
      - group
      - mode
{{ key }}:
  cmd.run:
    - cwd: {{ path }}
    - unless: test -s {{ cert }}
    - name: openssl req -new -x509 -days {{ days }} -nodes -out {{ cert }} -keyout {{ key }} -subj '/C={{ country }}/ST={{ state }}/L={{ locality }}/O={{ organization }}/OU={{ unit }}/CN={{ commonname }}/emailAddress={{ email }}'
    - require:
      - file: {{ path }}
    {% if require_in %}
    - require_in:
      {% for req_name, req_id in require_in.items() %}
      - {{ req_name }}: {{ req_id }}
      {% endfor %}
    {% endif %}
{%- endmacro -%}
