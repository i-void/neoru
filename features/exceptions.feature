Feature: Exceptions
  Is exception handling works as expected?

  Scenario: Raise some specific exceptions
    Then Raise SystemError exception
    Then Raise DatabaseError exception
