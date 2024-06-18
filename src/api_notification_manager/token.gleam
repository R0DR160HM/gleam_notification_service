import gleam/dynamic.{type Dynamic}

pub type Token {
  Token(token: String)
}

pub fn decode(json: Dynamic) -> Result(Token, dynamic.DecodeErrors) {
  let decoder = dynamic.decode1(Token, dynamic.field("token", dynamic.string))
  decoder(json)
}
