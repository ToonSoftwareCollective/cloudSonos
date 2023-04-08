//////  MODIFIED BUTTON BY OEPI-LOEPI for TOON


import QtQuick 2.1
import BasicUIControls 1.0

Item {
	id: sonosButton

	width: 430
	height: defaultHeight
	property int defaultHeight: 36

	property string buttonText
	property alias labelFontFamily: labelTitle.font.family
	property alias labelFontSize: labelTitle.font.pixelSize
    property string buttonActiveColor : "grey"
 	property string buttonHoverColor : "blue"
 	property string buttonDisabledColor  : "lightgrey"
	property string textColor : "black"
	property string textDisabledColor : "grey"

	signal clicked()

    function doClick(){

        clicked();
    }

	Rectangle {
		id: buttonRect
		anchors {
			fill: parent
			leftMargin: 5
			topMargin: 5
			rightMargin: 5
			bottomMargin: 5
		}
		border.color: "black"
		border.width: 0
		color: buttonActiveColor
		radius: designElements.radius
		//onClicked: sonosButton.clicked()
		Text {
			id: labelTitle
			anchors {
				verticalCenter: parent.verticalCenter
				horizontalCenter: parent.horizontalCenter				
			}
			font {
				family: qfont.semiBold.name
				//pixelSize: qfont.titleText
				pixelSize:isNxt ? 20 : 16
			}
			text: buttonText
			color: sonosButton.enabled? textColor: textDisabledColor
		}
		        state: sonosButton.enabled ? "active" : "disabled"
       
 	Component.onCompleted: state = state

        states: [
            State {
                name: "hover"
                when: buttonArea.containsMouse || sonosButton.focus
                PropertyChanges {
                    target: buttonRect
                    color: buttonHoverColor
                }
            },
            State {
                name: "active"
                when: sonosButton.enabled
                PropertyChanges {
                    target: buttonRect
                    color: buttonActiveColor
                }
            },
            State {
                name: "disabled"
                when: !sonosButton.enabled
                PropertyChanges {
                    target: buttonRect
                    color: buttonDisabledColor
                }
            }
        ]
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: doClick()
        cursorShape: Qt.PointingHandCursor
    }

}
