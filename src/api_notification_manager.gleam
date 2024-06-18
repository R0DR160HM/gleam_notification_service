import api_notification_manager/environment
import api_notification_manager/redis_client.{type Client}
import api_notification_manager/router
import gleam/erlang/process
import gleam/io
import mist
import radish

import wisp

const port = 8000

pub fn main() {
  connect_to_redis()
  |> serve()
}

fn serve(client: Client) {
  io.println("Iniciando servidor...")

  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let handle_request = router.handle_request(client, _)

  let assert Ok(_) =
    wisp.mist_handler(handle_request, secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.start_http

  io.println("Servidor iniciado.\n")

  process.sleep_forever()
}

fn connect_to_redis() {
  io.println("Conectando com Redis...")
  let assert Ok(client) =
    radish.start(environment.redis_host, environment.redis_port, [
      radish.Timeout(256),
      radish.Auth(environment.redis_password),
    ])
  io.println("Conectado com sucesso.\n")
  client
}
