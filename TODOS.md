# Todo-List

## general
- add check (nagelfar shell script)

## lib
- library cleanup
  - merge similar data-structs
  - only one regfile per module
- localparams?
- allow partial connections of bus signals (low-prio - would require larger reworks)

## tcllib
- signals: add type switch (e.g. struct types)
- reuse created rtl as ressource (also in testbench)
- add instance-only command or check in M if already exists: sane values, instances only?
- regfile:
  - specify regfile portnames (clk, ...)
- codesections: make adapt-selectively the default?
- checks: use "origin" information of constructed parts for logging of warnings
- support systemverilog structs

## templates
- signals: add type (see tcllib)
- testbench -> regs
- update systemverilog templates for logic type
- testbench to outside dummy module (see nowriteout function ?)
- rewrite regfile template as systemverilog woof with enums for addresse?

## bin
- allow multiple construction scripts?
- add "nowriteout" function or similar? -> allows for construction with intermediate clean

## test
- more tests
- coverage? (via nagelfar)
