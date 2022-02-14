Ddoc

$(COZUM_BOLUMU The $(C do-while) Loop)

$(P
This program is not directly related to the $(C do-while) loop, as any problem that is solved by the $(C do-while) loop can also be solved by the other loop statements.
)

$(P
The program can guess the number that the user is thinking of by shortening the candidate range from top or bottom according to the user's answers. For example, if its first guess is 50 and the user's reply is that the secret number is greater, the program would then know that the number must be in the range [51,100]. If the program then guesses another number right in the middle of that range, this time the number would be known to be either in the range [51,75] or in the range [76,100].
)

$(P
When the size of the range is 1, the program would be sure that it must be the number that the user has guessed.
)

Macros:
        TITLE=The do-while Loop Solutions

        DESCRIPTION=Programming in D exercise solutions: the 'do-while' loop

        KEYWORDS=programming in d tutorial do-while solution
