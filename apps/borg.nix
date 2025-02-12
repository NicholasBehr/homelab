{
  ## BASE CONFIG
  services.borgbackup.jobs."borgbase" = {
    # create backups
    preHook = ''
      systemctl start paperless-export
    '';

    # select backups
    paths = [
      "/var/lib/paperless/export"
    ];

    # borgbase
    repo = "ssh://iq775d32@iq775d32.repo.borgbase.com/./repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /run/keys/borg_passphrase";
    };
    environment.BORG_RSH = "ssh -i /run/keys/borg_ssh";
    compression = "auto,lzma";
    startAt = "*-*-* 01:11:11"; # every night @ 1:11am
    # startAt = "*:0/30"; # every 30 minutes
    persistentTimer = true;
  };

  ## ENVIRONMENT
  environment.variables = {
    BORG_REPO = "ssh://iq775d32@iq775d32.repo.borgbase.com/./repo";
    BORG_PASSCOMMAND = "cat /run/keys/borg_passphrase";
    BORG_RSH = "ssh -i /run/keys/borg_ssh";
  };
}
