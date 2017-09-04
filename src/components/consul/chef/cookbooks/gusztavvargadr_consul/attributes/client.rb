default['gusztavvargadr_consul']['client'] = {
  'version' => '0.9.2',
  'client_addr' => '127.0.0.1',
  'config' => {
    'options' => {
      'ui' => true,
      'acl_datacenter' => 'dc1',
    },
  },
}
