Ddoc

$(COZUM_BOLUMU Function Parameters)

$(P
Because the parameters of this function are the kind that gets copied from the arguments, what gets swapped in the function are those copies.
)

$(P
To make the function swap the arguments, both of the parameters must be passed by reference:
)

---
void swap($(HILITE ref) int first, $(HILITE ref) int second) {
    const int temp = first;
    first = second;
    second = temp;
}
---

$(P
With that change, now the variables in $(C main()) would be swapped:
)

$(SHELL
2 1
)

$(P
Although not related to the original problem, also note that $(C temp) is specified as $(C const) as it is not changed in the function.
)

Macros:
        TITLE=Function Parameters Solutions

        DESCRIPTION=Programming in D exercise solutions: Function Parameters

        KEYWORDS=programming in d tutorial function parameters
