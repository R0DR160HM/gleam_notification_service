import api_notification_manager/redis_client.{type Client}
import api_notification_manager/token
import api_notification_manager/web
import gleam/bytes_builder
import gleam/hackney
import gleam/http.{Delete, Options, Post}
import gleam/http/request
import gleam/io
import gleam/json
import gleam/result
import radish
import wisp.{type Request, type Response}

pub fn handle_request(client: Client, req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["subscribe"] -> handle_subscription(req, client)
    ["notify"] -> handle_notifications(req, client)
    _ -> wisp.not_found()
  }
}

fn handle_subscription(req: Request, client: Client) -> Response {
  case req.method {
    Post | Options -> set_subscription(req, client)
    _ -> wisp.method_not_allowed([Post])
  }
}

fn handle_notifications(req: Request, client: Client) -> Response {
  io.debug(req)
  io.println("\n\n\n\n")
  case req.method {
    Post -> send_notification(client)
    _ -> wisp.method_not_allowed([Post])
  }
}

fn set_subscription(req: Request, client: Client) -> Response {
  use json <- wisp.require_json(req)

  let response = {
    use tkn <- result.try(token.decode(json))
    let _ = radish.set(client, "waiting", tkn.token, 128)

    json.object([#("message", json.string("Adicionado com sucesso"))])
    |> json.to_string_builder
    |> Ok
  }
  case response {
    Ok(json) -> wisp.json_response(json, 200)
    Error(_) -> wisp.bad_request()
  }
}

fn send_notification(client: Client) -> Response {
  let response = {
    use token <- result.try(radish.get(client, "waiting", 128))

    let body =
      json.object([
        #("to", json.string(token)),
        #(
          "notification",
          json.object([
            #("title", json.string("ATENÇÃO!!!")),
            #(
              "body",
              json.string(
                "Seus ingressos nem um pouco suspeitos estão disponíveis.",
              ),
            ),
          ]),
        ),
      ])
      |> json.to_string
    // |> bytes_builder.from_string_builder

    let assert Ok(req) = request.to("https://fcm.googleapis.com/fcm/send")
    let req =
      req
      |> request.set_header("Content-Type", "application/json")
      |> request.set_header(
        "Authorization",
        "key=AAAAQpMHmrk:APA91bGUJrjRPX_KZFKCmnj1gq_VdZ3hYx0IH3HYS9Wwa-ib5M1kAx0X8qsVG0qm0Ebn5GeenoBD9EcJNGdMd7K4kPYwY58iz8q1JEpJnoUz-uI8LAp60mEDaoBrJWyA5ZUsKFcr_Ceh",
      )
      |> request.set_body(body)
      |> request.set_method(Post)
    io.debug(req)
    io.println("\n\n")
    let assert Ok(resp) = hackney.send(req)
    io.debug(resp)
    json.object([#("message", json.string("Enviado com sucesso"))])
    |> json.to_string_builder
    |> Ok
  }
  case response {
    Ok(json) -> wisp.json_response(json, 200)
    Error(_) -> wisp.bad_request()
  }
}
