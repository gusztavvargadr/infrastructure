# Infrastructure

<!--
TODOs

vagrant:
(tls)
vault
vb
dotnet

double check src / sample count
move from ws / packer

general
ci flow
ruby, chef lint, warns
environment generalization with providers (vagrant, terraform)
kitchen machine name from env (suite), allow hostmanager -> multi-machine -> mention at kitchen issue

vagrant
env vars to options
env name load from folder (check with kitchen)
machine / provisioner options directly (do not depend on env, other machines)
default options load from yml
data files load with chef

tls
prevent duplication

windows
windows file from cookbook (static and template)
package from iso (mount / umount)
generic shell with logs, output, elevated or not
official windows cookbook usage
all packages review for idempotence

octopus
clean up / unregister
samples with real projects
tentacle for running terraform / packer
env ps for selecting matching profiles - fetch from consul / vault
terraform chef solo
channels with version number
tentacle reconfigure

dotnet
cookbook for frameworks (include core)
ngen
samples

consul
dns, forwarding
separate tokens
mutliple dcs

vault
ha

chef
no abbreviations (e.g. gv_vs to visual studio)
idempotence everywhere
-->

This repository contains infrastructure components for .NET development with Docker, Visual Studio, IIS and SQL Server on Windows.

- Components
  - [Sources](src/components)
  - [Samples](samples/components)
