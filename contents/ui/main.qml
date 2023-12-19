/***************************************************************************
 *   Copyright 2015 by Cqoicebordel <cqoicebordel@gmail.com>               *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.15
import QtWebEngine 1.11
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQml 2.15

import "../code/utils.js" as ConfigUtils



Item {
    id: main

    property string websliceUrl: Plasmoid.configuration.websliceUrl
    property double zoomFactorCfg: Plasmoid.configuration.zoomFactor
    property bool enableReload: Plasmoid.configuration.enableReload
    property int reloadIntervalSec: Plasmoid.configuration.reloadIntervalSec
    property bool displaySiteBehaviour: Plasmoid.configuration.displaySiteBehaviour
    property bool buttonBehaviour: Plasmoid.configuration.buttonBehaviour
    property int webPopupWidth: Plasmoid.configuration.webPopupWidth
    property int webPopupHeight: Plasmoid.configuration.webPopupHeight
    property string webPopupIcon: Plasmoid.configuration.webPopupIcon
    property bool showPinButton: Plasmoid.configuration.showPinButton
    property bool pinButtonAlignmentLeft: Plasmoid.configuration.pinButtonAlignmentLeft
    property bool reloadAnimation: Plasmoid.configuration.reloadAnimation
    property bool backgroundColorWhite: Plasmoid.configuration.backgroundColorWhite
    property bool backgroundColorTransparent: Plasmoid.configuration.backgroundColorTransparent
    property bool backgroundColorTheme: Plasmoid.configuration.backgroundColorTheme
    property bool backgroundColorCustom: Plasmoid.configuration.backgroundColorCustom
    property string customBackgroundColor: Plasmoid.configuration.customBackgroundColor

    property bool enableScrollTo: Plasmoid.configuration.enableScrollTo
    property int scrollToX: Plasmoid.configuration.scrollToX
    property int scrollToY: Plasmoid.configuration.scrollToY
    property bool enableJSID: Plasmoid.configuration.enableJSID
    property string jsSelector: Plasmoid.configuration.jsSelector
    property bool enableCustomUA: Plasmoid.configuration.enableCustomUA
    property string customUA: Plasmoid.configuration.customUA
    property bool enableReloadOnActivate: Plasmoid.configuration.enableReloadOnActivate
    property bool bypassSSLErrors: Plasmoid.configuration.bypassSSLErrors
    property bool scrollbarsShow: Plasmoid.configuration.scrollbarsShow
    property bool scrollbarsOverflow: Plasmoid.configuration.scrollbarsOverflow
    property bool scrollbarsWebkit: Plasmoid.configuration.scrollbarsWebkit
    property bool enableJS: Plasmoid.configuration.enableJS
    property string js: Plasmoid.configuration.js

    property string urlsModel: Plasmoid.configuration.urlsModel

    property string keysSeqBack: Plasmoid.configuration.keysSeqBack
    property string keysSeqForward: Plasmoid.configuration.keysSeqForward
    property string keysSeqReload: Plasmoid.configuration.keysSeqReload
    property string keysSeqStop: Plasmoid.configuration.keysSeqStop
    property bool fillWidthAndHeight: Plasmoid.configuration.fillWidthAndHeight
    property bool notOffTheRecord: Plasmoid.configuration.notOffTheRecord
    property string profileName: Plasmoid.configuration.profileName

    signal handleSettingsUpdated();

    Plasmoid.preferredRepresentation: (displaySiteBehaviour)? Plasmoid.fullRepresentation : Plasmoid.compactRepresentation

    Plasmoid.fullRepresentation: webview

    Plasmoid.icon: webPopupIcon

    onUrlsModelChanged:{ console.log("onUrlsModelChanged"); loadURLs(); }

    onWebPopupHeightChanged:{ console.log("onWebPopupHeightChanged"); main.handleSettingsUpdated(); }

    onWebPopupWidthChanged:{  console.log("onWebPopupWidthChanged"); main.handleSettingsUpdated(); }

    onZoomFactorCfgChanged:{  console.log("onZoomFactorCfgChanged"); main.handleSettingsUpdated(); }

    onNotOffTheRecordChanged:{
        console.log("test");
        //console.debug(Plasmoid.fullRepresentation);
        //Plasmoid.fullRepresentation = null;
        //webviewID.destroy();
        //var component = Qt.createComponent("WebviewWebslice.qml");
        //webview = component.createObject(webview, {id: "webviewID"});
        //Plasmoid.fullRepresentation=component;
        //webview = component.createObject(webview);
        //webview.createObject(WebviewWebslice);
        //webview = webviewTemp;
    }

    //onKeysseqChanged: { main.handleSettingsUpdated(); }

    Binding {
        target: plasmoid
        property: "hideOnWindowDeactivate"
        value: !showPinButton
    }


    property Component webview: WebEngineView {
        id: webviewID
        url: websliceUrl
        // anchors.fill: parent
	// anchors.fill: plasmoid.fullRepresentation
	// anchors.fill: plasmoid.rootItem;

        backgroundColor: backgroundColorWhite?"white":(backgroundColorTransparent?"transparent":(backgroundColorTheme?theme.viewBackgroundColor:(backgroundColorCustom?customBackgroundColor:"black")))

        width: (displaySiteBehaviour) ? 0 : webPopupWidth
        height: (displaySiteBehaviour) ? 0 : webPopupHeight
        Layout.fillWidth: fillWidthAndHeight
        Layout.fillHeight: fillWidthAndHeight

        zoomFactor: zoomFactorCfg

        onWidthChanged: updateSizeHints()
        onHeightChanged: updateSizeHints()

        // onCertificateError: if(bypassSSLErrors){error.ignoreCertificateError()}

        property bool isExternalLink: false

        profile:  WebEngineProfile{
            httpUserAgent: (enableCustomUA)?customUA:httpUserAgent
            offTheRecord: !notOffTheRecord
            storageName: (notOffTheRecord)?profileName:"webslice-data"
        }


        /* Access to system palette */
        SystemPalette { id: myPalette}

        /**
         * Pin button
         */
        Button {
            id: pinButton
            x: pinButtonAlignmentLeft?y:parent.width-y-2*Math.round(units.gridUnit)
            width: Math.round(units.gridUnit)
            height: width
            checkable: true
            icon.name: "window-pin"
            hoverEnabled: false
            focusPolicy: Qt.NoFocus
            checked: showPinButton
            onCheckedChanged: showPinButton = checked
            visible: !displaySiteBehaviour && showPinButton
            z:1
            palette {
                button: showPinButton ? myPalette.highlight : myPalette.button
            }
        }


        /*
         * When using the shortcut to activate the Plasmoid
         * Thanks to https://github.com/pronobis/webslice-plasmoid/commit/07633bf508c1876d45645415dfc98b802322d407
         */
        Plasmoid.onActivated: {
	    console.log("Plasmoid.onActivated");
            if(enableReloadOnActivate){
                reloadFn(false);
            }
        }

	function onHandleSettingsUpdated() {
	    console.log("onHandleSettingsUpdated")
	    loadMenu();
	    updateSizeHints();
	}

        Connections {
            target: main
        }

        Shortcut {
            id:shortreload
            sequences: [StandardKey.Refresh, keysSeqReload]
            onActivated: reloadFn(false)
        }

        Shortcut {
            sequences: [StandardKey.Back, keysSeqBack]
            onActivated: goBack()
        }

        Shortcut {
            sequences: [StandardKey.Forward, keysSeqForward]
            onActivated: goForward()
        }

        Shortcut {
            sequences: [StandardKey.Cancel, keysSeqStop]
            onActivated: {
		console.log("Stop activated");
                stop();
		plasmoid.busy = false;
		/*
                busyIndicator.visible = false;
                busyIndicator.running = false;
		*/
            }
        }

        /**
         * Hack to handle the size of the popup when displayed as a compactRepresentation
         */
        function updateSizeHints() {
	    console.log("updateSizeHints")
            //console.debug(webviewID.height + " " + webPopupHeight + " " + Plasmoid.configuration.webPopupHeight + " " +displaySiteBehaviour);
            webviewID.zoomFactor = zoomFactorCfg;
	    webviewID.reload();
            if(!displaySiteBehaviour){
                webviewID.height = webPopupHeight;
                webviewID.width = webPopupWidth;
                //console.debug("inside" + webviewID.height + " " + webPopupHeight + " " + Plasmoid.configuration.webPopupHeight + " " +displaySiteBehaviour);
            }
        }

        /**
         * Handle everything around web request : display the busy indicator, and run JS
         */
        onLoadingChanged: {
	    console.log("onLoadingChanged")
	    console.log("loadRequest.status:", loadRequest.status)
	    console.log("loadRequest.errorCode:", loadRequest.errorCode)
	    console.log("loadRequest.errorDomain:", loadRequest.errorDomain)
	    console.log("loadRequest.errorString:", loadRequest.errorString)
	    console.log("loadRequest.url:", loadRequest.url)
	    console.log("WebEngineView.LoadStartedStatus:", WebEngineView.LoadStartedStatus)
	    console.log("WebEngineView.LoadStoppedStatus:", WebEngineView.LoadStoppedStatus)
	    console.log("WebEngineView.LoadSucceededStatus:", WebEngineView.LoadSucceededStatus)
	    console.log("WebEngineView.LoadFailedStatus:", WebEngineView.LoadFailedStatus)
	    console.log("zoomFactorCfg:", zoomFactorCfg)
            webviewID.zoomFactor = zoomFactorCfg;
            if (enableScrollTo && loadRequest.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript("window.scrollTo("+scrollToX+", "+scrollToY+");");
            }
            if (enableJSID && loadRequest.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript(jsSelector + ".scrollIntoView(true);");
            }
            if (scrollbarsOverflow && loadRequest.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript("document.body.style.overflow='hidden';");
            }else if (scrollbarsWebkit && loadRequest.status === WebEngineView.LoadSucceededStatus){
                runJavaScript("var style = document.createElement('style');
                                style.innerHTML = `body::-webkit-scrollbar {display: none;}`;
                                document.head.appendChild(style);");
            }
            if (enableJS && loadRequest.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript(js);
            }
            if (loadRequest && (loadRequest.status === WebEngineView.LoadSucceededStatus || loadRequest.status === WebEngineLoadRequest.LoadFailedStatus)) {
		plasmoid.busy = false;
		/*
                busyIndicator.visible = false;
                busyIndicator.running = false;
		*/
            }
        }

	onRenderProcessPidChanged: {
	    console.log("onRenderProcessPidChanged");
	}

        /**
         * Open the middle clicked (or ctrl+clicked) link in the default browser
         */
        onNavigationRequested: {
	    console.log("onNavigationRequested, request.action:", request.action, "isMainFrame:", request.isMainFrame, "navigationType:", request.navigationType, "url:", request.url, "isExternalLink:", isExternalLink, "zoomFactorCfg:", zoomFactorCfg)
	    console.log("LinkClickedNavigation", WebEngineNavigationRequest.LinkClickedNavigation);
	    console.log("TypedNavigation", WebEngineNavigationRequest.TypedNavigation);
	    console.log("FormSubmittedNavigation", WebEngineNavigationRequest.FormSubmittedNavigation);
	    console.log("BackForwardNavigation", WebEngineNavigationRequest.BackForwardNavigation);
	    console.log("ReloadNavigation", WebEngineNavigationRequest.ReloadNavigation);
	    console.log("RedirectNavigation", WebEngineNavigationRequest.RedirectNavigation);
	    console.log("OtherNavigation", WebEngineNavigationRequest.OtherNavigation);
            webviewID.zoomFactor = zoomFactorCfg;
            if(isExternalLink){
                isExternalLink = false;
                request.action = WebEngineView.IgnoreRequest;
                Qt.openUrlExternally(request.url);
            }else if(reloadAnimation){
		plasmoid.busy = true;
		/*
                busyIndicator.visible = true;
                busyIndicator.running = true;
		*/
            }
        }

	onCertificateError: {
	    console.log("onCertificateError, bypassSSLErrors:", bypassSSLErrors);
	    if (bypassSSLErrors) {
		error.ignoreCertificateError()
	    }
	}

	onWindowCloseRequested: {
	    console.log("onWindowCloseRequested");
	}

	onRenderProcessTerminated: {
	    console.log("onRenderProcessTerminated terminationStatus:", terminationStatus, "exitCode:", exitCode)
	}

        onNewViewRequested: {
	    console.log("onNewViewRequested")
            if(request.userInitiated){
                isExternalLink = true;
            }else{
                isExternalLink = false;
            }
        }

        /**
         * Show context menu
         */
        onContextMenuRequested: {
	    console.log("onContextMenuRequested")
	    console.log("ErrorDomain:", webviewID.ErrorDomain)
	    console.log("Feature:", webviewID.Feature)
	    console.log("LifecycleState:", webviewID.LifecycleState)
	    console.log("LoadStatus:", webviewID.LoadStatus)
	    console.log("RenderProcessTerminationStatus:", webviewID.RenderProcessTerminationStatus)
	    console.log("WebAction:", webviewID.WebAction)
	    console.log("loadingProgress:", webviewID.loadingProgress)
	    console.log("loading:", webviewID.loading)
	    console.log("title:", webviewID.title)
	    console.log("url:", url)
            request.accepted = true
            contextMenu.request = request
            contextMenu.open(request.x, request.y)
        }


        /**
         * Get status of Ctrl key
         */
         P5Support.DataSource {
            id: dataSource
            engine: "keystate"
            connectedSources: ["Ctrl"]
        }

        /**
         * Context menu
         */
        PlasmaComponents.ContextMenu {
            property var request
            id: contextMenu

            PlasmaComponents.MenuItem {
                text: i18n('Back')
                icon: 'draw-arrow-back'
                enabled: webviewID.canGoBack
                onClicked: webviewID.goBack()
            }

            PlasmaComponents.MenuItem {
                text: i18n('Forward')
                icon: 'draw-arrow-forward'
                enabled: webviewID.canGoForward
                onClicked: webviewID.goForward()
            }

            PlasmaComponents.MenuItem {
                text: i18n('Reload')
                icon: 'view-refresh'
                onClicked: {
		    console.log("Refresh clicked")
                    // Force reload if Ctrl pressed
		    if (dataSource.data.Ctrl !== undefined && dataSource.data.Ctrl.Pressed) {
                        reloadFn(true);
                    } else {
                        reloadFn(false);
                    }
                }
            }

            PlasmaComponents.MenuItem {
                id: gotourls
                text: i18n('Go to')
                icon: 'go-jump'
                visible:(urlsToShow.count>0)
                enabled:(urlsToShow.count>0)

                /**
                 * Dynamic context menu
                 * Display the principal URL first, then the list
                 */
                PlasmaComponents.ContextMenu {
                    id:dynamicMenu
                    visualParent: gotourls.action
                    PlasmaComponents.MenuItem {
                        text: websliceUrl
                        icon: 'go-home'
                        onClicked: webviewID.url = websliceUrl
                    }
                }
            }

            PlasmaComponents.MenuItem {
                text: i18n('Go Home')
                icon: 'go-home'
                visible:(urlsToShow.count==0)
                enabled:(urlsToShow.count==0)
                onClicked: webviewID.url = websliceUrl
            }

            PlasmaComponents.MenuItem {
                text: i18n('Open current URL in default browser')
                icon: 'document-share'
                onClicked: Qt.openUrlExternally(webviewID.url)
            }

            PlasmaComponents.MenuItem{
                separator: true
                visible: (typeof contextMenu.request !== "undefined" && contextMenu.request.linkUrl && contextMenu.request.linkUrl != "")
            }

            PlasmaComponents.MenuItem {
                text: i18n('Open link\'s URL in default browser')
                icon: 'document-share'
                enabled: (typeof contextMenu.request !== "undefined" && contextMenu.request.linkUrl && contextMenu.request.linkUrl != "")
                visible: (typeof contextMenu.request !== "undefined" && contextMenu.request.linkUrl && contextMenu.request.linkUrl != "")
                onClicked: Qt.openUrlExternally(contextMenu.request.linkUrl)
            }

            PlasmaComponents.MenuItem {
                text: i18n('Copy link\'s URL')
                icon: 'edit-copy'
                enabled: (typeof contextMenu.request !== "undefined" && contextMenu.request.linkUrl && contextMenu.request.linkUrl != "")
                visible: (typeof contextMenu.request !== "undefined" && contextMenu.request.linkUrl && contextMenu.request.linkUrl != "")
                onClicked: {
		    console.log("Copy link URL clicked")
                    copyURLTextEdit.text = contextMenu.request.linkUrl
                    copyURLTextEdit.selectAll()
                    copyURLTextEdit.copy()
                }
                TextEdit{
                    id: copyURLTextEdit
                    visible: false
                }
            }

            PlasmaComponents.MenuItem{
                separator: true
            }

            PlasmaComponents.MenuItem {
                text: i18n('Configure')
                icon: 'configure'
                onClicked: Plasmoid.action("configure").trigger()
            }
        }

        function addEntry(stringURL) {
	    console.log("addEntry:", stringURL)
            var menuItemI = menuItem.createObject(dynamicMenu, {text: stringURL, icon: 'link', "stringURL":stringURL});
            menuItemI.clicked.connect(function() { webviewID.url = stringURL; });
        }

        Component {
            id: menuItem
            PlasmaComponents.MenuItem {
            }
        }

        function loadMenu() {
	    console.log("loadMenu")
            for(var i=1; i<dynamicMenu.content.length; i++){
                dynamicMenu.content[i].visible=false;
            }

            for(var i=0; i<urlsToShow.count; i++){
                var entry = addEntry(urlsToShow.get(i).url);
            }
        }

        Component.onCompleted: {
	    console.log("Component.onCompleted")
            loadURLs();
        }

        Timer {
            interval: 1000 * reloadIntervalSec
            running: enableReload
            repeat: true
            onTriggered: {
		console.log("reload triggered")
                reloadFn(false)
            }
        }

	/*
        BusyIndicator {
            id: busyIndicator
            z: 5
            opacity: 1

            anchors.left: parent.left
            anchors.top: parent.top
            width: Math.min(webviewID.width, webviewID.height);
            height: Math.min(webviewID.width, webviewID.height);
            anchors.leftMargin: (webviewID.width - busyIndicator.width)/2
            anchors.topMargin: (webviewID.height - busyIndicator.height)/2
            visible: false
            running: false

            contentItem: PlasmaCore.SvgItem {
                id: indicatorItem
                svg: PlasmaCore.Svg {
                    imagePath: "widgets/busywidget"
                }

                RotationAnimator on rotation {
                    from: 0
                    to: 360
                    duration:2000
                    running: busyIndicator.running && indicatorItem.visible && indicatorItem.opacity > 0;
                    loops: Animation.Infinite
                }
            }
        }
	*/

        function reloadFn(force) {
	    console.log("reloadFn: ", force)
            if(reloadAnimation){
		plasmoid.busy = true;
		/*
                busyIndicator.visible = true;
                busyIndicator.running = true;
		*/
            }
            if(force){
                webviewID.reloadAndBypassCache()
            }else{
                webviewID.reload();
            }
        }
    }

    ListModel {
        id: urlsToShow
    }

    function loadURLs(){
	console.log("loadURLs")
        var arrayURLs = ConfigUtils.getURLsObjectArray();
        urlsToShow.clear();
        for (var index in arrayURLs) {
            urlsToShow.append({"url":arrayURLs[index]});
        }

        main.handleSettingsUpdated();
    }

}
