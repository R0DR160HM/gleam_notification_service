import api_notification_manager/redis_client.{type Client}
import api_notification_manager/web
import gleam/http.{Delete, Post}
import wisp.{type Request, type Response}

pub fn handle_request(client: Client, req: Request) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["subscribe"] -> handle_subscription(req, client)
    ["unsubscribe", token] -> handle_unsubscription(req, token, client)
    ["notify", group_id] -> handle_notifications(req, group_id)
    _ -> wisp.not_found()
  }
}

fn handle_subscription(req: Request, client: Client) -> Response {
  case req.method {
    Post -> set_subscription(req)
    _ -> wisp.method_not_allowed([Post])
  }
}

fn handle_unsubscription(
  req: Request,
  token: String,
  client: Client,
) -> Response {
  case req.method {
    Delete -> remove_subscription(token)
    _ -> wisp.method_not_allowed([Delete])
  }
}

fn handle_notifications(req: Request, group_id: String) -> Response {
  case req.method {
    Post -> send_notification(req, group_id)
    _ -> wisp.method_not_allowed([Post])
  }
}

fn set_subscription(req: Request) -> Response {
  // cache.set("as", )
  todo
}

fn remove_subscription(id: String) {
  todo
}

fn send_notification(req, group_id) {
  todo
}
