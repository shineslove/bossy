module repl

import readline
import lexer { Lexer }

pub fn start() {
	mut lex := Lexer{}
    prompt := ">> "
    mut reader := readline.Readline{}
    for {
        input := reader.read_line(prompt) or { "" }
        if input.is_blank() {
            break
        }
        l := lex.new(input)
        for tok in l {
            println(tok)
        }
    }
}
