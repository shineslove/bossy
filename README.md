# Monkey Language Interpreter in V

Completed [Monkey Programming Language](https://monkeylang.org/) in [V](https://github.com/vlang/v) from the [Interpreter Book by Thorsten Ball](https://interpreterbook.com)

## Thoughts
It was great writing this in V. There were a couple quirks along the way that made things harder like an instance when not have mut on a method that didn't need it meant it didn't have the latest data.
An instance where for some reason V was trying to access an empty array even though I have a if statement to try and stop it, and needed another layer of if statement to stop it. If a match had implicit returns and you add a return to one of them things blew up.
And the biggest thing that made it hard to want to go to the next part with V was that when using the finished interpreter on a monkey file it loses track of a function (fibonacci). At first I was hoping it was a bug on my part, but then when I just move things around, like calculating the fib before I add other methods to memory, it works fine. 
It seems I have to do recursive monkey functions first in the script before anything else or V loses track of things. Not even sure where to start to debug that...
I'm sure if I asked and they took a look we could see why, but I don't want to take their time on such a trivial issue. It's more important for them to work on getting V stable then my tiny issues, especially if they're planning to rewrite V in the future. 
So for now, I'm planning to continue on with Rust for my language because I don't want extra instability in my language apart from the bugs I'll be introducing. I still think a lot of complex things can be done with V especially if you know C in case you need to debug it. 
I still love using V and plan to use it for rapid prototyping, but until 1.0 I'll wait on using it for a main project.
