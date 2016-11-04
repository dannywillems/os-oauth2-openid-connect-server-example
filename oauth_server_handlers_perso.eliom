[%%shared
    open Eliom_content
    open Html.D
    module B = Bootstrap
]

(* ------------------------------------------------- *)
(* Normal HTML generation for a given list of client *)

(* -------------------------------------------------------------------------- *)
(* Eliom *)
let%client update_eliom () =
  let firstname =
    Js.to_string (Jsoo_lib.get_input_by_id "eliom-firstname")##.value
  in
  let lastname =
    Js.to_string (Jsoo_lib.get_input_by_id "eliom-lastname")##.value
  in
  let email =
    Js.to_string (Jsoo_lib.get_input_by_id "eliom-email")##.value
  in
  let pwd =
    Js.to_string (Jsoo_lib.get_input_by_id "eliom-pwd")##.value
  in
  Lwt.ignore_result
    (Eliom_client.call_service
      ~service:Oauth_server_services_perso.register_eliom_client
      ((firstname, lastname), (email, pwd))
      ()
    )

let%client remove_eliom_client id =
  Lwt.ignore_result
  (
    ignore (Eliom_client.call_service
      ~service:Oauth_server_services_perso.remove_eliom_client
      id
      ()
    ) ;
    Os_lib.reload ()
  )

(**
 * Returns a list of div containing the informations about clients. The
 * parameter is the clients list coming from the database.
 *)
