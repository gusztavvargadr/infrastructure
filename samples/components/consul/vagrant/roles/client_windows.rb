name 'client_windows'
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
              'name' => 'rdp',
              'port' => 3389,
              'checks' => [
                {
                  'tcp' => 'localhost:3389',
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
