Ddoc

$(DERS_BOLUMU $(IX operator precedence) $(IX precedence, operator) Operator Precedence)

$(P
As we have been using throughout the book, expressions can be $(I chained) with more than one operator. For example, the following line contains four expressions chained with three operators:
)

---
    a = b + c * d    // three operators: =, +, and *
---

$(P
Operator precedence rules specify the order that the chained operators are executed in and the expressions that they use. Operators are executed according to their precedences: first the higher ones, then the lower ones.
)

$(P
The following is D's operator precedence table. Operators are listed from the highest precedence to the lowest. The ones that are in the same table row have the same precedence. (Line wrapping inside table cells is insignificant; for example, $(C ==) and $(C !is) have the same precedence.) Unless specified otherwise, operators are $(I left-associative).
)

$(P
Some of the terms used in the table are explained later below.
)

<table class="full" border="1" cellpadding="4" cellspacing="0">

<col width="20%"/>
<col width="28%"/>
<col width="52%"/>

<th scope="col">Operators</th>
<th scope="col">Description</th>
<th scope="col">Notes</th>

<tr>

<td> $(C !)           </td>
<td class="serif"> Template instantiation</td>
<td class="serif">Cannot be chained
</td></tr>
<tr>

<td> $(C =&gt;)          </td>
<td class="serif">Lambda definition</td>
<td class="serif"> Not a real operator; occurs twice in the table; this row is for binding power to the $(I left)
</td></tr>
<tr>

