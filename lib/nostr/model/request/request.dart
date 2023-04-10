import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../core/constants.dart';
import 'filter.dart';
import '../../core/utils.dart';

/// {@template nostr_request}
/// NostrRequest is a request to subscribe to a set of events that match a set of filters with a given [subscriptionId].
/// {@endtemplate}
class NostrRequest extends Equatable {
  /// The subscription ID of the request.
  String? subscriptionId;

  /// A list of filters that the request will match.
  List<NostrFilter> filters;

  /// {@macro nostr_request}
  NostrRequest({
    this.subscriptionId,
    required this.filters,
  });

  /// Serialize the request to send it to the remote relays websockets.
  String serialized() {
    String decodedFilters =
        jsonEncode(filters.map((item) => item.toMap()).toList());

    subscriptionId ??= NostrClientUtils.random64HexChars();
    String header = jsonEncode([NostrConstants.request, subscriptionId]);

    final result =
        '${header.substring(0, header.length - 1)},${decodedFilters.substring(1, decodedFilters.length)}';

    return result;
  }

  /// Deserialize a request
  factory NostrRequest.deserialized(input) {
    assert(input.length >= 3, 'Invalid request, must have at least 3 elements');
    assert(
      input[0] == NostrConstants.request,
      'Invalid request, must start with ${NostrConstants.request}',
    );

    final subscriptionId = input[1];

    return NostrRequest(
      subscriptionId: subscriptionId,
      filters: List.generate(
        input.length - 2,
        (index) => NostrFilter.fromJson(
          input[index + 2],
        ),
      ),
    );
  }

  @override
  List<Object?> get props => [subscriptionId, filters];
}
