/*
 * Licensed under the MIT License
 * 
 * Copyright 2011 (c) Flávio Silva, flsilva.com
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * http://www.opensource.org/licenses/mit-license.php
 */
package org.vostokframework.configuration.parsers.xml
{
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.utils.ListUtil;
	import org.as3collections.utils.MapUtil;
	import org.vostokframework.configuration.AssetConfiguration;
	import org.vostokframework.configuration.parsers.xml.errors.XMLConfigurationParserError;
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.loading.settings.LoadingSettings;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetXMLNodeParser
	{
		
		private static const ASSET_ID_ATTRIBUTE_NAME:String = "id";
		private static const ASSET_SRC_ATTRIBUTE_NAME:String = "src";
		private static const ASSET_TYPE_ATTRIBUTE_NAME:String = "type";
		private static const SETTINGS_NODE_NAME:String = "settings";
		
		private var _settingsParser:LoadingSettingsXMLNodeParser;
		
		/**
		 * description
		 */
		public function AssetXMLNodeParser(settingsParser:LoadingSettingsXMLNodeParser)
		{
			_settingsParser = settingsParser;
		}
		
		public function parse(assets:XMLList):IList
		{
			if (!assets) return null;
			
			var $assets:IList = parseAssets(assets);
			return $assets;
		}
		
		private function parseAssets(assetsXmlList:XMLList):IList
		{
			if (!assetsXmlList) return null;
			
			var assets:IList = ListUtil.getTypedList(new ArrayList(), AssetConfiguration);
			var assetConfiguration:AssetConfiguration;
			var assetAttributesMap:IMap;
			var id:String;
			var src:String;
			var type:AssetType;
			var settingsNode:XML = <settings></settings>;
			var settingsXMLList:XMLList;
			var settings:LoadingSettings;
			
			for each (var assetNode:XML in assetsXmlList)
			{
				assetAttributesMap = new HashMap();
				MapUtil.feedMapWithXmlList(assetAttributesMap, assetNode.attributes());
				
				if (!assetAttributesMap.containsKey(ASSET_SRC_ATTRIBUTE_NAME))
				{
					var errorMessage:String = "Asset node must have < " + ASSET_SRC_ATTRIBUTE_NAME + "> attribute.";
					throw new XMLConfigurationParserError(errorMessage);
				}
				
				id = assetAttributesMap.getValue(ASSET_ID_ATTRIBUTE_NAME);
				src = assetAttributesMap.getValue(ASSET_SRC_ATTRIBUTE_NAME);
				if (assetAttributesMap.containsKey(ASSET_TYPE_ATTRIBUTE_NAME))
				{
					type = AssetType.getByName(assetAttributesMap.getValue(ASSET_TYPE_ATTRIBUTE_NAME));
				}
				
				//convert attributes to nodes and append into settings
				settingsXMLList = assetNode.attributes();
				for each(var att:XML in settingsXMLList)
				{
					settingsNode.appendChild(<{att.localName()}>{att.toString()}</{att.localName()}>);
				}
				//
				
				//merge settings nodes together with attributes settings
				settingsXMLList = assetNode.children().(name().localName == SETTINGS_NODE_NAME).children();
				settingsNode.appendChild(settingsXMLList);
				//
				
				settings = _settingsParser.parse(settingsNode);
				
				assetConfiguration = new AssetConfiguration(src, type, settings, id);
				assets.add(assetConfiguration);
			}
			
			return assets;
		}
		
	}

}