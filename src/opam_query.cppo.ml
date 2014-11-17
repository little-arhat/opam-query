let main field_flags filename =
  let opam = filename |> OpamFilename.of_string |> OpamFile.OPAM.read in
  field_flags |> List.iter (fun fn ->
    fn opam |> print_endline)

open Cmdliner

let field_flags =
  let field name fn = fn, Arg.info ~doc:("Print the value of the `" ^ name ^ ":' field.") [name] in
  let fields = [
    field "name"        (fun x -> x |> OpamFile.OPAM.name |> OpamPackage.Name.to_string);
    field "version"     (fun x -> x |> OpamFile.OPAM.version |> OpamPackage.Version.to_string);
    field "maintainer"  (fun x -> x |> OpamFile.OPAM.maintainer |> String.concat ", ");
    field "author"      (fun x -> x |> OpamFile.OPAM.author |> String.concat ", ");
    field "homepage"    (fun x -> x |> OpamFile.OPAM.homepage |> String.concat ", ");
    field "bug-reports" (fun x -> x |> OpamFile.OPAM.bug_reports |> String.concat ", ");
    field "dev-repo"    (fun x -> x |> OpamFile.OPAM.dev_repo |>
                          CCOpt.map OpamTypesBase.string_of_pin_option |>
                          CCOpt.get "");
    field "license"     (fun x -> x |> OpamFile.OPAM.license |> String.concat ", ");
    field "tags"        (fun x -> x |> OpamFile.OPAM.tags |> String.concat " ");
  ] in
  let name_version =
    (fun opam ->
      (opam |> OpamFile.OPAM.name |> OpamPackage.Name.to_string) ^ "." ^
      (opam |> OpamFile.OPAM.version |> OpamPackage.Version.to_string)),
    Arg.info ~doc:"Print the values of `name:' and `version:' fields separated by a dot."
      ["name-version"]
  in
  Arg.(value & vflag_all [] (fields @ [name_version]))

let filename =
  Arg.(value & pos 0 non_dir_file "opam" &
       info ~docv:"OPAM-FILE" ~doc:"Path to the opam file." [])

let eval_in_t = Term.(pure main $ field_flags $ filename)

let info =
  let doc = STRINGIFY(SYNOPSIS) in
  let man = [
    `S "BUGS";
    `P ("Report bugs at " ^ STRINGIFY(BUG_REPORTS) ^ ".");
  ] in
  Term.info "opam-query" ~doc ~man

let () = match Term.eval (eval_in_t, info) with `Error _ -> exit 1 | _ -> exit 0
