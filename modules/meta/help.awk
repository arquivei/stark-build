{
    if ($0 ~ /^.PHONY: [a-zA-Z\-_0-9%/]+$/) {
        helpCommand = substr($0, index($0, ":") + 2);
        if (helpMessage) {
            printf "\033[36m%-20s\033[0m %s\n",
                helpCommand, helpMessage;
            helpMessage = "";
        }
    } else if ($0 ~ /^[a-zA-Z\-_0-9.%/]+:/) {
        helpCommand = substr($0, 0, index($0, ":") - 1);
        if (helpMessage) {
            printf "\033[36m%-20s\033[0m %s\n",
                helpCommand, helpMessage;
            helpMessage = "";
        }
    } else if ($0 ~ /^[A-Z0-9_]+[ :?]+=/) {
        helpCommand = substr($0, 0, index($0, " ") - 1);
        if (helpMessage) {
            printf "\033[36m%-20s\033[0m %s\n",
                helpCommand, helpMessage;
            helpMessage = "";
        }
    } else if ($0 ~ /^##/) {
        if (helpMessage) {
            helpMessage = helpMessage"\n                     "substr($$0, 3);
        } else {
            helpMessage = substr($0, 3);
        }
    } else {
        if (helpMessage) {
            print "\n                     "helpMessage"\n"
        }
        helpMessage = "";
    }
}
