Feature: Route Class Feature
  This contains some routing scenario tests
  it uses features_fake_app

  Scenario Outline: Route with config and regexp
    Given mock route class with <name> <path> <parameters_url> <action_address> <subdomain> <methods> <position>
    Then check the result with <host>, <url>, <result>
    Examples:
      | name     | path        | parameters_url | action_address | subdomain | methods  | position | host          | url             | result    |
      | about_us | /about      | -              | main::about    | -         | get      | -        | localhost     | get:/about      | -         |
      | about_us | /about      | -              | main::about    | -         | get      | -        | localhost     | get:/about/him  | Hello him |
      | about_us | /about      | -              | main::about    | -         | post,put | -        | localhost     | get:/about/him  | -         |
      | about_us | /about      | -              | main::about    | -         | post,put | -        | localhost     | post:/about/him | Hello him |
      | about_us | /about      | /\d+           | main::about    | -         | post,put | -        | localhost     | post:/about/him | -         |
      | about_us | /about      | /\d+           | main::about    | -         | post,put | -        | localhost     | post:/about/12  | Hello 12  |
      | api      | /api/t      | /[0-9]         | main:api:      | -         | delete   | -        | localhost     | delete:/api/t/6 | Vers: 6   |
      | api      | /api/t      | -              | main:api:      | -         | delete   | -        | localhost     | delete:/api/t/  | Vers: 3   |
      | api      | /path       | -              | main::         | api       | delete   | -        | api.local.host| delete:/path/   | Main Page |
      | api      | /path       | -              | main::         | apic      | delete   | -        | api.local.host| delete:/path/   | -         |
      | api      | /api/t      | /[a-z]         | main:api:index | -         | delete   | -        | localhost     | delete:/api/t/6 | -         |
      | site     | /           | /[a-z]+?/[1-9] | ::             | -         | put      | -        | localhost     | put:/api/3      | api;3     |
      | site     | /           | /[a-z]+?/[1-9] | :site:         | -         | put      | -        | localhost     | put:/api        | -         |
      | site     | /           | -              | ::index        | -         | put      | -        | localhost     | put:/api        | -         |
      | site     | /           | -              | ::index        | -         | put      | -        | localhost     | put:/v1/v2      | v1;v2     |
      | site     | /           | -              | ::index        | -         | put      | -        | localhost     | put:/v1/v2/v3   | -         |
      | site     | /v1         | -              | ::index        | -         | put      | -        | localhost     | put:/v1/v2/v3   | v2;v3     |

  Scenario: Route with autoloader
    Given autoload all actions