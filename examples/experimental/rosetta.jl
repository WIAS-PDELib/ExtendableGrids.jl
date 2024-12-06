###########################################
# Define three modules with different
# but compatible data structures
#############
module ModFoo

    struct Foo
        foo::Vector
    end

    export Foo
end

#############
module ModBar

    struct Bar
        bar::Vector
    end

    export Bar
end

#############
module ModBaz

    struct Baz
        baz::Vector
    end

    export Baz
end


#############################################
# The Rosetta module stores code which knows
# how to convert between the data structures of the
# different modules without drawing in all the dependencies

# If this would be a package, dependencies only would be used
# in the unit tests, not while using this package

module Rosetta

    # Dummy module to define default
    module NoModule end

    # Heuristic methods to determine
    # a particular module
    isModFoo(mod) = isdefined(mod, :Foo)
    isModBar(mod) = isdefined(mod, :Bar)

    # Concrete conversion methods
    convert_foo_to_bar(foo, FooModule, BarModule) = BarModule.Bar(foo.foo)
    convert_bar_to_foo(bar, BarModule, FooModule) = FooModule.Foo(bar.bar)


    # Generic conversion method - the one "exported" from Rosetta
    function Base.convert(newtype, x; From = NoModule, To = NoModule)
        return if isModFoo(From)&&isModBar(To)
            convert_foo_to_bar(x, From, To)
        elseif isModBar(From)&&isModFoo(To)
            convert_bar_to_foo(x, From, To)
        else
            throw(ArgumentError("undefined conversion from $(typeof(x)) to $(newtype)"))
        end
    end

end

#################################
# Sample code (using locally defined modules here)
using .ModFoo
using .ModBar
using .ModBaz

using .Rosetta

function testrosetta()
    foo = Foo(rand(100))
    bar = convert(Bar, foo, From = ModFoo, To = ModBar)
    foo1 = convert(Foo, bar, From = ModBar, To = ModFoo)
    foo1 === foo || println("transitivity error")
    return try
        baz = convert(Baz, foo)
    catch e
        println("undefined conversion:")
        println(e)
    end
end
