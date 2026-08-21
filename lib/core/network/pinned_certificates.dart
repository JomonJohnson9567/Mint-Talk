/// SHA-256 fingerprints (hex, lowercase, no separators) of the DER-encoded
/// leaf certificates this app trusts for its backend host, used to pin the
/// TLS connection in release builds — see [dio_provider.dart].
///
/// To obtain the current fingerprint for a host:
/// ```
/// openssl s_client -connect HOST:443 -servername HOST </dev/null 2>/dev/null \
///   | openssl x509 -outform der \
///   | openssl dgst -sha256
/// ```
///
/// Intentionally left empty — pinning is disabled, by decision, not
/// oversight. The backend is currently hosted on Render, which terminates
/// TLS with a Google Trust Services–issued certificate on an automatic
/// ~90-day renewal cycle (verified live: a fresh leaf cert every renewal,
/// not a fixed one this app controls). Pinning the *leaf* certificate here
/// would break every install at each renewal unless a matching app update
/// shipped in lock-step — an operational risk that isn't worth taking for a
/// certificate this team doesn't own or control the lifecycle of.
///
/// Revisit this once either becomes true:
///   1. The backend moves to infrastructure with a certificate the team
///      provisions/renews itself (predictable rotation, or long-lived), or
///   2. Pinning is redone against the *intermediate/CA* public key (SPKI
///      hash of Google Trust Services' issuing CA) instead of the leaf —
///      far more stable across routine renewals, still blocks a rogue CA.
/// Until then, TLS validation relies on the OS trust store, which the
/// mechanism below is fully wired to use the moment this list is populated.
const List<String> pinnedCertificateSha256Fingerprints = [];
