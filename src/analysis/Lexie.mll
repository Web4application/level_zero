{
  open Parser
  exception SyntaxError of string
}

let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z' '_']
let id = alpha (alpha | digit)*

rule token = parse

| [' ' '\t' '\n'] { token lexbuf }
| "async"         { ASYNC }
| "await"         { AWAIT }

| "@selector"     { SELECTOR }
| "["             { LBRACK }
| "]"             { RBRACK }

| id as s         { ID(s) }
| eof             { EOF }
| _               { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
