# Infrastructure

<!--
TODOs

general
ci flow
ruby, chef lint, warns
idempotence everywhere
environment generalization with providers (vagrant, terraform)
samples for all
vagrant components - don't depend on each other (octopus / vault / consul)

vagrant
env vars to options
env name load from folder (check with kitchen)

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

dotnet
cookbook for frameworks (include core)
ngen
samples

consul
with chef cookbook
linux / windows samples
dns, forwarding
separate tokens

vault
ha
-->

This repository contains infrastructure components for .NET development with Docker, Visual Studio, IIS and SQL Server on Windows.

- Components
  - [Sources](src/components)
  - [Samples](samples/components)