let eliom_client_to_html c =
  let firstname = Os_user.firstname_of_user c in
  let lastname  = Os_user.lastname_of_user c in
  let userid    = Os_user.userid_of_user c in
  let%lwt email = Os_user.email_of_user c in
  Lwt.return (
    div ~a:[a_class ["text-left" ; "padding-top" ]]
    [
      p [b [pcdata "Id: "] ; pcdata (Int64.to_string userid)] ;
      p [b [pcdata "Firstname: "] ; pcdata firstname] ;
      p [b [pcdata "Lastname: "] ; pcdata lastname] ;
      p [b [pcdata "Email: "] ; pcdata email] ;
      div ~a:[a_class ["text-center"]]
      [
        button
          ~a:[
            a_onclick [%client (fun _ -> remove_eliom_client ~%userid)] ;
            a_button_type `Submit ;
            a_class ["btn" ; B.Button.to_string B.Button.Danger]
          ]
          [pcdata "Remove Eliom client"]
      ]
    ]
  )

(**
 * Get the clients list from the database, calls eliom_client_to_html to build
 * the list of div containing all informations about clients and wraps the list
 * in a div with a title in h2
 *)
let eliom_clients_list_to_html () =
  let%lwt l = Os_user.get_users () in
  let%lwt html = Lwt_list.map_s (fun u -> (eliom_client_to_html u)) l in
  Lwt.return (
    [
      div
      ~a:[a_class ["text-center"]]
      ([h2 ~a:[a_class ["text-center"]] [pcdata "Eliom clients list"]] @ html)
    ]
  )

(** Create the form to create a new eliom client *)
let form_eliom =
  B.form
    ~children:[
      B.form_group `Text "eliom-firstname" "Firstname: " ;
      B.form_group `Text "eliom-lastname" "Lastname: " ;
      B.form_group `Email "eliom-email" "Email: " ;
      B.form_group `Password "eliom-pwd" "Password: " ;
      button
        ~a:[
          a_onclick ([%client (fun _ -> update_eliom ())]);
          a_id "eliom-submit" ;
          a_class (["btn " ^ (B.Button.to_string B.Button.Default)]) ;
          a_button_type `Submit
        ]
        [pcdata "Submit"]
    ]
    ()
(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
(* OAuth *)
let%client update_oauth () =
  let app_name = Js.to_string ((Jsoo_lib.get_input_by_id
  "oauth-app-name")##.value) in
  let desc = Js.to_string ((Jsoo_lib.get_input_by_id "oauth-desc")##.value) in
  let redirect_uri = Js.to_string ((Jsoo_lib.get_input_by_id
  "oauth-redirect-uri")##.value) in
  Lwt.ignore_result
    (Eliom_client.call_service
      ~service:Oauth_server_services_perso.register_oauth_client
      ((app_name, desc), redirect_uri)
      ()
    )

let%client remove_oauth_client id =
  Lwt.ignore_result
  (
    Eliom_client.call_service
      ~service:Oauth_server_services_perso.remove_oauth_client
      id
      () ;
    Os_lib.reload ()
  )

(**
 * Returns a list of div containing the informations about clients. The
 * parameter is the clients list coming from the database.
 *)
let oauth_client_to_html c =
  let info = Os_oauth2_server.client_of_registered_client c in
  let credentials = Os_oauth2_server.credentials_of_registered_client c in
  let id = Os_oauth2_server.id_of_registered_client c in
  div ~a:[a_class ["text-left" ; "padding-top" ]]
  [
    p [b [pcdata "Id: "] ; pcdata (Int64.to_string id)] ;
    p [b [pcdata "App: "] ; pcdata (Os_oauth2_server.application_name_of_client
    info)] ;
    p [b [pcdata "Description: "] ; pcdata (Os_oauth2_server.description_of_client
    info)] ;
    p [b [pcdata "Redirect_uri: "] ; pcdata (Os_oauth2_server.redirect_uri_of_client
    info)] ;
    p [b [pcdata "Client ID: "] ; pcdata
    (Os_oauth2_shared.client_id_of_client_credentials credentials)] ;
    p [b [pcdata "Client secret: "] ; pcdata
    (Os_oauth2_shared.client_secret_of_client_credentials credentials)] ;
    div ~a:[a_class ["text-center"]]
    [
      button
        ~a:[
          a_onclick [%client (fun _ -> remove_oauth_client ~%id)] ;
          a_button_type `Submit ;
          a_class ["btn" ; B.Button.to_string B.Button.Danger]
        ]
        [pcdata "Remove OAuth2 client"]
    ]
  ]

(**
 * Get the clients list from the database, calls oauth_client_to_html to build
 * the list of div containing all informations about clients and wraps the list
 * in a div with a title in h2
 *)
let oauth_clients_list_to_html () =
  let%lwt l = Os_oauth2_server.list_clients () in
  let html = List.map (fun c -> (oauth_client_to_html c)) l in
  Lwt.return (
    [
      div
      ~a:[a_class ["text-center"]]
      ([h2 ~a:[a_class ["text-center"]] [pcdata "OAuth2 clients list"]] @ html)
    ]
  )

(** Create the form to create a new OAuth client *)
let form_oauth =
  B.form
    ~children:[
      B.form_group `Text "oauth-app-name" "Application name: " ;
      B.form_group `Text "oauth-desc" "Description: " ;
      B.form_group `Url "oauth-redirect-uri" "Redirect uri: " ;
      button
        ~a:[
          a_onclick ([%client (fun _ -> update_oauth ())]);
          a_id "oauth-submit" ;
          a_class (["btn " ^ (B.Button.to_string B.Button.Default)]) ;
          a_button_type `Submit
        ]
        [pcdata "Submit"] ;
    ]
    ()
(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
let%client remove_token token id =
  Lwt.ignore_result
  (
    Eliom_client.call_service
      ~service:Oauth_server_services_perso.remove_oauth_token_service
      (token, id)
      () ;
    Os_lib.reload ()
  )

let token_to_html token =
  let id_client  = Os_oauth2_server.Basic.id_client_of_saved_token token in
  let userid     = Os_oauth2_server.Basic.userid_of_saved_token token in
  let value      = Os_oauth2_server.Basic.value_of_saved_token token in
  let token_type = Os_oauth2_server.Basic.token_type_of_saved_token token in
  let scope      = Os_oauth2_server.Basic.scope_of_saved_token token in
  div ~a:[a_class ["text-left" ; "padding-top"]]
  [
    p
    [
      b [pcdata "Id of client in table: "] ;
      pcdata (string_of_int (Int64.to_int id_client))
    ] ;
    p
    [
      b [pcdata "Userid: "] ;
      pcdata (string_of_int (Int64.to_int userid))
    ] ;
    p [b [pcdata "Token: "] ; pcdata value] ;
    p [b [pcdata "Token_type: "] ; pcdata token_type] ;
    p [b [pcdata "Scope: "] ; pcdata
    (String.concat " " (Os_oauth2_server.Basic.scope_list_to_str_list scope))] ;
    div ~a:[a_class ["text-center"]]
    [
      button
        ~a:[
          a_onclick ([%client (fun _ -> remove_token ~%value ~%id_client)]);
          a_id "remove-token" ;
          a_class (["btn" ; B.Button.to_string B.Button.Danger]) ;
          a_button_type `Submit
        ]
        [pcdata "Remove token"]
    ]
  ]

let oauth_token_list_to_html () =
  let oauth_token_list = Os_oauth2_server.Basic.list_tokens () in
  let html_list = List.map (fun u -> token_to_html u) oauth_token_list in
  Lwt.return (
  [
    div
      ~a:[a_class ["text-center"]]
      html_list
  ])
(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
let%client remove_connect_token token id =
  Lwt.ignore_result
  (
    Eliom_client.call_service
      ~service:Oauth_server_services_perso.remove_connect_token_service
      (token, id)
      () ;
    Os_lib.reload ()
  )

let connect_token_to_html token =
  let id_client  = Os_connect_server.Basic.id_client_of_saved_token token in
  let userid     = Os_connect_server.Basic.userid_of_saved_token token in
  let value      = Os_connect_server.Basic.value_of_saved_token token in
  let token_type = Os_connect_server.Basic.token_type_of_saved_token token in
  let scope      = Os_connect_server.Basic.scope_of_saved_token token in
  let id_token   = Os_connect_server.Basic_ID_token.id_token_of_saved_token
  token in
  let header_token = Jwt.header_of_t id_token in
  let payload_token = Jwt.payload_of_t id_token in
  div ~a:[a_class ["text-left" ; "padding-top"]]
  [
    p
    [
      b [pcdata "Id of client in table: "] ;
      pcdata (string_of_int (Int64.to_int id_client))
    ] ;
    p
    [
      b [pcdata "Userid: "] ;
      pcdata (string_of_int (Int64.to_int userid))
    ] ;
    p [b [pcdata "Token: "] ; pcdata value] ;
    p [b [pcdata "Token_type: "] ; pcdata token_type] ;
    p [b [pcdata "Scope: "] ; pcdata
    (String.concat " " (Os_connect_server.Basic.scope_list_to_str_list scope))] ;
    p [b [pcdata "Header - Algo "] ; pcdata (Jwt.string_of_algorithm
    (Jwt.algorithm_of_header header_token))] ;
    p [b [pcdata "Header - Typ "] ; pcdata (Jwt.typ_of_header header_token)] ;
    p [b [pcdata "Payload - iss "] ; pcdata (Jwt.find_claim Jwt.iss
    payload_token)] ;
    p [b [pcdata "Payload - sub "] ; pcdata (Jwt.find_claim Jwt.sub
    payload_token)] ;
    p [b [pcdata "Payload - iat "] ; pcdata (
    CalendarLib.Printer.Calendar.to_string
      (
        CalendarLib.Calendar.from_unixtm
          (Unix.gmtime (float_of_string (Jwt.find_claim Jwt.iat payload_token)))
      )
    )] ;
    p [b [pcdata "Payload - exp "] ; pcdata (
    CalendarLib.Printer.Calendar.to_string
      (
        CalendarLib.Calendar.from_unixtm
          (Unix.gmtime (float_of_string (Jwt.find_claim Jwt.exp payload_token)))
      )
    )] ;
    p [b [pcdata "Payload - aud "] ; pcdata (Jwt.find_claim Jwt.aud
    payload_token)] ;
    div ~a:[a_class ["text-center"]]
    [
      button
        ~a:[
          a_onclick ([%client (fun _ -> remove_connect_token ~%value ~%id_client)]);
          a_id "remove-token" ;
          a_class (["btn" ; B.Button.to_string B.Button.Danger]) ;
          a_button_type `Submit
        ]
        [pcdata "Remove token"]
    ]
  ]

let connect_token_list_to_html () =
  let connect_token_list = Os_connect_server.Basic.list_tokens () in
  let html_list = List.map (fun u -> connect_token_to_html u) connect_token_list in
  Lwt.return (
  [
    div
      ~a:[a_class ["text-center"]]
      html_list
  ])

(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
let content_oauth =
  B.col
    ~css:["text-center"]
    ~lg:6
    ~children:
    [
      B.h2 "OAuth server: add a new client" ;
      form_oauth
    ]
    ()

let content_eliom =
  B.col
    ~css:["text-center"]
    ~lg:6
    ~children:
    [
      B.h2 "Eliom Server: add a new client" ;
      form_eliom
    ]
    ()

let content_oauth_list clients =
  B.col ~css:["text-center"] ~lg:4 ~children:clients ()

let content_eliom_list clients =
  B.col ~css:["text-center"] ~lg:4 ~children:clients ()

let content_token typ token_list =
  B.col
    ~css:["text-center"]
    ~lg:4
    ~children:([
      B.h2 (typ ^ " Tokens list") ;
    ] @ token_list) ()

let content oauth_clients_list
  eliom_clients_list
  oauth_token_list
  connect_token_list
  =
  B.container
    ~children:[
      B.row
        ~children:[
          content_oauth ;
          content_eliom
        ]
        () ;
      B.row
        ~children:[
          content_oauth_list oauth_clients_list ;
          content_eliom_list eliom_clients_list ;
          content_token "OAuth2" oauth_token_list ;
          content_token "Connect" connect_token_list
        ]
        ()
    ]
    ()
(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
let main_handler =
  (fun () () ->
    let%lwt oauth_clients_list  = oauth_clients_list_to_html ()  in
    let%lwt eliom_clients_list  = eliom_clients_list_to_html ()  in
    let%lwt oauth_token_list    = oauth_token_list_to_html ()    in
    let%lwt connect_token_list  = connect_token_list_to_html ()  in
    Lwt.return
      (Eliom_tools.F.html
         ~title:"oauth2_server"
         ~css:[["css";"bootstrap.min.css"]; ["css";"oauth_server.css"]]
         Html.F.(body [content oauth_clients_list eliom_clients_list
         oauth_token_list connect_token_list])
      )
  )

(* Service to register a new client *)
let register_oauth_client_handler =
  (fun ((application_name, description), redirect_uri) () ->
    ignore (
      Os_oauth2_server.new_client
        ~application_name
        ~description
        ~redirect_uri
    );
    Lwt.return ()
  )

let remove_oauth_client_handler =
  (fun id () ->
    ignore (Os_oauth2_server.remove_client_by_id id);
    Lwt.return ()
  )

let register_eliom_client_handler =
  (fun ((firstname, lastname), (email, password)) () ->
    ignore (Os_user.create ~password ~firstname ~lastname email);
    Lwt.return ()
  )

let remove_eliom_client_handler =
  (fun id () ->
    (*Os_db.User.remove_user_by_userid id ;*)
    Lwt.return ()
  )
(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
(* Handler for the authorization service *)
let authorization_handler : Os_oauth2_server.Basic.authorization_handler =
  fun ~state ~client_id ~redirect_uri ~scope ->
  let scope_str_list                                =
    (Os_oauth2_server.Basic.scope_list_to_str_list scope)
  in
  let scope_str                                     =
    String.concat " " scope_str_list
  in
  let%lwt client                                    =
    Os_oauth2_server.registered_client_of_client_id client_id
  in
  let info                                          =
    Os_oauth2_server.client_of_registered_client client
  in
  let application_name                              =
    Os_oauth2_server.application_name_of_client info
  in
  let description                                   =
    Os_oauth2_server.description_of_client info
  in
  let scope_list_to_html                            =
    ul
      ~a:[a_class ["list-group"]]
      (List.map
        (fun x -> li ~a:[a_class ["list-group-item"]] [pcdata x])
        scope_str_list
      )
  in

  (** Title + List with scope + information about the OAuth2.0 client *)
  let content_scope app_name scope_list description =
    [
      h1 ~a:[a_class ["text-danger"]] [pcdata "Add a connection box!"] ;
      p [b [pcdata application_name] ; pcdata " would like to get access to:"] ;
      scope_list_to_html ;
      p [b [pcdata "Description: "] ; pcdata description]
    ]
  in

  (** Buttons authorize and decline *)
  let buttons =
    B.row ~children:[
      B.col
        ~lg:6
        ~css:["text-center"]
        ~children:[
          button
            ~a:[
              a_class ["btn" ; B.Button.to_string B.Button.Success] ;
              a_button_type `Submit ;
              a_onclick
                ([%client
                  fun _ ->
                    ignore
                    (~%Os_oauth2_server.Basic.rpc_resource_owner_authorize
                      (~%state, ~%client_id)
                    );
                ]) ;
              a_id "authorize"
            ]
            [pcdata "Authorize"]
          ]
        ();
      B.col
        ~lg:6
        ~css:["text-center"]
        ~children:[
          button
            ~a:[
              a_class ["btn" ; B.Button.to_string B.Button.Danger] ;
              a_button_type `Submit ;
              a_onclick
                ([%client
                  fun _ ->
                    ignore
                    (~%Os_oauth2_server.Basic.rpc_resource_owner_decline
                      (~%state, ~%redirect_uri)
                    );
                ]) ;
              a_id "decline"
            ]
            [pcdata "Decline"]
          ]
        ()
    ]
    ()
  in

  let content_authorization () =
    B.col
      ~lg:6
      ~offset:3
      ~css:["text-center"]
      ~children:([
        h2 ~a:[a_class ["text-center"]] [pcdata "Authorization code"]]
        @ (content_scope application_name scope description) @ [buttons])
      ()
  in

  Os_oauth2_server.Basic.set_userid_of_request_info_code
    client_id
    state
    (Int64.of_int 10);

  Lwt.return
    (Eliom_tools.D.html
       ~title:"oauth2_server"
       ~css:[["css";"bootstrap.min.css"]; ["css";"oauth_server.css"]]
       Html.D.(body [
        B.container
          ~children:[
          B.row
            ~children:[content_authorization ()]
            ()
          ]
        ()
      ]
    )
  )
(* -------------------------------------------------------------------------- *)

(* -------------------------------------------------------------------------- *)
(* Handler for the authorization service *)
let connect_authorization_handler : Os_connect_server.Basic.authorization_handler =
  fun ~state ~client_id ~redirect_uri ~scope ->
  let scope_str_list                                =
    (Os_connect_server.Basic.scope_list_to_str_list scope)
  in
  let scope_str                                     =
    String.concat " " scope_str_list
  in
  let%lwt client                                    =
    Os_oauth2_server.registered_client_of_client_id client_id
  in
  let info                                          =
    Os_oauth2_server.client_of_registered_client client
  in
  let application_name                              =
    Os_oauth2_server.application_name_of_client info
  in
  let description                                   =
    Os_oauth2_server.description_of_client info
  in
  let scope_list_to_html                            =
    ul
      ~a:[a_class ["list-group"]]
      (List.map
        (fun x -> li ~a:[a_class ["list-group-item"]] [pcdata x])
        scope_str_list
      )
  in

  (** Title + List with scope + information about the OAuth2.0 client *)
  let content_scope app_name scope_list description =
    [
      h1 ~a:[a_class ["text-danger"]] [pcdata "Add a connection box!"] ;
      p [b [pcdata application_name] ; pcdata " would like to get access to:"] ;
      scope_list_to_html ;
      p [b [pcdata "Description: "] ; pcdata description]
    ]
  in

  (** Buttons authorize and decline *)
  let buttons =
    B.row ~children:[
      B.col
        ~lg:6
        ~css:["text-center"]
        ~children:[
          button
            ~a:[
              a_class ["btn" ; B.Button.to_string B.Button.Success] ;
              a_button_type `Submit ;
              a_onclick
                ([%client
                  fun _ ->
                    ignore
                    (~%Os_connect_server.Basic.rpc_resource_owner_authorize
                      (~%state, ~%client_id)
                    );
                ]) ;
              a_id "authorize"
            ]
            [pcdata "Authorize"]
          ]
        ();
      B.col
        ~lg:6
        ~css:["text-center"]
        ~children:[
          button
            ~a:[
              a_class ["btn" ; B.Button.to_string B.Button.Danger] ;
              a_button_type `Submit ;
              a_onclick
                ([%client
                  fun _ ->
                    ignore
                    (~%Os_connect_server.Basic.rpc_resource_owner_decline
                      (~%state, ~%redirect_uri)
                    );
                ]) ;
              a_id "decline"
            ]
            [pcdata "Decline"]
          ]
        ()
    ]
    ()
  in

  let content_authorization () =
    B.col
      ~lg:6
      ~offset:3
      ~css:["text-center"]
      ~children:([
        h2 ~a:[a_class ["text-center"]] [pcdata "Authorization code"]]
        @ (content_scope application_name scope description) @ [buttons])
      ()
  in

  Os_connect_server.Basic.set_userid_of_request_info_code
    client_id
    state
    (Int64.of_int 10);

  Lwt.return
    (Eliom_tools.D.html
       ~title:"oauth2_server"
       ~css:[["css";"bootstrap.min.css"]; ["css";"oauth_server.css"]]
       Html.D.(body [
        B.container
          ~children:[
          B.row
            ~children:[content_authorization ()]
            ()
          ]
        ()
      ]
    )
  )
(* -------------------------------------------------------------------------- *)


(* -------------------------------------------------------------------------- *)
(* ---------- Action handler ---------- *)

let remove_oauth_token_handler =
  fun (value, id_client) () ->
    let saved_token =
      Os_oauth2_server.Basic.saved_token_of_id_client_and_value id_client value
    in
    Os_oauth2_server.Basic.remove_saved_token saved_token;
    Lwt.return ()

let remove_connect_token_handler =
  fun (value, id_client) () ->
    let saved_token =
      Os_connect_server.Basic.saved_token_of_id_client_and_value id_client value
    in
    Os_connect_server.Basic.remove_saved_token saved_token;
    Lwt.return ()

(* ---------- Action handler ---------- *)
(* -------------------------------------------------------------------------- *)
