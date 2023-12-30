import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.10
import org.kde.kquickcontrols 2.0

Item {

    property alias cfg_websliceUrl: websliceUrl.text
    property alias cfg_zoomFactor: zoomFactor.value
    property alias cfg_enableReload: enableReload.checked
    property alias cfg_reloadIntervalSec: reloadIntervalSec.value

    property alias cfg_reloadAnimation: reloadAnimation.checked

    property alias cfg_backgroundColorWhite: backgroundColorWhite.checked
    property alias cfg_backgroundColorTransparent: backgroundColorTransparent.checked
    property alias cfg_backgroundColorTheme: backgroundColorTheme.checked
    property alias cfg_backgroundColorCustom: backgroundColorCustom.checked
    property alias cfg_customBackgroundColor: customBackgroundColor.color
    
    property double maxWidth: width - 22

    GridLayout {
        Layout.fillWidth: true
        Layout.maximumWidth: maxWidth
        columns: 4
        rowSpacing: 20

        // URL
        GridLayout{
            Layout.fillWidth: true
            Layout.columnSpan: 4
            columns: 3
            
            Label {
                text: i18n('URL :')
                Layout.columnSpan: 1
            }

            TextField {
                id: websliceUrl
                placeholderText: 'URL'
                Layout.columnSpan: 2
                Layout.fillWidth: true
            }
        }
        
        // Zoom Factor
        GridLayout{
            Layout.fillWidth: true
            Layout.columnSpan: 4
            columns: 4
            
            Label {
                text: i18n('Zoom factor :')
                Layout.columnSpan: 1
            }

            Slider {
                id: zoomFactor
                from: 0.25
                to: 5
                value: 1
                stepSize: 0.25
                Layout.columnSpan: 2
                Layout.fillWidth: true
                
            }
                Label {
                    id:zoof
                    Layout.columnSpan: 1
                    text: zoomFactor.value+"x"
                    width:35
                    //anchors.horizontalCenter: parent.horizontalCenter
                    //anchors.bottom: parent.top
                    Layout.minimumWidth:35
                    Layout.maximumWidth:35
                }
        }

        // Auto reload
        GridLayout{
            Layout.fillWidth: true
            Layout.columnSpan: 4
            columns: 3
            
            CheckBox {
                id: enableReload
                text: i18n('Enable auto reload')
                Layout.columnSpan: 3
            }

            Label {
                text: i18n('Reload interval :')
                enabled: enableReload.checked
                Layout.columnSpan: 1
                Layout.fillWidth: true
            }

            SpinBox {
                id: reloadIntervalSec
                enabled: enableReload.checked
                from: 15
                to: 360000
                stepSize: 15
		valueFromText: function(text, locale) {
		    var text2 = text
			.replace(/[^\-\.\d]/g, '') // Remove non digit characters
			.replace(/\.+/g, '.') // Allow user to type '.' instead of RightArrow to enter to decimals
			.replace(/ sec$/, '') // Remove the second abbreviation.  FIXME: i18nc
		    var val = Number(text2)
		    if (isNaN(val)) {
			val = -0
		    }
		    // console.log('valueFromText', text, val)
		    var factor = Math.pow(10,0)
		    return Math.round(val * factor)
		}
                textFromValue: function(value, locale) {
                    return i18nc('Abbreviation for seconds', '%1 sec', value);
                }
                Layout.columnSpan: 2
            }
        }

        // Loading animation
        ColumnLayout{
            Layout.fillWidth: true
            Layout.columnSpan: 4
            
            CheckBox {
                id: reloadAnimation
                text: i18n('Display loading animation')
            }
        }

        // Plasmoid background color
        ColumnLayout{
            Layout.fillWidth: true
            Layout.columnSpan: 4           
            
            Label {
                Layout.fillWidth: true
                text: i18n('Plasmoid background color :')
            }
            
            ButtonGroup {
                id: backgroundColorGroup
            }

            ColumnLayout {

                RadioButton {
                    id: backgroundColorWhite
                    text: i18n("White")
                    ButtonGroup.group: backgroundColorGroup
                }

                RadioButton {
                    id: backgroundColorTransparent
                    text: i18n("Transparent <i>(⚠ might cause drawing issues)</i>")
                    ButtonGroup.group: backgroundColorGroup
                }
                
                RadioButton {
                    id: backgroundColorTheme
                    text: i18n("Theme's background color")
                    ButtonGroup.group: backgroundColorGroup
                }
                
                RowLayout{
                    RadioButton {
                        id: backgroundColorCustom
                        text: i18n("Custom")
                        ButtonGroup.group: backgroundColorGroup
                    }
                    ColorButton {
                        id: customBackgroundColor
                        showAlphaChannel:true
                        enabled: backgroundColorCustom.checked
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                font.italic: true
                text: i18n('Note that the background color will only be visible if the page background is also transparent or not set. This setting is for the background of the plasmoid, not of the page.')
                wrapMode: Text.Wrap
                Layout.maximumWidth: maxWidth
            }
        }
    }
}
