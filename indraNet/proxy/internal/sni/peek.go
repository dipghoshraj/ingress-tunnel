package sni

import "net"

func PeekSNI(conn net.Conn) (string, net.Conn, error) {
	buf := make([]byte, 512)
	n, err := conn.Read(buf)
	if err != nil {
		return "", nil, err
	}
	serverName, err := ExtractHostFromHTTPRequest(buf[:n])
	// serverName, err := ExtractSNIFromRequest(buf[:n]) this is for TLS SNI extraction in current context request is flowing over HTTP
	if err != nil {
		return "", nil, err
	}

	return serverName, &ConnBuffer{buf: buf[:n], conn: conn}, nil

}
