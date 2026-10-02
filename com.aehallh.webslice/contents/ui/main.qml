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
        main.handleSettingsUpdated();
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
            updateSizeHints("width-changed");
        }
        onHeightChanged: {
            ConfigUtils.debug("onHeightChanged");
            updateSizeHints("height-changed");
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
            updateSizeHints("settings-updated");
        }

        Connections {
            target: main
        }

        Shortcut {
            id: shortreload
            sequences: [StandardKey.Refresh, main.keysSeqReload]
            onActivated: webviewID.reloadFn(false, "shortcut")
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
                webviewID.action(WebEngineView.Stop).trigger();
                plasmoid.busy = false;
            }
        }

        /**
         * Hack to handle the size of the popup when displayed as a compactRepresentation
         *
         * Debounced: width/height can change in rapid bursts (layout negotiation,
         * panel resize, popup-open animation, fillWidth/fillHeight recalculation),
         * and each change used to trigger an immediate, uncoalesced reload() - a
         * runaway reload storm under the right conditions. Route through the
         * resizeReloadDebounce timer instead of reloading synchronously here.
         */
        function updateSizeHints(reason) {
            ConfigUtils.debug("  updateSizeHints reason=" + reason);
            ConfigUtils.debug("    width: " + webviewID.width + " " + main.webPopupWidth + " " + plasmoid.configuration.webPopupWidth);
            ConfigUtils.debug("    height: " + webviewID.height + " " + main.webPopupHeight + " " + plasmoid.configuration.webPopupHeight);
            resizeReloadDebounce.pendingReason = reason || "size-hints";
            resizeReloadDebounce.restart();
        }

        Timer {
            id: resizeReloadDebounce
            interval: 500
            property string pendingReason: "size-hints"
            onTriggered: {
                webviewID.zoomFactor = main.zoomFactorCfg;
                webviewID.reloadFn(false, "resize-debounce:" + pendingReason);
            }
        }

        /**
         * Handle everything around web request : display the busy indicator, and run JS
         */
        onLoadingChanged: function (loadingInfo) {
            logEvent("loadingChanged", ConfigUtils.loadString(loadingInfo.status) + " url=" + loadingInfo.url + (loadingInfo.status === WebEngineView.LoadFailedStatus ? " error=" + loadingInfo.errorString : ""));
            ConfigUtils.debug("onLoadingChanged");
            ConfigUtils.debug("  loadingInfo.status:", ConfigUtils.loadString(loadingInfo.status));
            ConfigUtils.debug("  loadingInfo.errorCode:", loadingInfo.errorCode);
            ConfigUtils.debug("  loadingInfo.errorDomain:", loadingInfo.errorDomain);
            ConfigUtils.debug("  loadingInfo.errorString:", loadingInfo.errorString);
            ConfigUtils.debug("  loadingInfo.url:", loadingInfo.url);
            ConfigUtils.debug("  zoomFactorCfg:", main.zoomFactorCfg);
            webviewID.zoomFactor = main.zoomFactorCfg;
            if (main.enableScrollTo && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript("window.scrollTo(" + main.scrollToX + ", " + main.scrollToY + ");");
            }
            if (main.enableJSID && loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                runJavaScript(main.jsSelector + ".scrollIntoView(true);");
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
            logEvent("renderProcessPidChanged", "pid=" + renderProcessPid);
            ConfigUtils.debug("onRenderProcessPidChanged");
        }

        onUrlChanged: {
            logEvent("urlChanged", "url=" + url);
        }

        /**
         * Open the middle clicked (or ctrl+clicked) link in the default browser
         */
        onNavigationRequested: function (request) {
            logEvent("navigationRequested", "mainFrame=" + request.isMainFrame + " type=" + ConfigUtils.navTypeString(request.navigationType) + " url=" + request.url);
            ConfigUtils.debug("onNavigationRequested, isMainFrame:", request.isMainFrame, "navigationType:", ConfigUtils.navTypeString(request.navigationType), "url:", request.url, "isExternalLink:", isExternalLink, "zoomFactorCfg:", main.zoomFactorCfg);
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
            console.warn(logTag + " render process terminated (status=" + terminationStatus + ", exitCode=" + exitCode + "), debouncing recovery reload");
            renderTerminatedReloadDebounce.restart();
        }

        // Debounced so a renderer that crashes repeatedly (e.g. under memory
        // pressure) can't turn into a tight crash/reload loop; each new
        // termination just pushes the recovery reload out further.
        Timer {
            id: renderTerminatedReloadDebounce
            interval: 2000
            onTriggered: webviewID.reloadFn(false, "render-process-terminated")
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
            logEvent("jsConsole", "level=" + level + " src=" + source + ":" + line + " msg=" + String(msg).substring(0, 100));
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
                        webviewID.reloadFn(true, "context-menu-force");
                    } else {
                        webviewID.reloadFn(false, "context-menu");
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
                webviewID.reloadFn(false, "auto-reload-timer");
            }
        }

        readonly property string logTag: "webslice[" + main.plasmoid.id + "]:"

        // Per-kind event counts for the current eventStatsTimer window. Used by
        // logEvent() to log the first few events of each kind in full and then
        // only summarize, so a page-driven event flood is visible in the
        // journal without our own logging adding to the flood.
        property var eventCounts: ({})
        readonly property int eventLogBurst: 5

        function logEvent(kind, detail) {
            const count = (eventCounts[kind] || 0) + 1;
            eventCounts[kind] = count;
            if (count <= eventLogBurst) {
                console.log(logTag + " " + kind + " " + detail);
            }
            if (!eventStatsTimer.running) {
                eventStatsTimer.start();
            }
        }

        Timer {
            id: eventStatsTimer
            interval: 10000
            repeat: true
            onTriggered: {
                const summary = [];
                let noisy = false;
                for (const kind in webviewID.eventCounts) {
                    summary.push(kind + "=" + webviewID.eventCounts[kind]);
                    if (webviewID.eventCounts[kind] > webviewID.eventLogBurst) {
                        noisy = true;
                    }
                }
                if (summary.length === 0) {
                    stop();
                    return;
                }
                if (noisy) {
                    console.warn(webviewID.logTag + " event burst in last " + (interval / 1000) + "s: " + summary.join(" "));
                }
                webviewID.eventCounts = ({});
            }
        }

        // Recent reloadFn() call timestamps (ms), used only for the loop
        // detection below; pruned to the last reloadLoopWindowMs on every call.
        property var reloadTimestamps: []
        readonly property int reloadLoopWindowMs: 10000
        readonly property int reloadLoopWarnThreshold: 5

        function reloadFn(force, reason) {
            const label = reason || "unknown";
            const now = Date.now();
            reloadTimestamps = reloadTimestamps.filter(t => now - t < reloadLoopWindowMs);
            reloadTimestamps.push(now);

            // Unconditional (not gated behind the debug config flag) so a
            // reload storm is visible in the journal even when debug logging
            // is off. Deliberately not itself debounced/rate-limited: this
            // logging exists to make runaway-reload incidents diagnosable.
            console.log(logTag + " reloadFn force=" + force + " reason=" + label + " recentReloads(" + (reloadLoopWindowMs / 1000) + "s)=" + reloadTimestamps.length);
            if (reloadTimestamps.length >= reloadLoopWarnThreshold) {
                console.warn(logTag + " possible reload loop detected - " + reloadTimestamps.length + " reloads in the last " + (reloadLoopWindowMs / 1000) + "s (last reason: " + label + ")");
            }

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
        for (const index in arrayURLs) {
            urlsToShow.append({
                "url": arrayURLs[index]
            });
        }

        main.handleSettingsUpdated();
    }
}
