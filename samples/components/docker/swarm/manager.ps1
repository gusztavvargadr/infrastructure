# TODO: check if already member

# if [ ! -f '/vagrant/.vagrant/docker-swarm-join-ip' ];
# then
#   hostname -I | awk '{print $1}' > /vagrant/.vagrant/docker-swarm-join-ip

#   docker swarm init --advertise-addr eth0
#   docker swarm join-token manager -q > /vagrant/.vagrant/docker-swarm-join-token-manager
#   docker swarm join-token worker -q > /vagrant/.vagrant/docker-swarm-join-token-worker

#   docker stack deploy -c /vagrant/stacks/core/docker-compose.yml core
# else

netsh advfirewall firewall add rule name="Docker Engine" dir=in localport=2376 protocol=TCP action=allow
netsh advfirewall firewall add rule name="Docker Swarm Management" dir=in localport=2377 protocol=TCP action=allow
netsh advfirewall firewall add rule name="Docker Swarm Nodes" dir=in localport=7946 protocol=TCP action=allow
netsh advfirewall firewall add rule name="Docker Swarm Nodes" dir=in localport=7946 protocol=UDP action=allow
netsh advfirewall firewall add rule name="Docker Swarm Network" dir=in localport=4789 protocol=UDP action=allow

$ip = Get-Content /vagrant/.vagrant/docker-swarm-join-ip
$token = Get-Content /vagrant/.vagrant/docker-swarm-join-token-manager

"docker swarm join --token $token $($ip):2377" | Invoke-Expression

# fi
