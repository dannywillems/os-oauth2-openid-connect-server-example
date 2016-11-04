[%%server
  open Eliom_parameter
]

(**************************************************************************** *)
(** Services **)

let%server register_oauth_client =
  let param =
      ((string "app_name") ** (string "description"))
      **
      (string "redirect_uri")
  in
  Eliom_service.create
    ~name:"register_oauth_client"
    ~path:Eliom_service.No_path
    ~meth:(Eliom_service.Get param)
    ()

let%client register_oauth_client =
  ~%register_oauth_client

let%server remove_oauth_client =
  let param = Eliom_parameter.int64 "id" in
  Eliom_service.create
    ~name:"remove_oauth_client"
    ~path:Eliom_service.No_path
    ~meth:(Eliom_service.Get param)
    ()

let%client remove_oauth_client =
  ~%remove_oauth_client

let%server register_eliom_client =
  let param =
    ((string "firstname") ** (string "lastname"))
    **
    ((string "password") ** (string "email"))
  in
  Eliom_service.create
    ~name:"register_eliom_client"
    ~path:Eliom_service.No_path
    ~meth:(Eliom_service.Get param)
    ()

let%client register_eliom_client =
  ~%register_eliom_client

let%server remove_eliom_client =
  let param = Eliom_parameter.int64 "id" in
  Eliom_service.create
    ~name:"remove_eliom_client"
    ~path:Eliom_service.No_path
    ~meth:(Eliom_service.Get param)
    ()

let%client remove_eliom_client =
  ~%remove_eliom_client

let%server remove_oauth_token_service =
  let param =
    (Eliom_parameter.string "token") ** (Eliom_parameter.int64 "id")
  in
  Eliom_service.create
    ~name:"remove token"
    ~path:Eliom_service.No_path
    ~meth:(Eliom_service.Get param)
    ()

let%client remove_oauth_token_service =
  ~%remove_oauth_token_service

let%server remove_connect_token_service =
  let param =
    (Eliom_parameter.string "token") ** (Eliom_parameter.int64 "id")
  in
  Eliom_service.create
    ~name:"remove token"
    ~path:Eliom_service.No_path
    ~meth:(Eliom_service.Get param)
    ()

let%client remove_connect_token_service =
  ~%remove_connect_token_service

(** Services **)
(**************************************************************************** *)
