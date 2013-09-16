puppet-manifest-router
======================

A simple rack wrapper app for speeding up puppet run times.

Puppet quickly becomes unmanageably slow when hundreds of node manifests are present. The puppet server catalog compilation must parse all node manifests before compiling the catalog. This simple rack app speeds puppet runs by limiting the node manifests that are imported to only those in the domain of the host requesting the catalog.

Obviously Hiera with roles and profiles is the better/final solution. However, this is a great interim solution while testing and migrating.

Example manifest directory layout:

```
├── domains.d
│   ├── bar.com.d
│   │   ├── hostname.pp
│   │   └── hostname2.pp
│   └── foo.com.d
│       └── hostname.pp
├── envs.d
│   ├── bar.com.pp
│   └── foo.com.pp
└── site.pp
```
Example site.pp, importing all node manifests:

```
$ cat site.pp
import "envs.d/*.pp"
```

Example domain specific "site.pp"

```
$ cat envs.d/bar.com.pp
import "../domains.d/bar.com.d/*.pp"
```

A request for /dev/catalog/hostname.foo.com will result in the --manifest being set to "envs.d/foo.com.pp". If ever a puppet agent hostname does not match a file within envs.d it will default to using "site.pp", thereby importing all hosts.

Installation instructions:

- clone this repo into your rack directory (/etc/puppet/rack/).
- modify the run line at the bottom to your manifest directory and domains.d or chosen subdir name.

 
** The always_restart.txt is a passenger specific file that if present make sure a new passenger process be spawned for each request. It does add to the overhead (context switching), but the difference is nominal and the speed increase from using this wrapper greatly outweight that drawback.

