# ShopSync over HTTP
## Shops
Shops should send ShopSync packets encoded as JSON to a Receiver as a `POST` request.
The `Content-Type` header MUST be set to `application/json`. Receivers may reject packets with an incorrect header.

# Receivers
Receivers MUST accept ShopSync packets as JSON data as an HTTP `POST` request with `Content-Type` set to `application/json`.
They may reject packets with an incorrect header.
Receivers MUST reject packets if they do not contain a required field for the version.
Receivers MUST NOT reject packets for containing extra fields, such as optional fields added after the receiver is updated to support it.
