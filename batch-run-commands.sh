#!/usr/bin/bash

SCRIPT_CWD=$(pwd)

# Define your port forwards: "kubectl port-forward command arguments"
# Ensure your kubectl context is set correctly before running!
declare -a FORWARDS=(
    "minikube --logtostderr -p sbomer mount /tmp/sbomer:/tmp/hostpath-provisioner/default/sbomer-sboms --uid=65532"
    "cd $SCRIPT_CWD && bash ./hack/minikube-expose-db.sh"
    "kubectl port-forward services/sbomer-mequal 8181:80"
    "minikube -p sbomer dashboard"
    "kubectl port-forward -n tekton-pipelines service/tekton-dashboard 9097:9097"
    "cd $SCRIPT_CWD && bash ./hack/run-service-dev.sh -Dquarkus.rest-client.mequal.url=http://dummy -Dquarkus.rest-client.errata.url=http://dummy -Dquarkus.rest-client.atlas-build.url=http://dummy -Dquarkus.rest-client.atlas-release.url=http://dummy"
    "cd $SCRIPT_CWD && export REACT_APP_SBOMER_URL=http://localhost:8080 && bash ./hack/run-ui-dev.sh"
    # Add more commands as needed
)

# For macOS Terminal.app
osascript <<EOF
tell application "Terminal"
    activate
    set first_window to true
    repeat with cmd in {$(printf "\"%s\"," "${FORWARDS[@]}" | sed 's/,$//')}
        if first_window then
            do script cmd
            set first_window to false
        else
            tell application "System Events" to keystroke "t" using command down
            delay 0.5 # Give a moment for the new tab to open
            do script cmd in front window
        end if
        delay 0.5 # Give a moment for the command to start
    end repeat
end tell
EOF