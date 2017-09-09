name 'client_ubuntu'
run_list(
  'recipe[gusztavvargadr_consul::client]'
)
default_attributes(
  'gusztavvargadr_consul' => {
    'client' => {
      'config' => {
        'options' => {
          'services' => [
            {
              'name' => 'ssh',
              'port' => 22,
              'checks' => [
                {
                  'tcp' => 'localhost:22',
                  'interval' => '10s',
                },
              ],
            },
          ],
        },
      },  
    },
  }
)
