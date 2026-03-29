(* index.ml - Static Analysis Entry Point *)
open Lexing

let print_position outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  Printf.fprintf outx "%s:%d:%d" pos.pos_fname
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

(** Basic parser bridge to detect unsafe Objective-C calls **)
let parse_with_error lexbuf =
  try 
    (* Placeholder for actual Cycript grammar parsing *)
    print_endline "Analysing Cycript script for safety..."
  with
  | _ -> 
    fprintf stderr "%a: syntax error\n" print_position lexbuf;
    exit (-1)

let () =
  let filename = if Array.length Sys.argv > 1 then Sys.argv.(1) else "input.cy" in
  let inx = open_in filename in
  let lexbuf = Lexing.from_channel inx in
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
  parse_with_error lexbuf;
  close_in inx
