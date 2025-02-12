{
  ## BASE CONFIG
  services.nginx = {
    enable = true;

    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedBrotliSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
  };

  ## LET'S ENCRYPT
  security.acme = {
    acceptTerms = true;
    defaults.email = "foo@bar.com";
  };

  ## HOMEPAGE
  services.nginx.virtualHosts = {
    "nicholasbehr.ch" = {
      enableACME = true;
      forceSSL = true;
      http2 = true;
      root = "/var/www/homepage/";
    };
    "www.nicholasbehr.ch" = {
      globalRedirect = "nicholasbehr.ch";
    };
  };

  ## PAPERLESS
  services.nginx.virtualHosts = {
    "paperless.nicholasbehr.ch" = {
      enableACME = true;
      forceSSL = true;
      http2 = true;
      locations."/" = {
        proxyPass = "http://localhost:28981";
        proxyWebsockets = true;
      };
    };
    "www.paperless.nicholasbehr.ch" = {
      globalRedirect = "paperless.nicholasbehr.ch";
    };
  };
}
