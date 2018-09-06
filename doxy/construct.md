# ICGlue construction scripts

## File
An ICGlue construction script is a Tcl script run in an encapsulating namespace by ICGlue.
Besides all Tcl commands, ICGlue commands for hierarchy, codesection and regfile generation are provided.

## Module hierarchy
For creating the module hierarchy the command `M` is provided.
It creates a unit/module hierarchy.

### Example
```tcl
M -unit "abc" -tree {
    tb_abc .................. (tb)
    |
    +-- abc ................. (rtl,ilm)
    |   |
    |   +-- res1<inst1..4> .. (res)
    |   +-- res2<a,b> ....... (res)
    |
    +-- verifip<tb> ......... (res)
}
```

The example will create a unit `abc` with a testbench (`tb`) `tb_abc`,
an rtl module `abc` and an instance of a non-generated resource (`res`)
`verifip` with instance identifier `tb`.
The Module `abc` will contain multiple instances of two other non-generated
resources `res1` (instance identifiers `inst1`, ..., `inst4`) and `res2`
(instance identifiers `a` and `b`).

### Design unit
The design unit for the generated hierarchy can be specified via the `-unit` switch.
Alternatively sub hierarchies can be part of a different unit by specifying `unit=<unitname>`
in the modules properties in parentheses at the end of the module's specification line.

### Hierarchy tree
The hierarchy is specified as a tree block after the `-tree` argument.
Variables and Tcl commands in brackets will be evaluated inside the specified tree.
Hierarchy is defined by indentation of the modules and instances.
It is possible (and looks nice) to draw a tree-like structure, but this structure
is not parsed -- any non-alphabetic characters are just parsed as indentation.

Modules that are not resources will be generated and can only be instantiated once.
The reason is that there is no way to distinguish their sub-instances when creating
signals.
Every instance can have an instance identifier in `<` and `>` delimiters.
Resource instances can have multiple instances specified by separating their
identifiers by commas or alternatively using `..` for a range of numeric identifiers (see example above).

### Module properties
A module can have comma-separated properties set in parentheses at the end of its specification line.
Dot and space characters before the parentheses are ignored and can be used to improve readability.
Properties specify a view, a hardware description language or additional properties.

Views:
* `tb` (testbench)
* `rtl` (rtl description = default)
* `beh` (behavioral description)

Hardware description languages:
* `v` (verilog = default)
* `sv` (systemverilog)
* `vhdl` (vhdl)

Additional properties
* `res` (module is a resource -- resources are assumed to exist,
  will not be generated and are allowed to be instantiated multiple times)
* `ilm` (module is an ILM module -- it will become a place & route macro
  and parameters are not fed through to its instance as this is impossible for macros)
* `inc` (instance of a module specified before, e.g. in an individual hierarchy tree)
* `unit=<unitname>` (to specify an individual unit for a hierarchy tree branch)
* `rf=<rf-name>` (module contains a register file, a name can be specified)
* `rfattr=<attr>=<value>` (additional attribute set for the regfile in a module;
  regfile will have an attribute `<attr>` set to value `<value>`)

### Alternative module/instance specification
Alternatively it is possible to specify individual modules in the form:
```
M [-tb|-rtl|-beh] [-v|-sv|-vhdl] [-ilm] [-res] [-u <unit>] <module-name> [-i <instance-list>]
```

In this case instantiated modules  must already be defined.
Instance identifiers are similar to those in the hierarchy tree.
The flags are similar to the module properties in the hierarchy tree.

## Signals and Parameters
For specifying hierarchical signals and module parameters the commands
`S` (signals) and `P` (parameters) are provided.

Signals and parameters have a unique identifier.
So within a given construction step every signal name and every parameter name
can be specified only once even for different sub hierarchies.

For every signal or parameter explicit endpoints (= instances) within the
hierarchy can be specified where the signal is connected to or the parameter is provided.
The remaining hierarchy will be adapted accordingly if it is between two explicit endpoints
on a hierarchy branch or a common root between two explicit endpoints.

Explicit endpoints are instances with their instance identifiers.
Additionally they can be provided with an explicit instance-specific
port or parameter name after a colon (`:`).
In case of a signal an explicit port name will be used verbatim unless
followed by an exclamation mark (`!`, in which case the port will get a generated suffix
indicating its direction).
Additionally in case of a signal a signal can be connected inverted by prefixing the
explicit endpoint with a tilde (`~`).

Parameters have to be provided a default value, signals can be provided with a value
which will be assigned to them at the signal source point.
Additionally signals can be specified with a bus width.

### Signals
General command structure:
```
S <signal-identifier> [-w <bus-width>] [-v <assigned-value>] <endpoint-list> ... (<--|<->|-->) <endpoint-list> ...
```

The arrow between the endpoint lists specifies the signal direction.
For a directed signal (`<--` or `-->`) only one source endpoint is allowed.

### Parameters
General command structure:
```
P <parameter-identifier> [-v <default-value>] <endpoint-list> ...
```

### Examples
```tcl
# 32 bit regfile config signal
S config1 -w 32 regfile --> core:config_i

# 1 bit tied config signal
S config2 -v {1'b0} mgmt --> core<1..4>:mode! ~accelerator:mode_n!

# parameter
P GPIO_W -v 8 testbench pads

# bidirectional
S gpio -w {GPIO_W} pads <-> testbench
```