module token

pub enum Token {
	assign
	plus
	lparen
	rparen
	lbrace
	rbrace
	comma
	semicolon
	let
	integer
	function
	ident
	eof
	illegal
}

pub struct TokenType {
pub:
	value string
	@type Token
}
