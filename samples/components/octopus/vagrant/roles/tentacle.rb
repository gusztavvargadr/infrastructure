name 'tentacle'
run_list(
  'recipe[gusztavvargadr_octopus_sample::tentacle]'
)
default_attributes(
  'gusztavvargadr_octopus' => {
    'tentacle' => {
      'environment_names' => [
        'environment',
      ],
      'tenant_names' => [
        'tenant',
      ],
      'role_names' => [
        'tentacle',
      ],
    },
  }
)
