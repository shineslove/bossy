module token

pub enum Token {
	assign
	plus
	minus
	bang
	asterisk
	slash
	lt
	gt
	lparen
	rparen
	lbrace
	rbrace
	comma
	semicolon
	integer
	ident
	not_eq
	eq
	function
	let
	@true
	@false
	@if
	@else
	@return
	eof
	illegal
}

pub struct TokenType {
pub:
	value string
	@type Token
}
