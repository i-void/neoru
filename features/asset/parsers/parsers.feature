Feature: Parsers
  Tests about asset parsers of neoru

  @main
  Scenario Outline: Take a file and parse
    Given Prepare <test_file> for parsing
    When Parse with <parser_class>
    Then Expect <result_file> content same as parsed content
  Examples:
    | parser_class  | test_file               | result_file         |
    | Coffee        | coffee/testfile.coffee  | coffee/testfile.js  |
    | Opal          | opal/testfile.rb        | opal/testfile.js    |
    | Sass          | sass/testfile.sass      | sass/testfile.css   |
    | Scss          | scss/testfile.scss      | scss/testfile.css   |


  @sass_parser
  Scenario Outline: Sass parser must return false if filename starts
    with underscore (_)
    Given Prepare <test_file> for parsing
    When Parse with <parser_class>
    Then Expect result must false
  Examples:
    | parser_class  | test_file               |
    | Sass          | sass/_testfile.sass     |
    | Scss          | scss/_testfile.scss     |