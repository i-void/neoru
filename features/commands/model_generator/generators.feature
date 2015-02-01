Feature: Model Generator
  Model generator must create models from structure.yml file

  Scenario Outline: Generator must create model files correctly
    Given Clear the fake model directory except <structure_file>
    Given Create a fake model file into model directory
    Given Read the <structure_file>
    When Model files generated
    Then The fake model file must be deleted
    Then Module directories must be created
    Then Model files must be created
    Then Model files must be same with prepared content
  Examples:
    | structure_file |
    | structure.yml  |