import gleam/erlang/process.{type Subject}
import radish/client.{type Message}

pub type Client =
  Subject(Message)
