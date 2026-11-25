/// Which phone this app instance plays in the two-phone demo, chosen with
/// the `rol` query parameter of the page URL.
enum DemoRole {
  /// Single instance: the sender and the internal test accounts.
  standalone,

  /// The sender phone: shares with the remote [remoteGuestId] account.
  sender,

  /// The recipient phone: shows what others shared with [remoteGuestId].
  recipient;

  /// Account of the recipient phone; fixed so the sender can address it.
  static const remoteGuestId = 'sofia-demo';

  /// `rol=emisor` and `rol=sofia`; anything else is the single instance.
  static DemoRole parse(String? value) => switch (value) {
    'emisor' => sender,
    'sofia' => recipient,
    _ => standalone,
  };
}
