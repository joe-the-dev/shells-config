function fuji --description 'Fuji AWS shortcuts: login | ssm | vdi | pg'
    set -l profile (string join '' -- $FUJI_PROFILE)
    set -l target  (string join '' -- $FUJI_TARGET)
    set -l host    (string join '' -- $FUJI_HOST)

    # Fall back to hardcoded defaults if env vars are not set
    test -z "$profile"; and set profile fuji-mips-devlab
    test -z "$target";  and set target  i-020ba3f6a16ae5cba
    test -z "$host";    and set host    10.101.67.228

    set -l cmd $argv[1]

    # fzf picker when no subcommand given
    if test -z "$cmd"
        if not type -q fzf
            echo "Usage: fuji <login|ssm|vdi|pg>"
            return 1
        end
        set cmd (printf 'login\nssm\nvdi\npg' | fzf --prompt='fuji> ' --height=~6)
        test -z "$cmd"; and return 0
    end

    switch $cmd
        case login
            echo "→ SSO login ($profile)"
            aws sso login --profile $profile

        case ssm
            echo "→ Tunnelling Oracle 1521 → localhost:1521 via $target"
            aws ssm start-session \
                --region ap-southeast-2 \
                --target $target \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters "{\"portNumber\":[\"1521\"],\"localPortNumber\":[\"1521\"],\"host\":[\"$host\"]}" \
                --profile $profile

        case vdi
            echo "→ Tunnelling RDP 3389 → localhost:3389 via $target"
            aws ssm start-session \
                --region ap-southeast-2 \
                --target $target \
                --document-name AWS-StartPortForwardingSession \
                --parameters '{"portNumber":["3389"],"localPortNumber":["3389"]}' \
                --profile $profile

        case pg postgres
            echo "→ Tunnelling Postgres 5432 → localhost:5432 via $target"
            aws ssm start-session \
                --region ap-southeast-2 \
                --target $target \
                --document-name AWS-StartPortForwardingSessionToRemoteHost \
                --parameters "{\"portNumber\":[\"5432\"],\"localPortNumber\":[\"5432\"],\"host\":[\"$host\"]}" \
                --profile $profile

        case '*'
            echo "Unknown subcommand: $cmd"
            echo "Usage: fuji <login|ssm|vdi|pg>"
            return 1
    end
end
