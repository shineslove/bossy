interface Node {
    token_literal() string
} 

interface Statement {
   Node
}

interface Expression {
   Node
}

struct Program {
   statements []Statement
}

fn (pro Program) token_literal() string {
    if pro.statements.len > 0 {
        return pro.statements[0].token_literal()
    }
    return ""
}

