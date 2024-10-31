import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import "../code/utils.js" as ConfigUtils
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

KCMUtils.SimpleKCM {
    id: rootItem

    property string cfg_urlsModel


    /*
    property int textfieldWidth:parent.width-(buttonAdd.width+5)*4
    property double tableWidth: parent.width
    */


   /*
    ListModel {
        id: urlsModel
    }
    */


    ColumnLayout {
        Label {
            text: i18n('List of URLs accessible throught the context menu to switch to others websites.')
        }

        ListView {
            id: table
	    width: parent.parent.width; height: 200;
	    model: ListModel {
		id: urlsModel
	    }
	    orientation: ListView.Vertical
	    verticalLayoutDirection: ListView.TopToBottom
	    highlightFollowsCurrentItem: true
            // width: tableWidth
	    delegate: Component {
		id: urlComponent
		PlasmaComponents.ItemDelegate {
		id: urlText
		required property string url
		text: "URL: " + url
		highlighted: ListView.isCurrentItem
		onClicked: {
		    console.log("index:", index);
		}
		// color: ListView.isCurrentItem ? Kirigami.Theme.activeTextColor : Kirigami.Theme.textColor

		/*
		MouseArea {
		    anchors.fill: parent
		    onClicked: {
			urlText.forceActiveFocus()
			console.log("urlText.index: ", urlText.index)
			console.log("parent.index: ", parent.index)
			console.log("index: ", index)
			table.currentIndex = parent.index
		    }
		}
		*/
		}
		}
            //height:300
	    focus: true
        }


	TextField {
	    id: addedUrl
	    placeholderText: i18n('URL to add')
	    Keys.onReturnPressed: {
		urlsModel.append({"url": addedUrl.text});
		cfg_urlsModel = ConfigUtils.stringifyModel(urlsModel)
	    }
	    // Layout.preferredWidth: textfieldWidth
	}

        RowLayout {
	    id: buttons
            Button {
                id:buttonAdd
                icon.name: 'list-add'
                text: i18n('Add a URL')
                onClicked: {
                    urlsModel.append({"url": addedUrl.text});
                    cfg_urlsModel = ConfigUtils.stringifyModel(urlsModel)
                }
            }

            Button {
                icon.name: 'list-remove'
                text: i18n('Remove the selected URL')
                onClicked: {
                    urlsModel.remove(table.currentIndex);
                    cfg_urlsModel = ConfigUtils.stringifyModel(urlsModel)
                }
            }
            Button {
                icon.name: 'go-up'
                text: i18n('Move the selected URL up')
                onClicked: {
		    var current = table.currentIndex

		    if (current > 0) {
			urlsModel.move(table.currentIndex, table.currentIndex - 1, 1);
			table.currentIndex = Math.max(current - 1, 0)
			cfg_urlsModel = ConfigUtils.stringifyModel(urlsModel)
		    }
                }
            }
            Button {
                icon.name: 'go-down'
                text: i18n('Move the selected URL down')
                onClicked: {
		    var current = table.currentIndex

		    if (current < (table.count - 1)) {
			urlsModel.move(table.currentIndex, table.currentIndex + 1, 1);
			table.currentIndex = Math.min(current + 1, table.count)
			cfg_urlsModel = ConfigUtils.stringifyModel(urlsModel)
		    }
                }
            }
        }
    }

    Component.onCompleted: {
        var arrayURLs = ConfigUtils.getURLsObjectArray();
        for (var index in arrayURLs) {
	    console.log("URL: ", arrayURLs[index]);
            urlsModel.append({"url":arrayURLs[index]});
        }
    }
}
