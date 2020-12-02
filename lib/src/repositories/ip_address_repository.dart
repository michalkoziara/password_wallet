import '../data/data_sources/ip_address_provider.dart';

/// An IP address data access repository.
class IpAddressRepository {
  /// Creates IP address data access repository.
  IpAddressRepository({IpAddressProvider ipAddressProvider})
      : _ipAddressProvider = ipAddressProvider ?? IpAddressProvider();

  /// The IP address data access object.
  final IpAddressProvider _ipAddressProvider;

  /// Gets public IP address.
  Future<String> getPublicIpAddress() =>
      _ipAddressProvider.getPublicIpAddress();
}
