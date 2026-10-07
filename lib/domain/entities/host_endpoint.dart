// Канонический адрес для host key: без регистра и крайних пробелов.
String normalizeHost(String host) => host.trim().toLowerCase();

String endpointKey(String host, int port) => '${normalizeHost(host)}:$port';
