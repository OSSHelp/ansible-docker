# Docker

[![Build Status](https://drone.osshelp.io/api/badges/ansible/docker/status.svg?ref=refs/heads/master)](https://drone.osshelp.io/ansible/docker)

## Description

The role installs Docker (stable or test), docker-compose and required python modules. It can do:

- log in registries
- setup loki log driver
- setup userns mod
- deploy compose files
- init docker swarm
- deploy swarm stacks
- create networks, volumes, containers

## Deploy examples

### Install docker

Stable branch:

``` yaml
    - role: docker
```

Test branch:

``` yaml
    - role: docker
      repo_branch: test
```

### Configure only mode

``` yaml
    - role: docker
      docker_setup: configure
```

### Enable live-restore mode

Option is incompatible with swarm mode!

``` yaml
    - role: docker
      live_restore: true
```

### Log in to registries

The list in the ansible vault file with one private registry:

``` yaml
docker_registries:
  - registry: project-registry.ossbuild.ru
    user: project-ro
    password: pass
```

The list in the vault with two private registries and dockerhub private registry:

``` yaml
docker_registries:
  - registry: project-registry.ossbuild.ru
    user: project-ro
    password: pass
  - registry: registry.project.com
    user: user
    password: pass
  - user: dockerhub-user
    password: dockerhub-pass
```

Section in the playbook:

``` yaml
    - role: docker
      registries: "{{ docker_registries }}"
```

### Log options

- `log.max_size`. default `50m`
- `log.max_file`. default `10`

[Documentation](https://docs.docker.com/config/containers/logging/configure/)

### Loki log driver

Installation only:

``` yaml
    - role: docker
      loki: true
```

Installation and setup as default log driver for docker daemon:

``` yaml
    - role: docker
      loki:
        host: https://loki_host
```

Optional parameters:

- `loki.uri`. default `/loki/api/v1/push`
- `loki.external_labels`. default `container_name={{.Name}}`
- `loki.batch_size`. default `102400`
- `loki.timeout`. default `10s`
- `loki.batch-wait`. default `1s`
- `loki.min_backoff`. default `100ms`
- `loki.max_backoff`. default `10s`
- `loki.retries`. default `10`

Log options for Loki:

- `log.mode`. default `non-blocking`
- `log.max_buffer_size`. default `5m`

[Loki docker log driver documentation](https://github.com/grafana/loki/blob/master/cmd/docker-driver/README.md)

### Environment variables for compose or stack

Should be in vault:

``` yaml
docker_deploy_envs:
  VAR1: value
  VAR2: value
```

Section in the playbook:

``` yaml
    - role: docker
      deploy_envs: "{{ docker_deploy_envs }}"
```

Usage in compose/stack files:

``` yaml
  service:
    image: alpine:latest
    command: command with $VAR1
    environment:
      SOMETHING_SECRET: $VAR2
```

### Deploy compose files

Repository structure:

``` shell
.
├── docker-compose
│   ├── compose-project-name.yml
│   └── compose-project2-name.yml
├── inventory
├── server.yml
├── README.md
├── requirements.yml
└── vault.yml

```

compose-project-name.yml and compose-project2-name.yml - these are docker compose files

Section in the playbook:

``` yaml
    - role: docker
      composes:
        - name: compose-project-name
        - name: compose-project2-name
```

### Deploy stack files

Repository structure:

``` shell
.
├── docker-stack
│   ├── stack1.yml
│   └── stack2.yml
├── inventory
├── server.yml
├── README.md
├── requirements.yml
└── vault.yml

```

stack1.yml and stack2.yml - these are docker compose files

Section in the playbook:

``` yaml
    - role: docker
      stacks:
        - name: stack1
        - name: stack2
```

### Init swarm without deploy stacks

``` yaml
    - role: docker
      swarm_init: true
```

### Deploy networks

``` yaml
    networks:
      - {name: network_name}
```

### Deploy volumes

``` yaml
    volumes:
      - {name: volume_name}
```

### Deploy containers

``` yaml
    - role: docker
      containers:
        - command: redis-server --appendonly true
          exposed_ports: [6379]
          image: redis
          name: redis
          networks:
            - {name: testnet}
          published_ports: ['6379:6379']
          state: absent
        - image: portainer/portainer
          name: portainer
          published_ports: ['9000:9000']
          volumes: ['/var/run/docker.sock:/var/run/docker.sock', 'portainer_data:/data']
        - capabilities: [SYS_PTRACE]
          env: {PGID: 999}
          image: firehol/netdata
          name: netdata
          published_ports: ['19999:19999']
          security_opts: [apparmor=unconfined]
          volumes: ['/proc:/host/proc:ro', '/sys:/host/sys:ro', '/var/run/docker.sock:/var/run/docker.sock:ro']
```

## To-do

- add docker swarm stacks support (join)
- add overload module (load dynamically plus insert into /etc/modules?)
- add testing on VMs instead of LXC (can't start any container in case of LXD nesting, apparmor issues)
