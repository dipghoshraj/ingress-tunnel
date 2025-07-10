package sni

import "net"

func PeekSNI(conn net.Conn) (string, net.Conn, error) {
	buf := make([]byte, 512)
	n, err := conn.Read(buf)
	if err != nil {
		return "", nil, err
	}
	serverName, err := ExtractSNIFromRequest(buf[:n])
	if err != nil {
		return "", nil, err
	}

	return serverName, &ConnBuffer{buf: buf[:n], conn: conn}, nil

}
