#!/usr/bin/env bash
# connect to a remote host using credentials from file
# supports password (via sshpass) and SSH key auth 

# load credentials file
CRED_FILE="/home/kane/.secrets/cred/nas_ssh_credentials.cred"
if [[ ! -f "$CRED_FILE" ]]; then
    echo "credentials file missing: $CRED_FILE"
    exit 1
fi

source "$CRED_FILE"

# check if user exist and is !null
if [[ -z "$SSH_USER" ]]; then
    echo "SSH_USER is not in credentials file"
    exit 1
fi
# check if host address exist and is !null
if [[ -z "$HOST" ]]; then
    echo "HOST is not in credentials file"
    exit 1
fi

# check host avaliability(modified -W for faster responce)
if ! ping -c 1 -W 1 "$HOST" &> /dev/null; then
    echo "Host $HOST is unreachable"
    exit 1
fi 

# skips connection prompt and does not save host key
OPTS=("-o StrictHostKeyChecking=accept-new" "-o UserKnownHostsFile=/home/kane/.ssh/known_hosts_nas" "-o ConnectTimeout=3")
    
# try key auth 
function key_connection() {
    # check key existance 
    if [[ -n "$KEY" && -f "$KEY" ]]; then
        echo "Key confirmed"
        echo "Using SSH keypair..."
        # connect and verify if key is valid
        # BatchMode skips pasword input after failed key 
        ssh -o BatchMode=yes -i "$KEY" "${OPTS[@]}" "$SSH_USER"@"$HOST"
        # return previous command exit code
        return $?
    else
        echo "Key is missing, switching to basic password..." 
        return 1
    fi
}

# try basic password auth 
function password_connection() {
    # check if sshpass exists
    if ! command -v sshpass > /dev/null 2>&1; then
        echo "sshpass is not available"
        return 1  
    fi
    
    # check if user password exists and is !null
    if [[ -z "$PASS" ]]; then
        echo "Password does not exist or is empty"
        return 1
    fi

    echo "Using basic password auth"
    sshpass -p "$PASS" ssh "${OPTS[@]}" "$SSH_USER@$HOST"
    # return previous command exit code
    return $?
}

# try key auth 
if ! key_connection; then
    echo "Key auth failed, switching to password..." 
    # try basic password auth 
    if ! password_connection; then
        echo "All auth failed!"
        exit 1
    fi  
fi 