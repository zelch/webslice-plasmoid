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

pragma ComponentBehavior: Bound

import QtQuick
import QtWebEngine
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.plasmoid as Plasmoid
import QtQml
import org.kde.kirigami as Kirigami

import "../code/utils.js" as ConfigUtils

Plasmoid.PlasmoidItem {
    id: main

    property string websliceUrl: plasmoid.configuration.websliceUrl
    property double zoomFactorCfg: plasmoid.configuration.zoomFactor
    property bool enableReload: plasmoid.configuration.enableReload
    property int reloadIntervalSec: plasmoid.configuration.reloadIntervalSec
    property int webPopupWidth: plasmoid.configuration.webPopupWidth
    property int webPopupHeight: plasmoid.configuration.webPopupHeight
    property string webPopupIcon: plasmoid.configuration.webPopupIcon
    property bool showPinButton: plasmoid.configuration.showPinButton
    property bool pinButtonAlignmentLeft: plasmoid.configuration.pinButtonAlignmentLeft
    property bool reloadAnimation: plasmoid.configuration.reloadAnimation

    property bool enableScrollTo: plasmoid.configuration.enableScrollTo
    property int scrollToX: plasmoid.configuration.scrollToX
    property int scrollToY: plasmoid.configuration.scrollToY
    property bool enableJSID: plasmoid.configuration.enableJSID
    property string jsSelector: plasmoid.configuration.jsSelector
    property bool enableCustomUA: plasmoid.configuration.enableCustomUA
    property string customUA: plasmoid.configuration.customUA
    property bool enableReloadOnActivate: plasmoid.configuration.enableReloadOnActivate
    property bool bypassSSLErrors: plasmoid.configuration.bypassSSLErrors
    property bool scrollbarsShow: plasmoid.configuration.scrollbarsShow
    property bool scrollbarsOverflow: plasmoid.configuration.scrollbarsOverflow
    property bool scrollbarsWebkit: plasmoid.configuration.scrollbarsWebkit
    property bool enableJS: plasmoid.configuration.enableJS
    property string js: plasmoid.configuration.js

    property string urlsModel: plasmoid.configuration.urlsModel

    property string keysSeqBack: plasmoid.configuration.keysSeqBack
    property string keysSeqForward: plasmoid.configuration.keysSeqForward
    property string keysSeqReload: plasmoid.configuration.keysSeqReload
    property string keysSeqStop: plasmoid.configuration.keysSeqStop
    property bool fillWidthAndHeight: plasmoid.configuration.fillWidthAndHeight
    property bool notOffTheRecord: plasmoid.configuration.notOffTheRecord
    property string profileName: plasmoid.configuration.profileName

    property bool cfg_debug: plasmoid.configuration.debug

    signal handleSettingsUpdated

    preferredRepresentation: fullRepresentation

    fullRepresentation: webview

    // icon.name: webPopupIcon

    onUrlsModelChanged: {
        ConfigUtils.debug("onUrlsModelChanged");
        loadURLs();
    }

    onWebPopupHeightChanged: {
        ConfigUtils.debug("onWebPopupHeightChanged");
        main.handleSettingsUpdated();
    }

    onWebPopupWidthChanged: {
        ConfigUtils.debug("onWebPopupWidthChanged");
        main.handleSettingsUpdated();
    }

    onZoomFactorCfgChanged: {
        ConfigUtils.debug("onZoomFactorCfgChanged");
        main.handleSettingsUpdated();
    }

    onNotOffTheRecordChanged: {
        ConfigUtils.debug("onNotOffTheRecordChanged");
        webview.reloadFn(true);
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
        url: main.websliceUrl

        backgroundColor: getBackgroundColor()

        function getBackgroundColor() {
            switch (plasmoid.configuration.backgroundColor) {
            case "theme":
                return Kirigami.Theme.backgroundColor;
            case "custom":
                return plasmoid.configuration.customBackgroundColor;
            default:
                return plasmoid.configuration.backgroundColor;
            }
        }

        width: main.webPopupWidth
        height: main.webPopupHeight
        Layout.fillWidth: main.fillWidthAndHeight
        Layout.fillHeight: main.fillWidthAndHeight

        zoomFactor: main.zoomFactorCfg

        onWidthChanged: {
            ConfigUtils.debug("onWidthChanged");
            updateSizeHints();
        }
        onHeightChanged: {
            ConfigUtils.debug("onHeightChanged");
            updateSizeHints();
        }

        // onCertificateError: if(bypassSSLErrors){error.ignoreCertificateError()}

        property bool isExternalLink: false

        profile: WebEngineProfile {
            httpUserAgent: (main.enableCustomUA) ? main.customUA : httpUserAgent
            offTheRecord: !main.notOffTheRecord
            storageName: (main.notOffTheRecord) ? main.profileName : "webslice-data"
        }

        /* Access to system palette */
        SystemPalette {
            id: myPalette
        }

        /*
         * When using the shortcut to activate the Plasmoid
         * Thanks to https://github.com/pronobis/webslice-plasmoid/commit/07633bf508c1876d45645415dfc98b802322d407
         */
        // Plasmoid.onActivated: {
        //     ConfigUtils.debug("Plasmoid.onActivated");
        //     if (enableReloadOnActivate) {
        //         reloadFn(false);
        //     }
        // }

        function onHandleSettingsUpdated() {
            ConfigUtils.debug("onHandleSettingsUpdated");
            // loadMenu();
            updateSizeHints();
        }

        Connections {
            target: main
        }

        Shortcut {
            id: shortreload
            sequences: [StandardKey.Refresh, main.keysSeqReload]
            onActivated: webviewID.reloadFn(false)
        }

        Shortcut {
            sequences: [StandardKey.Back, main.keysSeqBack]
            onActivated: webviewID.goBack()
        }

        Shortcut {
            sequences: [StandardKey.Forward, main.keysSeqForward]
            onActivated: webviewID.goForward()
        }

        Shortcut {
            sequences: [StandardKey.Cancel, main.keysSeqStop]
            onActivated: {
                ConfigUtils.debug("Stop activated");
                stop();
                plasmoid.busy = false;
            }
        }

        /**
         * Hack to handle the size of the popup when displayed as a compactRepresentation
         */
        function updateSizeHints() {
            ConfigUtils.debug("  updateSizeHints");
            ConfigUtils.debug("    width: " + webviewID.width + " " + webPopupWidth + " " + plasmoid.configuration.webPopupWidth);
            ConfigUtils.debug("    height: " + webviewID.height + " " + webPopupHeight + " " + plasmoid.configuration.webPopupHeight);
            webviewID.zoomFactor = main.zoomFactorCfg;
            webviewID.reload();
            return;
        }

        /**
         * Handle everything around web request : display the busy indicator, and run JS
         */
        onLoadingChanged: function (loadingInfo) {
            ConfigUtils.debug("onLoadingChanged");
            ConfigUtils.debug("  loadingInfo.status:", ConfigUtils.loadString(loadingInfo.status));
            ConfigUtils.debug("  loadingInfo.errorCode:", loadingInfo.errorCode);
            ConfigUtils.debug("  loadingInfo.errorDomain:", loadingInfo.errorDomain);
            ConfigUtils.debug("  loadingInfo.errorString:", loadingInfo.errorString);
            ConfigUtils.debug("  loadingInfo.url:", loadingInfo.url);
            ConfigUtils.debug("  zoomFactorCfg:", main.zoomFactorCfg);
            webviewID.zoomFactor = main.zoomFactorCfg;
            if (main.enableScrollTo && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript("window.scrollTo(" + scrollToX + ", " + scrollToY + ");");
            }
            if (main.enableJSID && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript(jsSelector + ".scrollIntoView(true);");
            }
            if (main.scrollbarsOverflow && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript("document.body.style.overflow='hidden';");
            } else if (main.scrollbarsWebkit && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript(`var style = document.createElement('style');
                                style.innerHTML = \`body::-webkit-scrollbar {display: none;}\`;
                                document.head.appendChild(style);`);
            }
            if (main.enableJS && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript(main.js);
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
        onNavigationRequested: function (request) {
            ConfigUtils.debug("onNavigationRequested, isMainFrame:", request.isMainFrame, "navigationType:", ConfigUtils.navTypeString(request.navigationType), "url:", request.url, "isExternalLink:", isExternalLink, "zoomFactorCfg:", zoomFactorCfg);
            webviewID.zoomFactor = main.zoomFactorCfg;
            if (isExternalLink) {
                isExternalLink = false;
                request.reject();
                Qt.openUrlExternally(request.url);
            } else if (main.reloadAnimation) {
                main.plasmoid.busy = true;
            }
        }

        onCertificateError: function (error) {
            ConfigUtils.debug("onCertificateError, bypassSSLErrors:", main.bypassSSLErrors);
            if (main.bypassSSLErrors) {
                // error.ignoreCertificateError();
                error.acceptCertificate();
            }
        }

        onWindowCloseRequested: {
            ConfigUtils.debug("onWindowCloseRequested");
        }

        onRenderProcessTerminated: function (terminationStatus, exitCode) {
            ConfigUtils.debug("onRenderProcessTerminated terminationStatus:", terminationStatus, "exitCode:", exitCode);
            reloadFn(false);
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
        onContextMenuRequested: function (request) {
            /*
            ConfigUtils.debug("onContextMenuRequested");
            ConfigUtils.debug("  webviewID:", webviewID);
            ConfigUtils.debug("  request:", request);
            ConfigUtils.debug("  request.position:", request.position);
            ConfigUtils.debug("  request.position.x:", request.position.x);
            ConfigUtils.debug("  request.position.y:", request.position.y);
            ConfigUtils.debug("  request.x:", request.x);
            ConfigUtils.debug("  request.y:", request.y);
            ConfigUtils.debug("  ErrorDomain:", webviewID.ErrorDomain);
            ConfigUtils.debug("  Feature:", webviewID.Feature);
            ConfigUtils.debug("  LifecycleState:", webviewID.LifecycleState);
            ConfigUtils.debug("  LoadStatus:", webviewID.LoadStatus);
            ConfigUtils.debug("  RenderProcessTerminationStatus:", webviewID.RenderProcessTerminationStatus);
            ConfigUtils.debug("  WebAction:", webviewID.WebAction);
            ConfigUtils.debug("  loadingProgress:", webviewID.loadingProgress);
            ConfigUtils.debug("  loading:", webviewID.loading);
            ConfigUtils.debug("  title:", webviewID.title);
            ConfigUtils.debug("  url:", url);
            ConfigUtils.debug("  contextualActions:", Plasmoid.contextualActions);
            */

            request.accepted = true;
            contextMenu.popup(webviewID);
        }

        onJavaScriptConsoleMessage: function (level, msg, line, source) {
            ConfigUtils.debug("webslice: ", level, " - ", msg, " -", line, " - ", source);
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
        Menu {
            id: contextMenu

            MenuItem {
                text: i18n('Back')
                icon.name: 'draw-arrow-back'
                enabled: webviewID.canGoBack
                onTriggered: webviewID.goBack()
            }
            MenuItem {
                text: i18n('Forward')
                icon.name: 'draw-arrow-forward'
                enabled: webviewID.canGoForward
                onTriggered: webviewID.goForward()
            }
            MenuItem {
                text: i18n('Reload')
                icon.name: 'view-refresh'
                onTriggered: {
                    ConfigUtils.debug("Refresh clicked");
                    // Force reload if Ctrl pressed
                    if (dataSource.data.Ctrl !== undefined && dataSource.data.Ctrl.Pressed) {
                        ConfigUtils.debug("Force reload.");
                        webviewID.reloadFn(true);
                    } else {
                        webviewID.reloadFn(false);
                    }
                }
            }
            MenuItem {
                text: i18n('Go Home')
                icon.name: 'go-home'
                visible: (urlsToShow.count == 0)
                enabled: (urlsToShow.count == 0)
                onTriggered: webviewID.url = main.websliceUrl
            }
            MenuItem {
                text: i18n('Open current URL in default browser')
                icon.name: 'document-share'
                onTriggered: Qt.openUrlExternally(webviewID.url)
            }

            /*
             PlasmaCore.Action{
                 separator: true
             }
             */

            MenuItem {
                text: i18n('Configure')
                icon.name: 'configure'
                onTriggered: main.plasmoid.internalAction("configure").trigger()
            }
        }

        Component.onCompleted: {
            ConfigUtils.debug("Component.onCompleted");
            main.loadURLs();
        }

        Timer {
            interval: 1000 * main.reloadIntervalSec
            running: main.enableReload
            repeat: true
            onTriggered: {
                ConfigUtils.debug("reload triggered");
                webviewID.reloadFn(false);
            }
        }

        function reloadFn(force) {
            ConfigUtils.debug("reloadFn: ", force);
            if (main.reloadAnimation) {
                main.plasmoid.busy = true;
            }
            if (force) {
                webviewID.reloadAndBypassCache();
            } else {
                webviewID.reload();
            }
        }
    }

    ListModel {
        id: urlsToShow
    }

    function loadURLs() {
        ConfigUtils.debug("loadURLs");
        var arrayURLs = ConfigUtils.getURLsObjectArray();
        urlsToShow.clear();
        for (var index in arrayURLs) {
            urlsToShow.append({
                "url": arrayURLs[index]
            });
        }

        main.handleSettingsUpdated();
    }
}
