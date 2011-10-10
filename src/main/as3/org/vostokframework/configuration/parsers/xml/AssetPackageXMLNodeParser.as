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
	import org.vostokframework.configuration.AssetPackageConfiguration;
	import org.vostokframework.configuration.parsers.xml.errors.XMLConfigurationParserError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetPackageXMLNodeParser
	{
		
		private static const ASSET_NODE_NAME:String = "asset";
		private static const PACKAGE_NODE_NAME:String = "package";
		private static const PACKAGE_ID_ATTRIBUTE_NAME:String = "id";
		private static const PACKAGE_LOCALE_ATTRIBUTE_NAME:String = "locale";
		
		private var _assetXMLNodeParser:AssetXMLNodeParser;
		
		/**
		 * description
		 */
		public function AssetPackageXMLNodeParser(assetXMLNodeParser:AssetXMLNodeParser)
		{
			_assetXMLNodeParser = assetXMLNodeParser;
		}
		
		public function parse(node:XMLList):IList
		{
			if (!node) return null;
			
			var packagesXmlList:XMLList = node.children().(name().localName == PACKAGE_NODE_NAME);
			var packages:IList = parsePackages(packagesXmlList);
			return packages;
		}
		
		private function parsePackages(packagesXmlList:XMLList):IList
		{
			if (!packagesXmlList) return null;
			
			var packages:IList = ListUtil.getTypedList(new ArrayList(), AssetPackageConfiguration);
			var packageConfiguration:AssetPackageConfiguration;
			var packageAttributesMap:IMap;
			var id:String;
			var locale:String;
			var assets:IList;
			
			for each (var packageNode:XML in packagesXmlList)
			{
				packageAttributesMap = new HashMap();
				MapUtil.feedMapWithXmlList(packageAttributesMap, packageNode.attributes());
				
				if (!packageAttributesMap.containsKey(PACKAGE_ID_ATTRIBUTE_NAME))
				{
					var errorMessage:String = "XML node <" + PACKAGE_NODE_NAME + "> must have @" + PACKAGE_ID_ATTRIBUTE_NAME + " attribute.";
					throw new XMLConfigurationParserError(errorMessage);
				}
				
				id = packageAttributesMap.getValue(PACKAGE_ID_ATTRIBUTE_NAME);
				locale = packageAttributesMap.getValue(PACKAGE_LOCALE_ATTRIBUTE_NAME);
				
				var assetsXmlList:XMLList = packageNode.children().(name().localName == ASSET_NODE_NAME);
				assets = _assetXMLNodeParser.parse(assetsXmlList);
				
				packageConfiguration = new AssetPackageConfiguration(id, locale, assets);
				packages.add(packageConfiguration);
			}
			
			return packages;
		}
		
	}

}