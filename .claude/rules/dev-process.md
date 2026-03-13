# Development Process

## Bug Fixes

When a bug is reported, work autonomously through these steps without asking for input:

1. Check for a Makefile and run the existing test suite (e.g. `make test`) to see current failures
2. Read the relevant source files to understand the code
3. Write a new test that reproduces the specific bug
4. Confirm the new test fails
5. Implement a fix
6. Re-run the full test suite
7. If any tests fail, diagnose and fix without breaking other tests
8. Repeat until ALL tests pass
9. Commit with a descriptive message
