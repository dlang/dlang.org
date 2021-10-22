Ddoc

$(COZUM_BOLUMU Structs)

$(OL

$(LI
One of the simplest designs is to use two $(C dchar) members:

---
struct Card {
    dchar suit;
    dchar value;
}
---

)

$(LI
It would be as simple as printing the two members side by side:

---
void printCard(Card card) {
    write(card.suit, card.value);
}
---

)

$(LI
Assuming that there is already a function called $(C newSuit()), $(C newDeck()) can be implemented by calling that function for each suit:

---
Card[] newDeck()
out (result) {
    assert(result.length == 52);

} do {
    Card[] deck;

    deck ~= newSuit('♠');
    deck ~= newSuit('♡');
    deck ~= newSuit('♢');
    deck ~= newSuit('♣');

    return deck;
}
---

$(P
The rest of the work can be accomplished by the following $(C newSuit()), which constructs the suit by combining the suit character with each value of a string:
)

---
Card[] newSuit(dchar suit)
in {
    assert((suit == '♠') ||
           (suit == '♡') ||
           (suit == '♢') ||
           (suit == '♣'));

} out (result) {
    assert(result.length == 13);

} do {
    Card[] suitCards;

    foreach (value; "234567890JQKA") {
        suitCards ~= Card(suit, value);
    }

    return suitCards;
}
---

$(P
Note that the functions above take advantage of contract programming to reduce risk of program errors.
)

)

$(LI
Swapping two elements at random would make the deck become more and more shuffled at each repetition. Although it is possible to pick the same element by chance, swapping an element with itself does not have any effect other than missing an opportunity toward a more shuffled deck.

---
void shuffle(Card[] deck, int repetition) {
    /* Note: A better algorithm is to walk the deck from the
     *       beginning to the end and to swap each element
     *       with a random one that is picked among the
     *       elements from that point to the end.
     *
     * It would be even better to call randomShuffle() from
     * the std.algorithm module, which already applies the
     * same algorithm. Please read the comment in main() to
     * see how randomShuffle() can be used. */
    foreach (i; 0 .. repetition) {
        // Pick two elements at random
        immutable first = uniform(0, deck.length);
        immutable second = uniform(0, deck.length);

        swap(deck[first], deck[second]);
    }
}
---

$(P
The function above calls $(C std.algorithm.swap), which simply swaps the values of its two $(C ref) parameters. It is effectively the equivalent of the following function:
)

---
void mySwap(ref Card left,
            ref Card right) {
    immutable temporary = left;
    left = right;
    right = temporary;
}
---

)

)

$(P
Here is the entire program:
)

---
import std.stdio;
import std.random;
import std.algorithm;

struct Card {
    dchar suit;
    dchar value;
}

void printCard(Card card) {
    write(card.suit, card.value);
}

Card[] newSuit(dchar suit)
in {
    assert((suit == '♠') ||
           (suit == '♡') ||
           (suit == '♢') ||
           (suit == '♣'));

} out (result) {
    assert(result.length == 13);

} do {
    Card[] suitCards;

    foreach (value; "234567890JQKA") {
        suitCards ~= Card(suit, value);
    }

    return suitCards;
}

Card[] newDeck()
out (result) {
    assert(result.length == 52);

} do {
    Card[] deck;

    deck ~= newSuit('♠');
    deck ~= newSuit('♡');
    deck ~= newSuit('♢');
    deck ~= newSuit('♣');

    return deck;
}

void shuffle(Card[] deck, int repetition) {
    /* Note: A better algorithm is to walk the deck from the
     *       beginning to the end and to swap each element
     *       with a random one that is picked among the
     *       elements from that point to the end.
     *
     * It would be even better to call randomShuffle() from
     * the std.algorithm module, which already applies the
     * same algorithm. Please read the comment in main() to
     * see how randomShuffle() can be used. */
    foreach (i; 0 .. repetition) {
        // Pick two elements at random
        immutable first = uniform(0, deck.length);
        immutable second = uniform(0, deck.length);

        swap(deck[first], deck[second]);
    }
}

void main() {
    Card[] deck = newDeck();

    shuffle(deck, 100);
    /* Note: Instead of the shuffle() call above, it would be
     *       better to call randomShuffle() as in the
     *       following line:
     *
     * randomShuffle(deck);
     */
    foreach (card; deck) {
        printCard(card);
        write(' ');
    }

    writeln();
}
---


Macros:
        TITLE=Structs Solutions

        DESCRIPTION=Programming in D exercise solutions: Structs

        KEYWORDS=d programming book tutorial struct exercise solutions
