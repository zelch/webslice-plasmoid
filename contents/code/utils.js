/**
 * Transform a model into a string representing the model as an array
 */
function stringifyModel(model) {
    var newArray = []
    for (var i = 0; i < model.count; i++) {
        var obj = model.get(i)
        newArray.push(obj.url)
    }
    return JSON.stringify(newArray)
}

/**
 * Get an array from a string representing that array
 */
function getURLsObjectArray() {
    var cfgURLS = plasmoid.configuration.urlsModel
    if (!cfgURLS) {
        return []
    }
    return JSON.parse(cfgURLS)
}

function loadString(Status) {
    switch (Status) {
	case WebEngineView.LoadStartedStatus:
	    return "Started"
	case WebEngineView.LoadStoppedStatus:
	    return "Stopped"
	case WebEngineView.LoadSucceededStatus:
	    return "Succeeded"
	case WebEngineView.LoadFailedStatus:
	    return "Failed"
	default:
	    return "Unknown"
    }
}

function navTypeString(navType) {
    switch (navType) {
	case WebEngineNavigationRequest.LinkClickedNavigation:
	    return "Link Clicked"
	case WebEngineNavigationRequest.TypedNavigation:
	    return "Typed"
	case WebEngineNavigationRequest.FormSubmittedNavigation:
	    return "Form Submitted"
	case WebEngineNavigationRequest.BackForwardNavigation:
	    return "Back / Forward"
	case WebEngineNavigationRequest.ReloadNavigation:
	    return "Reload"
	case WebEngineNavigationRequest.RedirectNavigation:
	    return "Redirect"
	case WebEngineNavigationRequest.OtherNavigation:
	    return "Other"
	default:
	    return "Unknown"
    }
}

function debug(entry) {
    if (cfg_debug) {
	console.log(entry)
    }
}
