default['gusztavvargadr_consul']['server'] = {
  'version' => '0.9.2',
  'client_addr' => '0.0.0.0',
  'config' => {
    'options' => {
      'server' => true,
      'ui' => true,
      'acl_datacenter' => 'dc1',
      'acl_default_policy' => 'deny',
    },
  },
}