<td> $(C . ++ -- $(PARANTEZ_AC) [) </td>
<td class="serif"> Postfix operators        </td>
<td class="serif">$(C $(PARANTEZ_AC)) and $(C [) must be balanced with $(C $(PARANTEZ_KAPA)) and $(C ]), respectively
</td></tr>
<tr>

<td> $(C ^^)          </td>
<td class="serif"> Power operator           </td>
<td class="serif"> Right-associative
</td></tr>
<tr>

<td> $(C ++ -- * + - ! &amp; ~ cast) </td>
<td class="serif"> Unary operators          </td>
<td class="serif">
</td></tr>
<tr>

<td> $(C * / %)       </td>
<td class="serif"> Binary operators</td>
<td class="serif">
</td></tr>
<tr>

<td> $(C + - ~)       </td>
<td class="serif">Binary operators</td>
<td class="serif"></td>

</tr>
<tr>

<td> $(C &lt;&lt; &gt;&gt; &gt;&gt;&gt;)   </td>
<td class="serif"> Bit shift operators      </td>
<td class="serif">
</td></tr>
<tr>

<td>$(C == != &gt; &lt; &gt;= &lt;= in !in is !is) </td>
<td class="serif"> Comparison operators     </td>
<td class="serif"> Unordered with respect to bitwise operators, cannot be chained
</td></tr>
<tr>

<td> $(C &amp;)           </td>
<td class="serif">Bitwise $(I and)</td>
<td class="serif"> Unordered with respect to comparison operators
</td></tr>
<tr>

<td> $(C ^)           </td>
<td class="serif"> Bitwise $(I xor)</td>
<td class="serif"> Unordered with respect to comparison operators
</td></tr>
<tr>

<td> $(C |)           </td>
<td class="serif"> Bitwise $(I or)</td>
<td class="serif"> Unordered with respect to comparison operators
</td></tr>
<tr>

<td> $(C &amp;&amp;)          </td>
<td class="serif">Logical $(I and)</td>
<td class="serif">Short-circuit</td>

</tr>
<tr>

<td>$(C ||)</td>
<td class="serif">Logical $(I or)</td>
<td class="serif">Short-circuit</td>

</tr>
<tr>

<td>$(C ?:)</td>
<td class="serif">Ternary operator</td>
<td class="serif">Right-associative
</td></tr>
<tr>

<td>$(C = -= += = *= %= ^= ^^= ~= &lt;&lt;= &gt;&gt;= &gt;&gt;&gt;=)
 </td>
<td class="serif"> Assignment operators     </td>
<td class="serif"> Right-associative
</td></tr>
<tr>

<td> $(C =&gt;)          </td>
<td class="serif">Lambda definition</td>
<td class="serif"> Not a real operator; occurs twice in the table; this row is for binding power to the $(I right)</td>
</tr>
<tr>

<td> $(C ,)           </td>
<td class="serif">Comma operator</td>
<td class="serif">Not to be confused with using comma as a separator (e.g. in parameter lists)</td>

</tr>
<tr>

<td> $(C ..)          </td>
<td class="serif">Number range</td>
<td class="serif"> Not a real operator; hardwired into syntax at specific points
</td></tr>
</table>


$(H6 $(IX operator chaining) $(IX chaining, operator) Chaining)

$(P
Let's consider the line from the beginning of the chapter:
)

---
    a = b + c * d
---

$(P
Because binary $(C *) has higher precedence than binary $(C +), and binary $(C +) has higher precedence than $(C =), that expression is executed as the following parenthesized equivalent:
)

---
    a = (b + (c * d))    // first *, then +, then =
---

$(P
As another example, because postfix $(C .) has higher precedence than unary $(C *), the following expression would first access member $(C ptr) of object $(C o) and then dereference it:
)

---
    *o.ptr      $(CODE_NOTE dereferences pointer member o.ptr)
    *(o.ptr)    $(CODE_NOTE equivalent of the above)
    (*o).ptr    $(CODE_NOTE_WRONG NOT equivalent of the above)
---

$(P
Some operators cannot be chained:
)

---
    if (a > b == c) {      $(DERLEME_HATASI)
        // ...
    }
---

$(SHELL
Error: found '==' when expecting '$(PARANTEZ_KAPA)'
)

$(P
The programmer must specify the desired execution order with parentheses:
)

---
    if ((a > b) == c) {    $(CODE_NOTE compiles)
        // ...
    }
---

$(H6 $(IX left-associative) $(IX right-associative) $(IX associativity, operator) $(IX operator associativity) Associativity)

$(P
If two operators have the same precedence, then their associativity determines which operator is executed first: the one on the left or the one on the right.
)

$(P
Most operators are $(I left-associative); the one on the left-hand side is executed first:
)

---
    10 - 7 - 3;
    (10 - 7) - 3;    $(CODE_NOTE equivalent of the above (== 0))
    10 - (7 - 3);    $(CODE_NOTE_WRONG NOT equivalent of the above (== 6))
---

$(P
Some operators are right-associative; the one on the right-hand side is executed first:
)

---
    4 ^^ 3 ^^ 2;
    4 ^^ (3 ^^ 2);    $(CODE_NOTE equivalent of the above (== 262144))
    (4 ^^ 3) ^^ 2;    $(CODE_NOTE_WRONG NOT equivalent of the above (== 4096))
---

$(H6 Unordered operator groups)

$(P
Precedence between bitwise operators and logical operators are not specified by the language:
)

---
    if (a & b == c) {      $(DERLEME_HATASI)
        // ...
    }
---

$(SHELL
Error: b == c must be parenthesized when next to operator &
)

$(P
The programmer must specify the desired execution order with parentheses:
)

---
    if ((a & b) == c) {    $(CODE_NOTE compiles)
        // ...
    }
---

$(H6 $(IX =>, operator precedence) The precedence of $(C =>))

$(P
Although $(C =>) is not an operator, it takes part in the table twice to specify how it interacts with operators on its left-hand side and right-hand side.
)

---
    l = a => a = 1;
---

$(P
Although both sides of $(C =>) above have an $(C =) operator, $(C =>) has precedence over $(C =) on the left hand side so it $(I binds stronger) to $(C a) as if the programmer wrote the following parentheses:
)

---
    l = (a => a = 1);
---

$(P
On the right-hand side, $(C =>) has lower precedence than $(C =), so the $(C a) on the right-hand side binds stronger to $(C =) as if the following extra set of parentheses are specified:
)

---
    l = (a => $(HILITE $(PARANTEZ_AC))a = 1$(HILITE $(PARANTEZ_KAPA)));
---

$(P
As a result, the lambda expression does not become just $(C a&nbsp;=>&nbsp;a) but includes the rest of the expression as well: $(C a&nbsp;=>&nbsp;a&nbsp;=&nbsp;1), which means $(I given a, produce a = 1). That lambda is then assigned to the variable $(C l).
)

$(P
$(I $(B Note:) This is just an example; otherwise, $(C a&nbsp;=&nbsp;1) is not a meaningful body for a lambda because the mutation to its parameter $(C a) is seemingly lost and the result of calling the lambda is always 1. (The reason I say "seemingly" is that the assignment operator may have been overloaded for $(C a)'s type and may have side-effects.))
)

$(H6 $(IX , (comma), operator) $(IX comma operator) Comma operator)

$(P
Comma operator is a binary operator. It executes first the left-hand side expression then the right-hand side expression. The values of both expressions are ignored.
)

---
    int a = 1;
    foo()$(HILITE ,) bar()$(HILITE ,) ++a;

    assert(a == 2);
---

$(P
The comma operator is most commonly used with $(C for) loops when the loop iteration involves mutating more than one variable:
)

---
    for ({ int i; int j; } i < 10; ++i$(HILITE ,) ++j) {
        // ...
    }
---

Macros:
        TITLE=Operator Precedence

        DESCRIPTION=The precedences and associativity of D operators.

        KEYWORDS=d programming lesson book tutorial operator precedence associativity
