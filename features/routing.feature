Feature: Routing
  This contains some routing scenario tests

  Scenario Outline: Route with config and regexp
    Given add route as /test with parameters will tested by <regexp>
    Then <true_url> must pass
    Then <false_url> must give error
    Examples:
      | regexp                                            | true_url            | false_url            |
      | /\w{8}/                                              | /test/12345678      | /test/123456789      |
      | /([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?/  | /test/www.yahoo.com | /test/www..yahoo.com |
