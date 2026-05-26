class AddOatsPortalConfig < ActiveRecord::Migration[5.0]
  def up
    portal = Portal.find_or_create_by(slug: 'oats')
    portal.update(
      name: 'OATS',
      saml_idp_entity_id: 'https://eippl.oatspayroll.com/sp',
      saml_idp_sso_url: 'https://eippl.oatspayroll.com/SSO/SAML/AssertionConsumerService.aspx',
      saml_idp_cert: "-----BEGIN CERTIFICATE-----\nMIIC/jCCAeagAwIBAgIQCGehfcnv6r5My/fnrbfDejANBgkqhkiG9w0BAQsFADAV\nMRMwEQYDVQQDEwp3d3cuc3AuY29tMB4XDTEzMTEyMjA4MjMyMVoXDTQ5MTIzMTE0\nMDAwMFowFTETMBEGA1UEAxMKd3d3LnNwLmNvbTCCASIwDQYJKoZIhvcNAQEBBQAD\nggEPADCCAQoCggEBAMPm/ew9jaGWpQS1C7KtpvgzV4nSOIFPgRt/nlRYR+pUWdDE\nfSKmyjK28nkQ1KKujRJTnvnmZydmUrmEFpVv+giBiUkvCJY3PxZ/EDSsF3R/OzWh\nkUv5nfAXPnqkX9x22b6+vUof6WiLGyAW6lOYMCVADjTSl9pSaUtIaANdx9maERcT\n9eQbGSnjim0WurFRYs9ZE8ttErrMH9+Su4246YDqOPAkz6La4cHHMPQdcFQT5p/c\nuXBfU1vl1tWdBEgAY3xHYZE8u5TTJ/vp9UxyU1MwfeO2g9VDRcokLQHrj6wFxtvuf\nA+WtUKYJGUu2p/qSuaw7eS6UFjUn49aVqg9OacCAwEAAaNKMEgwRgYDVR0BBD8w\nPYAQl/S0ibdvfdFkJ9T9oIPluKEXMBUxEzARBgNVBAMTCnd3dy5zcC5jb22CEAhnoX3J\n7+q+TMv35623w3owDQYJKoZIhvcNAQELBQADggEBAAHlmVoAZUt6paeFvtQbc/iaJe/F\nhd+JG1U0jyjlFDcCn8erLihEbhb3mFBBMF25oO67gfA1JJXZrmHry3NlOZuovqRqm8v7\nwg8n0nQa1HUWkUC2TBgfg1HE8/2rmSF2PngiEi18VOxRDxx0WXMNZX6JebJ1kCOCpT/x\n7aupS7T1GrIPmDLxjnC9Bet7pRynfomjP/6iU21/xOIF6xB9Yf1a/kQbYdAVt2haYKIf\nvaF3xsq1X5tCXc9ijhBMgyaoqA+bQJD/l3S8+yCmMxEYZjAVLEkyGlU4Uwo01cKEYbXI\nG/YVq+4CaIRxIfMvV+j8gzTLHTXI+pHEMfMhyYa0pzM=\n-----END CERTIFICATE-----",
      active: true)
  end

  def down
    Portal.find_by(slug: 'oats')&.destroy
  end
end
