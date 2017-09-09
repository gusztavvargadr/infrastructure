name 'server'
run_list(
  'recipe[gusztavvargadr_octopus_sample::server]'
)
default_attributes(
  'gusztavvargadr_octopus' => {
    'server' => {
      'import' => {
        'gusztavvargadr_octopus_sample::server_import' => {
          'password' => 'Octopus42',
        },
      },
    },
  }
)
