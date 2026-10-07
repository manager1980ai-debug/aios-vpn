import QtQuick
import QtQuick.Controls

// Never fade two menu pages over one another on desktop or mobile.
StackView {
    id: root
    clip: true
    pushEnter: Transition {}
    pushExit: Transition {}
    popEnter: Transition {}
    popExit: Transition {}
    replaceEnter: Transition {}
    replaceExit: Transition {}
}
