Ruby Slim Protocol (V0.1)
=========================

Setup
-----

Put these command in a parent of the Ruby test pages.

    !define TEST_SYSTEM {slim}
    !define TEST_RUNNER {<wherever you put Ruby Slim>/lib/run_ruby_slim.rb}
    !define COMMAND_PATTERN {ruby -I %p %m}
    !define PATH_SEPARATOR {-I}
    !path <wherever you put Ruby Slim>/lib
    !path <any directory where you have ruby fixtures>

Paths can be relative. You should put the following in an appropriate SetUp page:

    !|import|
    |<ruby module of fixtures>|

You can have as many rows in this table as you like, one for each module that
contains fixtures. Note that this needs to be the *name* of the module as
written in the Ruby code, not the filename where the module is defined.

Ruby slim works a lot like Java slim. We tried to use ruby method naming
conventions. So if you put this in a table:

    |SomeDecisionTable|
    |input|get output?|
    |1    |2          |

Then it will call the `set_input` and `get_output` functions of the
`SomeDecisionTable` class.

The `SomeDecisionTable` class would be written in a file called
`some_decision_table.rb`, like this (the file name must correspond to the class
name defined within, and the module name must match the one you are importing):

    module MyModule
      class SomeDecisionTable
        def set_input(input)
          @x = input
        end

        def get_output
          @x
        end
      end
    end

Note that there is no type information for the arguments of these functions, so
they will all be treated as strings. This is important to remember! All
arguments are strings. If you are expecting integers, you will have to convert
the strings to integers within your fixtures.


Hashes
------

There is one exception to the above rule. If you pass a HashWidget in a table,
then the argument will be converted to a Hash.

Consider, for example, this fixtures class:

    module TestModule
      class TestSlimWithArguments
        def initialize(arg)
          @arg = arg
        end

        def arg
          @arg
        end

        def name
          @arg[:name]
        end

        def addr
          @arg[:addr]
        end

        def set_arg(hash)
          @arg = hash
        end
      end
    end

This corresponds to the following tables.

    |script|test slim with arguments|!{name:bob addr:here}|
    |check|name|bob|
    |check|addr|here|

    |script|test slim with arguments|gunk|
    |check|arg|gunk|
    |set arg|!{name:bob addr:here}|
    |check|name|bob|
    |check|addr|here|

Note the use of the HashWidgets in the table cells. These get translated into
HTML, which RubySlim recognizes and converts to a standard ruby `Hash`.


System Under Test
-----------------

If a fixture has a `sut` method that returns an object, then if a method called
by a test is not found in the fixture itself, then if it exists in the object
returned by `sut` it will be called. For example:

    !|script|my fixture|
    |func|1|

    class MySystem
      def func(x)
        #this is the function that will be called.
      end
    end

    class MyFixture
      attr_reader :sut

      def initialize
        @sut = MySystem.new
      end
    end

Since the fixture `MyFixture` does not have a function named `func`, but it
_does_ have a method named `sut`, RubySlim will try to call `func` on the
object returned by `sut`.


Library Fixtures
----------------

Ruby Slim supports the `|Library|` feature of FitNesse. If you declare certain
classes to be libraries, then if a test calls a method, and the specified
fixture does not have it, and there is no specified `sut`, then the libraries
will be searched in reverse order (latest first). If the method is found, then
it is called.

For example:

    |Library|
    |echo fixture|

    |script|
    |check|echo|a|a|

    class EchoFixture
      def echo(x)
        x
      end
    end

Here, even though no fixture was specified for the script table, since a
library was declared, functions will be called on it.

