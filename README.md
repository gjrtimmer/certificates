# Certificates

This repository allows you to quickly genereate certificates for services and or servers.

## Usage

In order to usage this repository to create certificates you must do the following.

1. Install dependecies `ansible-galaxy install -r requirements.yml`
2. Create `certs` directory if not exists
3. Copy `.config/hosts.yml` -> `hosts.yml`
4. Copy `.config/defaults.yml` -> `config/defaults.yml`
5. Copy `.config/cert.yml` -> `config/cert.yml`

The ansible inventory must be copied first.
By default this does not contain any nodes.
If you add in your own nodes, you will be able to deploy the certificates to your servers.

Please be mindful of the target directories of certificates.
Its even possible to provide multiple target directories for the same certificate.
This allows you to deploy a certificate not only to the default directory but also to additional
target directories for example to `/etc/docker/registry/<registry>/ca.crt`.

The `config/cert.yml` is an example for a certificate.
This file is required, without the precense of at least `one` certificate in the `config` dir,
the certificates playbook will not work, this also applies to the presence of the `config/defaults.yml` file.

Create a configuration file for each certificate that you want in the `config` directory.
Each configuration file should have the minimal configuration for creating a certificate.

```yaml
---
certificates:
  - commonName: "vault.local"
    sign: local
    deploy:
      target:
        - dir: "{{ certificate.dir.remote }}/vault"
          alias: server
    san:
      enabled: true
      dns:
        - "*.vault.local"
        - vault.local
        - node1.local
        - node2.local
        - node3.local
        - node4.local
        - localhost
      ip:
        - 192.168.0.21
        - 192.168.0.22
        - 192.168.0.23
        - 192.168.0.24
        - 127.0.0.1
```

Multiple certificates can be created from a single configuration file.
Without a minimal of 1 configuration file for a certificate the repository will generate an error if you try to run it.

After you configured the basics you can generate your certificate tree with:

```shell
./run.sh
```

## Defaults

The `config/defaults.yml` does not count for generating a certificate.
Make changes to this as you see fit.

The default configuration for the Root CA and intermediate CAs like email address and other properties
will be loaded from the `roles/certificates/defaults/main.yml`, you can override this in the `config/defaults.yml`
and put in your own attributes. See `roles/certificates/defaults/main.yml` for more information.

## Servers

Copy `.config/host.yml` to the `host_vars` directory and provide it with the same name
as a host from your inventory to generate a certificate for a server.

## Certificate Output

The entire certificate tree is generated in the `certs` directory.
The structure within the `certs` directory will follow the default certificate structure
of OpenSSL.

By default two intermediate certificates are generated under the Root CA.

- local
- k3s

### Root CA

The root CA certificate can be found at `certs/certs/root.crt` and the corresponding private
key can be found at `certs/private/root.key`.

### Intermediate CAs

The intermediate CAs can be found in `certs/intermediate` where a folder for each intermediate CA
will be created. The directory structure within each intermediate certificate folder will
be conform the OpenSSL output nad be identical the the structure of `certs`.

Each intermediate CA certificate can be found at `certs/intermediate/<name>/certs/<name>.crt`
this will be accompanied by a `chain.crt` which will hold the certificate chain.

The private key of the intermediate certificate is located at `certs/intermediate/<name>/private/<name>.key`.

You can selected with which `intermediate` certificate a certificate is signed by using the `sign` attribute
of a certificate configuration. See `.config/cert.yml` for example.

### Generated Certificates

The generated certificates can
be found in the `certs/certs` directory. For each generated certificate it will generate a folder
following the `common name` of the certificate. `*` will be converted to the text `wild`.

Each generated certificate will consists of 3 files.

- `<name>.crt`
- `<name>.csr`
- `<name>.key`

## Deploy

Deployment is disabled by default you must configure hosts in the `hosts.yml` inventory and provide
the ansible tag `deploy` in order to deploy the certificates.

The default `run.sh` script does `NOT` include this tag therefor the following command must be used to
deploy the certificates, change the target servers as  you see fit.

```shell
ansible-playbook -l all certs.yml -t deploy`
```
