# sandwatch
Remember how long commands take, tell me if I have enough time to make a sandwich?

This is inspired by [arbtt](https://arbtt.nomeata.de/#what), the shell built-in time, and the rust utility [tally](https://crates.io/crates/tally).

The name was suggested by [qu1j0t3](https://github.com/qu1j0t3/).

# Why?

Rather than telling me how long something has taken, I would like to know roughly how long this task will take, based on historical records.

Sandwatch records the current directory, the command line, and the runtime for a command.

When running a new command that matches the directory and the first two words of the command line, sandwatch reports expected completion time in sandwich units (five minutes?).

# How to use it?

It's a wrapper command. `sandwatch cabal build` or `sandwatch make` or whatever you like. Perhaps one day this will become a shell builtin written in Rust.

# How to install it?

I suggest using [ghcup](https://www.haskell.org/ghcup/) to install the Haskell compiler and then `cabal build` in your clone of this git repo.

# How does it work?

Sandwatch creates a json file holding entries recording the working directory, the command line, and the execution time.

When a command matches in the same directory, execution from previous runs is average together to give you a rough idea as to whether you have time to make a sandwich or not!
