function fuji_login
  aws sso login --profile fuji-mips-devlab
end

function fuji_ssm
  aws ssm start-session --region ap-southeast-2 --target "i-020ba3f6a16ae5cba" --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"portNumber":["1521"], "localPortNumber":["1521"], "host":["10.101.67.228"]}' --profile fuji-mips-devlab
end

function fuji_vdi
  aws ssm start-session --region ap-southeast-2 --target "i-020ba3f6a16ae5cba" --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["3389"], "localPortNumber":["3389"]}' --profile fuji-mips-devlab
end

function fuji_postgres
  aws ssm start-session --region ap-southeast-2 --target "i-020ba3f6a16ae5cba" --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"portNumber":["5432"], "localPortNumber":["5432"]}' --profile fuji-mips-devlab
end
