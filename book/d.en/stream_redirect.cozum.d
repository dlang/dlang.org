Ddoc

$(COZUM_BOLUMU Redirecting the Standard Input and Output Streams)

$(P
Redirecting standard input and output of programs are commonly used especially on Unix-based operating system shells. (A shell is the program that interacts with the user in the terminal.) Some programs are designed to work well when piped to other programs.
)

$(P
For example, a file named $(C deneme.d) can be searched under a directory tree by piping $(C find) and $(C grep) as in the following line:
)

$(SHELL
find | grep deneme.d
)

$(P
$(C find) prints the names of all of the files to its output. $(C grep) receives that output through its input and prints the lines that contain $(C deneme.d) to its own output.
)

Macros:
        TITLE=Redirecting the Standard Input and Output Streams Solutions

        DESCRIPTION=Problem solutions for the Redirecting Streams Input and Output Streams chapter.

        KEYWORDS=d programming lesson book tutorial redirect standard input output problem solution
