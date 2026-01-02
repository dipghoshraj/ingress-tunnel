package registry

import (
	"github.com/Purple-House/mem-sdk/certengine/pkg"
)

func BuildCreds(dns, name string) error {
	err := pkg.GenerateSelfSignedAgent(
		name,
		[]string{dns},
	)
	pkg.Must(err)
	return nil
}

// func certFingurePrint() error {
// 	permfile := "certs/server.pem" // replace with your file path
// 	certPEM, err := os.ReadFile(permfile)
// 	if err != nil {
// 		return fmt.Errorf("failed to read certificate file: %v", err)
// 	}

// 	block, _ := pem.Decode(certPEM)

// 	if block == nil || block.Type != "CERTIFICATE" {
// 		return fmt.Errorf("failed to decode PEM block containing certificate")
// 	}

// 	cert, err := x509.ParseCertificate(block.Bytes)
// 	if err != nil {
// 		return err
// 	}

// 	sum := sha256.Sum256(cert.Raw)
// 	fingerprint := hex.EncodeToString(sum[:])
// 	log.Printf("Client CERT fingerprint (SHA256): %s", fingerprint)
// 	return nil
// }
