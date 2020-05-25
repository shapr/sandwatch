# sandwatch
Remember how long commands take, tell me if I have enough time to make a sandwich?

This is inspired by [arbtt](https://arbtt.nomeata.de/#what), the shell built-in time, and the rust utility [tally](https://crates.io/crates/tally).

The name was suggested by [qu1j0t3](https://github.com/qu1j0t3/).

# Why?

Rather than telling me how long something has taken, I would like to know roughly how long this task will take, based on historical records.

Sandwatch records the current directory, the command line, and the runtime for a command.

When running a new command that matches the directory and the first two words of the command line, sandwatch reports expected completion time in sandwich units (five minutes?).
