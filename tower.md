## Shopsync over Classic Peripherals radio towers
## Shops
Shops MUST transmit ShopSync data as two packed strings using the "ss" format, transmitted over port 9773:
1. The serialized JSON ShopSync packet
2. The SHA-256 hash of the serialized packet
Example:
string.pack(
  "ss",
  textutils.serializeJSON(packet),
  sha256(textutils.serializeJSON(packet))
)


## Receivers
Receivers MUST listen on port 9773 for ShopSync packets
Receivers MUST accept packed data containing:
1. A serialized JSON ShopSync packet
2. A SHA-256 hash of that packet
The receiver then MUST verify that the SHA-256 hash matches the serialized packet.
Receivers MUST reject the packet if the SHA-256 hash is invalid or missing.
