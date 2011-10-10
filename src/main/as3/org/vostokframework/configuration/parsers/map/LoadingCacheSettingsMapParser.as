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
	import org.vostokframework.configuration.parsers.errors.ConfigurationParserError;
	import org.vostokframework.domain.loading.settings.LoadingCacheSettings;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingCacheSettingsMapParser
	{
		
		private var _configurationElementNames:ConfigurationElementNames;
		
		/**
		 * description
		 */
		public function LoadingCacheSettingsMapParser(configurationElementNames:ConfigurationElementNames)
		{
			_configurationElementNames = configurationElementNames;
		}
		
		public function parse(cacheSettings:LoadingCacheSettings, settingsMap:IMap):void
		{
			if (!settingsMap || settingsMap.isEmpty()) return;
			if (!cacheSettings) cacheSettings = new LoadingCacheSettings();
			
			if (settingsMap.containsKey(_configurationElementNames.allowInternalCache))
			{
				var allowInternalCache:* = settingsMap.getValue(_configurationElementNames.allowInternalCache);
				
				if (!(allowInternalCache is Boolean))
				{
					throwInvalidBooleanStringError(allowInternalCache, _configurationElementNames.allowInternalCache);
				}
				
				cacheSettings.allowInternalCache = allowInternalCache;
			}
			
			if (settingsMap.containsKey(_configurationElementNames.killExternalCache))
			{
				var killExternalCache:* = settingsMap.getValue(_configurationElementNames.killExternalCache);
				
				if (!(killExternalCache is Boolean))
				{
					throwInvalidBooleanStringError(killExternalCache, _configurationElementNames.killExternalCache);
				}
				
				cacheSettings.killExternalCache = killExternalCache;
			}
		}
		
		private function throwInvalidBooleanStringError(value:String, setting:String):void
		{
			var errorMessage:String = "Setting < " + setting + "> must be a valid Boolean String (\"true\" or \"false\").\n";
			errorMessage += "Received: <" + value + ">";
			
			throw new ConfigurationParserError(errorMessage);
		}
		
	}

}