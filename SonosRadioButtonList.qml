import QtQuick 2.1

import qb.components 1.0
import BasicUIControls 1.0;

/**
 * A component that represents a radiobutton list
 *
 * In a group of radio buttons, only one radio button can be checked at a time.
 * If the user selects another button, the previously selected button is switched off.
 */

Item {
	id: sonosRadioButtonList

	implicitWidth: Math.max(listHeader.implicitWidth, listView.implicitWidth)
	implicitHeight: (listHeader.text ? listHeader.height + listView.anchors.topMargin : 0) +
					count * (count ? listView.contentItem.children[0].height : 0) +
					(count ? (count - 1) * listView.spacing : 0)

	property string title
	property int gridWidth
	property int gridHeight
	
	property int gridCellWidth:200
	property int gridCellHeight : 50
	
	property int dotOffset: 2
	property int radius: 8
	property int spacing: 8
	property int dotRadius: 5
	property int smallDotRadius: 5

	property string fontFamily: qfont.regular.name
	property string fontPixelSize: qfont.bodyText
	property string backgroundColor: colors.rbBackground

	property string smallDotColor: "grey"
	property string smallDotShadowColor: "white"
	property int shadowPixelSizeSmallDot: 1
	property int radioWidth: 100
	property int radioHeight:40
	
	property alias currentIndex: radioGroup.currentControlId

	property alias count: listView.count
	property alias listDelegate: listView.delegate


	property int radioLabelWidth: 0

	function addItem(text) {
		listModel.append({"itemtext": text,"itemEnabled": true, "controlGroup": radioGroup});
	}

	function addCustomItem(item) {
		item.controlGroup = radioGroup;
		item.itemEnabled = true;
		listModel.append(item);
	}

	function setItemEnabled(index,enabled) {
		if(enabled === false) {
			listModel.setProperty(index, "itemEnabled", false);
		} else {
			listModel.setProperty(index, "itemEnabled", true);
		}
	}

	function getModelItem(index) {
		if (index < 0 || index >= listModel.count) {
			return undefined
		} else {
			return listModel.get(index)
		}
	}

	function forceLayout() {
		listView.forceLayout()
	}

	function clearModel() {
		listModel.clear();
		listView.forceLayout()
	}


Rectangle {
		id: frame
		width: parent.width
		height: parent.height
		color: colors.canvas
		
		ListModel {
			id: listModel
		}
		
		GridView {
			id: listView
			anchors.fill: parent
			cellWidth: gridCellWidth
			cellHeight: gridCellHeight
			model: listModel
			delegate: listDelegate
			highlightRangeMode : ListView.StrictlyEnforceRange
			highlightFollowsCurrentItem : false
			interactive: false
		}
		
		ControlGroup {
			id: radioGroup
			exclusive: true
		}

		Component {
			id: listDelegate

			StandardRadioButton {
				id: radioButton
				dotOffset: dotOffset
				radius: designElements.radius
				spacing: spacing
				dotRadius: dotRadius
				smallDotRadius: smallDotRadius

				fontFamily: qfont.regular.name
				fontPixelSize: qfont.bodyText
				backgroundColor: colors.canvas

				smallDotColor: smallDotColor
				smallDotShadowColor: smallDotShadowColor
				shadowPixelSizeSmallDot: 1
				
				width: radioWidth
				height:radioHeight
				controlGroupId: index
				controlGroup: radioGroup
				text: model.itemtext ? model.itemtext : ""
				enabled: model.itemEnabled
				selected: model.selected ? true : false
				property string kpiId: title + ".radioButton" + index
				ListView.onAdd: ListView.view.maxWidth = Math.max(ListView.view.maxWidth, implicitWidth)
			}
		}
	}

}
