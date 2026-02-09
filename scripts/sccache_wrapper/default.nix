 # This just uses the aws profile for fly.io s3 storage

{ writeFishScriptBin, sccache }: writeFishScriptBin "sccache_wrapper" ''
  # This just uses the aws profile for fly.io s3 storage

  AWS_PROFILE=tigris ${sccache}/bin/sccache $argv[1..-1]
''
