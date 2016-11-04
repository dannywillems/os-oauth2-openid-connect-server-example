(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

[%%shared
   open Eliom_content.Html
   open Eliom_content.Html.F
]

let%shared connect_form () =
  D.Form.post_form ~service:Os_services.connect_service
    (fun ((login, password), keepmeloggedin) ->
       [ Form.input
           ~a:[a_placeholder "Your email"]
           ~name:login
           ~input_type:`Email
           Form.string
       ; Form.input
           ~a:[a_placeholder "Your password"]
           ~name:password
           ~input_type:`Password
           Form.string
       ; label [ Form.bool_checkbox_one
                   ~a:[a_checked ()]
                   ~name:keepmeloggedin
                   ()
               ; pcdata "keep me logged in"]
       ; Form.input
           ~a:[a_class ["button"]]
           ~input_type:`Submit
           ~value:"Sign in"
           Form.string
       ]) ()

let%shared sign_up_form () =
  Os_view.generic_email_form ~service:Os_services.sign_up_service ()

let%shared forgot_password_form () =
  Os_view.generic_email_form ~service:Os_services.forgot_password_service ()

let%shared forgotpwd_button ?(close = [%client (fun () -> () : unit -> unit)])
    () =
  let popup_content = [%client fun _ -> Lwt.return @@
    div [ h2 [ pcdata "Recover password" ]
        ; forgot_password_form ()] ]
  in
  let button_name = "Forgot your password?" in
  let button = D.Raw.a ~a:[ a_class ["os-forgot-pwd-link"]
                          ; a_onclick [%client fun _ -> ~%close () ] ]
      [pcdata button_name]
  in
  Os_tools.bind_popup_button
    ~a:[a_class ["os-forgot-pwd"]]
    ~button
    ~popup_content
    ();
  button


let%shared sign_in_button () =
  let popup_content = [%client fun close -> Lwt.return @@
    div [ h2 [ pcdata "Sign in" ]
        ; connect_form ()
        ; forgotpwd_button ~close:(fun () -> Lwt.async close) ()
        ] ]
  in
  let button_name = "Sign In" in
  let button = D.button ~a:[a_class ["button"]] [pcdata button_name] in
  Os_tools.bind_popup_button
    ~a:[a_class ["os-sign-in"]]
    ~button
    ~popup_content
    ();
  button


let%shared sign_up_button () =
  let popup_content = [%client fun _ -> Lwt.return @@
    div [ h2 [ pcdata "Sign up" ]
        ; sign_up_form ()] ]
  in
  let button_name = "Sign Up" in
  let button = D.button ~a:[a_class ["button"]] [pcdata button_name] in
  Os_tools.bind_popup_button
    ~a:[a_class ["os-sign-up"]]
    ~button
    ~popup_content
    ();
  button


let%shared disconnect_button () =
  D.Form.post_form ~service:Os_services.disconnect_service
    (fun _ -> [
         Form.button_no_value
           ~a:[ a_class ["button"] ]
           ~button_type:`Submit
           [Oauth_server_icons.F.signout (); pcdata "Logout"]
       ]) ()


let%shared disconnect_link ?(a = []) () =
  Eliom_content.Html.D.Raw.a
    ~a:(a_onclick [%client fun _ ->
      Lwt.async (fun () ->
        Eliom_client.change_page ~service:Os_services.disconnect_service () ())
    ]
        ::a)
    [ Oauth_server_icons.F.signout (); pcdata "Logout" ]


let%shared connected_user_box ~user =
  let username = Os_view.username user in
  D.div ~a:[a_class ["connected-user-box"]]
    [ Os_view.avatar user
    ; div [ username ]
    ]


let%shared connection_box () =
  let sign_in    = sign_in_button () in
  let sign_up    = sign_up_button () in
  Lwt.return @@ div ~a:[ a_class ["os-connection-box"] ]
    [ sign_in
    ; sign_up
    ]



let%shared user_box ?user () =
  match user with
  | None -> connection_box ()
  | Some user -> Lwt.return (connected_user_box user)