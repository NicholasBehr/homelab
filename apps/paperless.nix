{
  ## BASE CONFIG
  services.paperless = {
    enable = true;

    settings = {
      # Paths and folders
      PAPERLESS_FILENAME_FORMAT =
        "{{ created_year }}/{{ created }}_"
        + "{{ title"
        + "|lower"
        + "|replace('ä', 'ae')|replace('ö', 'oe')|replace('ü', 'ue')|replace('ß', 'ss')"
        + "|replace(' ', '_') }}";

      # Hosting & Security
      PAPERLESS_URL = "https://paperless.nicholasbehr.ch";

      # OCR settings
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_MODE = "skip";
      PAPERLESS_OCR_CLEAN = "clean-final";

      # Software tweaks
      PAPERLESS_TIME_ZONE = "CET";
      PAPERLESS_TASK_WORKERS = 2;
      PAPERLESS_THREADS_PER_WORKER = 2;

      # Document Consumption
      PAPERLESS_CONSUMER_DELETE_DUPLICATES = "true";
      PAPERLESS_OCR_USER_ARGS = {
        invalidate_digital_signatures = true;
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
    };
  };

  ## EXPORT BACKUP
  # https://docs.paperless-ngx.com/administration/#exporter
  systemd.services."paperless-export" = {
    script = ''
      mkdir -p /var/lib/paperless/export
      /var/lib/paperless/paperless-manage document_exporter /var/lib/paperless/export -c -d -f --no-progress-bar
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "paperless";
    };
  };
}
