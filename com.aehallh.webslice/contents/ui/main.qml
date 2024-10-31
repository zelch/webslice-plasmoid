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

import QtQuick
import QtWebEngine
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import QtQml
import org.kde.kirigami as Kirigami

import "../code/utils.js" as ConfigUtils



PlasmoidItem {
    id: main

    property string websliceUrl: Plasmoid.configuration.websliceUrl
    property double zoomFactorCfg: Plasmoid.configuration.zoomFactor
    property bool enableReload: Plasmoid.configuration.enableReload
    property int reloadIntervalSec: Plasmoid.configuration.reloadIntervalSec
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

    property bool cfg_debug: Plasmoid.configuration.debug

    signal handleSettingsUpdated();

    preferredRepresentation: fullRepresentation

    fullRepresentation: webview

    // icon.name: webPopupIcon

    onUrlsModelChanged:{ ConfigUtils.debug("onUrlsModelChanged"); loadURLs(); }

    onWebPopupHeightChanged:{ ConfigUtils.debug("onWebPopupHeightChanged"); main.handleSettingsUpdated(); }

    onWebPopupWidthChanged:{  ConfigUtils.debug("onWebPopupWidthChanged"); main.handleSettingsUpdated(); }

    onZoomFactorCfgChanged:{  ConfigUtils.debug("onZoomFactorCfgChanged"); main.handleSettingsUpdated(); }

    onNotOffTheRecordChanged:{
        ConfigUtils.debug("test");
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

    /*
    Binding {
        target: plasmoid
        property: "hideOnWindowDeactivate"
        value: !showPinButton
    }
    */


    property Component webview: WebEngineView {
        id: webviewID
        url: websliceUrl
        // anchors.fill: parent
	// anchors.fill: plasmoid.fullRepresentation
	// anchors.fill: plasmoid.rootItem;

        backgroundColor: backgroundColorWhite?"white":(backgroundColorTransparent?"transparent":(backgroundColorTheme?Kirigami.Theme.viewBackgroundColor:(backgroundColorCustom?customBackgroundColor:"black")))

        width: webPopupWidth
        height: webPopupHeight
        Layout.fillWidth: fillWidthAndHeight
        Layout.fillHeight: fillWidthAndHeight

        zoomFactor: zoomFactorCfg

        onWidthChanged: { ConfigUtils.debug("onWidthChanged"); updateSizeHints() }
        onHeightChanged: { ConfigUtils.debug("onHeightChanged"); updateSizeHints() }

        // onCertificateError: if(bypassSSLErrors){error.ignoreCertificateError()}

        property bool isExternalLink: false

        profile:  WebEngineProfile{
            httpUserAgent: (enableCustomUA)?customUA:httpUserAgent
            offTheRecord: !notOffTheRecord
            storageName: (notOffTheRecord)?profileName:"webslice-data"
        }


        /* Access to system palette */
        SystemPalette { id: myPalette}

        /*
         * When using the shortcut to activate the Plasmoid
         * Thanks to https://github.com/pronobis/webslice-plasmoid/commit/07633bf508c1876d45645415dfc98b802322d407
         */
        Plasmoid.onActivated: {
	    ConfigUtils.debug("Plasmoid.onActivated");
            if(enableReloadOnActivate){
                reloadFn(false);
            }
        }

	function onHandleSettingsUpdated() {
	    ConfigUtils.debug("onHandleSettingsUpdated")
	    // loadMenu();
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
		ConfigUtils.debug("Stop activated");
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
            ConfigUtils.debug("  updateSizeHints")
            ConfigUtils.debug("    width: " + webviewID.width + " " + webPopupWidth + " " + Plasmoid.configuration.webPopupWidth);
            ConfigUtils.debug("    height: " + webviewID.height + " " + webPopupHeight + " " + Plasmoid.configuration.webPopupHeight);
            webviewID.zoomFactor = zoomFactorCfg;
            webviewID.reload();
            return
        }

        /**
         * Handle everything around web request : display the busy indicator, and run JS
         */
        onLoadingChanged: function(loadingInfo) {
	    ConfigUtils.debug("onLoadingChanged")
	    ConfigUtils.debug("  loadingInfo.status:", ConfigUtils.loadString(loadingInfo.status))
	    ConfigUtils.debug("  loadingInfo.errorCode:", loadingInfo.errorCode)
	    ConfigUtils.debug("  loadingInfo.errorDomain:", loadingInfo.errorDomain)
	    ConfigUtils.debug("  loadingInfo.errorString:", loadingInfo.errorString)
	    ConfigUtils.debug("  loadingInfo.url:", loadingInfo.url)
	    ConfigUtils.debug("  zoomFactorCfg:", zoomFactorCfg)
            webviewID.zoomFactor = zoomFactorCfg;
            if (enableScrollTo && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript("window.scrollTo("+scrollToX+", "+scrollToY+");");
            }
            if (enableJSID && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript(jsSelector + ".scrollIntoView(true);");
            }
            if (scrollbarsOverflow && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript("document.body.style.overflow='hidden';");
            }else if (scrollbarsWebkit && loadingInfo.status === WebEngineView.LoadSucceededStatus){
                runJavaScript("var style = document.createElement('style');
                                style.innerHTML = `body::-webkit-scrollbar {display: none;}`;
                                document.head.appendChild(style);");
            }
            if (enableJS && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript(js);
            }
            if (loadingInfo && (loadingInfo.status === WebEngineView.LoadSucceededStatus || loadingInfo.status === WebEngineView.LoadFailedStatus)) {
		plasmoid.busy = false;
            }
        }

	onRenderProcessPidChanged: {
	    ConfigUtils.debug("onRenderProcessPidChanged");
	}

        /**
         * Open the middle clicked (or ctrl+clicked) link in the default browser
         */
        onNavigationRequested: function(request) {
	    ConfigUtils.debug("onNavigationRequested, isMainFrame:", request.isMainFrame, "navigationType:", ConfigUtils.navTypeString(request.navigationType), "url:", request.url, "isExternalLink:", isExternalLink, "zoomFactorCfg:", zoomFactorCfg)
            webviewID.zoomFactor = zoomFactorCfg;
            if (isExternalLink) {
                isExternalLink = false;
		request.reject()
                //request.action = WebEngineView.IgnoreRequest;
                Qt.openUrlExternally(request.url);
            } else if (reloadAnimation) {
		plasmoid.busy = true;
		/*
                busyIndicator.visible = true;
                busyIndicator.running = true;
		*/
            }
        }

	onCertificateError: {
	    ConfigUtils.debug("onCertificateError, bypassSSLErrors:", bypassSSLErrors);
	    if (bypassSSLErrors) {
		error.ignoreCertificateError()
	    }
	}

	onWindowCloseRequested: {
	    ConfigUtils.debug("onWindowCloseRequested");
	}

	onRenderProcessTerminated: {
	    ConfigUtils.debug("onRenderProcessTerminated terminationStatus:", terminationStatus, "exitCode:", exitCode)
	    reloadFn(false)
	}

	/*
        onNewViewRequested: {
	    ConfigUtils.debug("onNewViewRequested")
            if (request.userInitiated) {
                isExternalLink = true;
            }else{
                isExternalLink = false;
            }
        }
	*/

        /**
         * Show context menu
         */
        onContextMenuRequested: function(request) {
	    ConfigUtils.debug("onContextMenuRequested")
	    ConfigUtils.debug("  ErrorDomain:", webviewID.ErrorDomain)
	    ConfigUtils.debug("  Feature:", webviewID.Feature)
	    ConfigUtils.debug("  LifecycleState:", webviewID.LifecycleState)
	    ConfigUtils.debug("  LoadStatus:", webviewID.LoadStatus)
	    ConfigUtils.debug("  RenderProcessTerminationStatus:", webviewID.RenderProcessTerminationStatus)
	    ConfigUtils.debug("  WebAction:", webviewID.WebAction)
	    ConfigUtils.debug("  loadingProgress:", webviewID.loadingProgress)
	    ConfigUtils.debug("  loading:", webviewID.loading)
	    ConfigUtils.debug("  title:", webviewID.title)
	    ConfigUtils.debug("  url:", url)
	    ConfigUtils.debug("  request:", request)
	    ConfigUtils.debug("  request.x:", request.x)
	    ConfigUtils.debug("  request.y:", request.y)
	    ConfigUtils.debug("  contextualActions:", Plasmoid.contextualActions);
	    /*
	    // FIXME: We don't have any way to trigger the context menu right now.
            request.accepted = true
	    Plasmoid.contextualActionsAboutToShow()
	    Plasmoid.showStatusNotifierContextMenu()
	    Plasmoid.showPlasmoidMenu(main, request.x, request.y)
	    contextMenu(request)
	    */
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
	Plasmoid.contextualActions: [
	    PlasmaCore.Action {
                text: i18n('Back')
                icon.name: 'draw-arrow-back'
                enabled: webviewID.canGoBack
                onTriggered: webviewID.goBack()
	    },
	    PlasmaCore.Action {
                text: i18n('Forward')
                icon.name: 'draw-arrow-forward'
                enabled: webviewID.canGoForward
                onTriggered: webviewID.goForward()
            },
	    PlasmaCore.Action {
                text: i18n('Reload')
                icon.name: 'view-refresh'
                onTriggered: {
		    ConfigUtils.debug("Refresh clicked")
                    // Force reload if Ctrl pressed
		    if (dataSource.data.Ctrl !== undefined && dataSource.data.Ctrl.Pressed) {
                        reloadFn(true);
                    } else {
                        reloadFn(false);
                    }
                }
            },
	    PlasmaCore.Action {
                text: i18n('Go Home')
                icon.name: 'go-home'
                visible:(urlsToShow.count==0)
                enabled:(urlsToShow.count==0)
                onTriggered: webviewID.url = websliceUrl
            },

            PlasmaCore.Action {
                text: i18n('Open current URL in default browser')
                icon.name: 'document-share'
                onTriggered: Qt.openUrlExternally(webviewID.url)
            },

	    /*
            PlasmaCore.Action{
                separator: true
                visible: (typeof contextMenu.request !== "undefined" && contextMenu.request.linkUrl && contextMenu.request.linkUrl != "")
            },
	    */

            PlasmaCore.Action {
                text: i18n('Open link\'s URL in default browser')
                icon.name: 'document-share'
                enabled: (typeof contextMenu.request !== "undefined" && contextMenu.request.linkUrl && contextMenu.request.linkUrl != "")
                visible: (typeof contextMenu.request !== "undefined" && contextMenu.request.linkUrl && contextMenu.request.linkUrl != "")
                onTriggered: Qt.openUrlExternally(contextMenu.request.linkUrl)
            },

	    /*
            PlasmaCore.Action {
                text: i18n('Copy link\'s URL')
                icon.name: 'edit-copy'
                enabled: (typeof contextMenu.request !== "undefined" && contextMenu.request.linkUrl && contextMenu.request.linkUrl != "")
                visible: (typeof contextMenu.request !== "undefined" && contextMenu.request.linkUrl && contextMenu.request.linkUrl != "")
                onTriggered: {
		    ConfigUtils.debug("Copy link URL clicked")
                    copyURLTextEdit.text = contextMenu.request.linkUrl
                    copyURLTextEdit.selectAll()
                    copyURLTextEdit.copy()
                }
                TextEdit {
                    id: copyURLTextEdit
                    visible: false
                }
            },
	    */

	    /*
            PlasmaCore.Action{
                separator: true
            },
	    */

            PlasmaCore.Action {
                text: i18n('Configure')
                icon.name: 'configure'
                onTriggered: Plasmoid.internalAction("configure").trigger()
            }
	]

	/*
        function addEntry(stringURL) {
	    ConfigUtils.debug("addEntry:", stringURL)
            var menuItemI = menuItem.createObject(dynamicMenu, {text: stringURL, icon.name: 'link', "stringURL":stringURL});
            menuItemI.clicked.connect(function() { webviewID.url = stringURL; });
        }

        Component {
            id: menuItem
            PlasmaComponents.MenuItem {
            }
        }
	*/

	/*
        function loadMenu() {
	    ConfigUtils.debug("loadMenu")
            for(var i=1; i<dynamicMenu.content.length; i++){
                dynamicMenu.content[i].visible=false;
            }

            for(var i=0; i<urlsToShow.count; i++){
                var entry = addEntry(urlsToShow.get(i).url);
            }
        }
	*/

        Component.onCompleted: {
	    ConfigUtils.debug("Component.onCompleted")
            loadURLs();
        }

        Timer {
            interval: 1000 * reloadIntervalSec
            running: enableReload
            repeat: true
            onTriggered: {
		ConfigUtils.debug("reload triggered")
                reloadFn(false)
            }
        }

        function reloadFn(force) {
	    ConfigUtils.debug("reloadFn: ", force)
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
	ConfigUtils.debug("loadURLs")
        var arrayURLs = ConfigUtils.getURLsObjectArray();
        urlsToShow.clear();
        for (var index in arrayURLs) {
            urlsToShow.append({"url":arrayURLs[index]});
        }

        main.handleSettingsUpdated();
    }

}
