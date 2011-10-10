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
	import org.as3collections.IMap;
	import org.as3collections.maps.HashMap;
	import org.as3collections.utils.MapUtil;
	import org.vostokframework.configuration.parsers.map.LoadingSettingsMapParser;
	import org.vostokframework.domain.loading.ILoadingSettingsFactory;
	import org.vostokframework.domain.loading.settings.LoadingSettings;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingSettingsXMLNodeParser
	{
		private var _loadingSettingsFactory:ILoadingSettingsFactory;
		
		/**
		 * description
		 */
		public function LoadingSettingsXMLNodeParser(loadingSettingsFactory:ILoadingSettingsFactory)
		{
			_loadingSettingsFactory = loadingSettingsFactory;
		}
		
		public function parse(settings:XML):LoadingSettings
		{
			if (!settings) return null;
			
			var settingsMap:IMap = new HashMap();
			MapUtil.feedMapWithXmlList(settingsMap, settings.children());
			
			var xmlConfigurationElementNames:XMLConfigurationElementNames = new XMLConfigurationElementNames();
			var settingsMapParser:LoadingSettingsMapParser = new LoadingSettingsMapParser(xmlConfigurationElementNames, _loadingSettingsFactory);
			
			var $settings:LoadingSettings = settingsMapParser.parse(settingsMap);
			return $settings;
		}
		
	}

}