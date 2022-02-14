Ddoc

$(DERS_BOLUMU $(IX scope(success)) $(IX scope(exit)) $(IX scope(failure)) $(CH4 scope))

$(P
As we have seen in the previous chapter, expressions that must always be executed are written in the $(C finally) block, and expressions that must be executed when there are error conditions are written in $(C catch) blocks.
)

$(P
We can make the following observations about the use of these blocks:
)

$(UL

$(LI $(C catch) and $(C finally) cannot be used without a $(C try) block.)

$(LI Some of the variables that these blocks need may not be accessible within these blocks:

---
void foo(ref int r) {
    try {
        $(HILITE int addend) = 42;

        r += addend;
        mayThrow();

    } catch (Exception exc) {
        r -= addend;           $(DERLEME_HATASI)
    }
}
---

$(P
That function first modifies the reference parameter and then reverts this modification when an exception is thrown. Unfortunately, $(C addend) is accessible only in the $(C try) block, where it is defined. $(I ($(B Note:) This is related to name scopes, as well as object lifetimes, which will be explained in $(LINK2 lifetimes.html, a later chapter.)))
)

)

$(LI Writing all of potentially unrelated expressions in the single $(C finally) block at the bottom separates those expressions from the actual code that they are related to.
)

)

$(P
The $(C scope) statements have similar functionality to the $(C catch) and $(C finally) scopes but they are better in many respects. Like $(C finally), the three different $(C scope) statements are about executing expressions when leaving scopes:
)

$(UL
$(LI $(C scope(exit)): the expression is always executed when exiting the scope, regardless of whether successfully or due to an exception)

$(LI $(C scope(success)): the expression is executed only if the scope is being exited successfully)

$(LI $(C scope(failure)): the expression is executed only if the scope is being exited due to an exception)
)

$(P
Although these statements are closely related to exceptions, they can be used without a $(C try-catch) block.
)

$(P
As an example, let's write the function above with a $(C scope(failure)) statement:
)

---
void foo(ref int r) {
    int addend = 42;

    r += addend;
    $(HILITE scope(failure)) r -= addend;

    mayThrow();
}
---

$(P
The $(C scope(failure)) statement above ensures that the $(C r -= addend) expression will be executed if the function's scope is exited due to an exception. A benefit of $(C scope(failure)) is the fact that the expression that reverts another expression is written close to it.
)

$(P
$(C scope) statements can be specified as blocks as well:
)

---
    scope(exit) {
        // ... expressions ...
    }
---

$(P
Here is another function that tests all three of these statements:
)

---
void test() {
    scope(exit) writeln("when exiting 1");

    scope(success) {
        writeln("if successful 1");
        writeln("if successful 2");
    }

    scope(failure) writeln("if thrown 1");
    scope(exit) writeln("when exiting 2");
    scope(failure) writeln("if thrown 2");

    throwsHalfTheTime();
}
---

$(P
If no exception is thrown, the output of the function includes only the $(C scope(exit)) and $(C scope(success)) expressions:
)

$(SHELL
when exiting 2
if successful 1
if successful 2
when exiting 1
)

$(P
If an exception is thrown, the output includes the $(C scope(exit)) and $(C scope(failure)) expressions:
)

$(SHELL
if thrown 2
when exiting 2
if thrown 1
when exiting 1
object.Exception@...: the error message
)

$(P
As seen in the outputs, the blocks of the $(C scope) statements are executed in reverse order. This is because later code may depend on previous variables. Executing the $(C scope) statements in reverse order enables undoing side effects of earlier expressions in a consistent order.
)

Macros:
        TITLE=scope

        DESCRIPTION=The scope(success), scope(failure), and scope(exit) statements that are used for specifying expressions that must be executed when exiting scopes.

        KEYWORDS=d programming language tutorial book scope
