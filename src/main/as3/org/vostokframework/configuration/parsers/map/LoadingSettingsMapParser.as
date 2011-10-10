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
package org.vostokframework.configuration.parsers.map
{
	import org.as3collections.IMap;
	import org.vostokframework.configuration.ConfigurationElementNames;
	import org.vostokframework.domain.loading.ILoadingSettingsFactory;
	import org.vostokframework.domain.loading.settings.LoadingSettings;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingSettingsMapParser
	{
		
		private var _configurationElementNames:ConfigurationElementNames;
		private var _loadingSettingsFactory:ILoadingSettingsFactory;
		
		/**
		 * description
		 */
		public function LoadingSettingsMapParser(configurationElementNames:ConfigurationElementNames, loadingSettingsFactory:ILoadingSettingsFactory)
		{
			_configurationElementNames = configurationElementNames;
			_loadingSettingsFactory = loadingSettingsFactory;
		}
		
		public function parse(settings:IMap):LoadingSettings
		{
			if (!settings || settings.isEmpty()) return null;
			
			var $settings:LoadingSettings = _loadingSettingsFactory.create();
			
			var loadingCacheSettingsMapParser:LoadingCacheSettingsMapParser = new LoadingCacheSettingsMapParser(_configurationElementNames);
			loadingCacheSettingsMapParser.parse($settings.cache, settings);
			
			return $settings;
		}
		
	}

}