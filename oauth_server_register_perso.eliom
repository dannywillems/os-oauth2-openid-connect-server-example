let%server _ =
  (* -------------------------------------------------------- *)
  (* ---------- Register and remove a OAuth2 client --------- *)

  Eliom_registration.Action.register
    ~service:Oauth_server_services_perso.register_oauth_client
    (Oauth_server_handlers_perso.register_oauth_client_handler);

  Eliom_registration.Action.register
    ~service:Oauth_server_services_perso.remove_oauth_client
    (Oauth_server_handlers_perso.remove_oauth_client_handler) ;

  (* ---------- Register and remove a OAuth2 client --------- *)
  (* -------------------------------------------------------- *)

  (* -------------------------------------------------------- *)
  (* ---------- Register and remove a Eliom client --------- *)

  Eliom_registration.Action.register
    ~service:Oauth_server_services_perso.register_eliom_client
    (Oauth_server_handlers_perso.register_eliom_client_handler);

  Eliom_registration.Action.register
    ~service:Oauth_server_services_perso.remove_eliom_client
    (Oauth_server_handlers_perso.remove_eliom_client_handler);

  (* ---------- Register and remove a Eliom client --------- *)
  (* -------------------------------------------------------- *)

  (* --------------------------------------------------------- *)
  (* ---------- Register services for authorization ---------- *)

  Oauth_server_base.App.register
    ~service:
      (Os_oauth2_server.Basic.authorization_service ["oauth2" ;
      "authorization"])
    (Os_oauth2_server.Basic.authorization_handler
      Oauth_server_handlers_perso.authorization_handler);

  Oauth_server_base.App.register
    ~service:
      (Os_connect_server.Basic.authorization_service ["connect" ;
      "authorization"])
    (Os_connect_server.Basic.authorization_handler
      Oauth_server_handlers_perso.connect_authorization_handler);


  (* ---------- Register services for authorization ---------- *)
  (* --------------------------------------------------------- *)

  (* ------------------------------------------------- *)
  (* ---------- Register services for token ---------- *)

  Eliom_registration.Action.register
    ~service:Oauth_server_services_perso.remove_oauth_token_service
    Oauth_server_handlers_perso.remove_oauth_token_handler;

  Eliom_registration.Any.register
    ~service:(Os_oauth2_server.Basic.token_service ["oauth2" ; "token"])
    Os_oauth2_server.Basic.token_handler;

  Eliom_registration.Any.register
    ~service:(Os_connect_server.Basic.token_service ["connect" ; "token"])
    Os_connect_server.Basic.token_handler;

  Oauth_server_base.App.register
    ~service:Oauth_server_services_perso.main_service
    Oauth_server_handlers_perso.main_handler
  (* ---------- Register services for token ---------- *)
  (* ------------------------------------------------- *)
