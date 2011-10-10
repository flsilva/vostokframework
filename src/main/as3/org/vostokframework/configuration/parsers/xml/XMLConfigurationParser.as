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
	import org.as3collections.ICollection;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.configuration.VostokFrameworkConfiguration;
	import org.vostokframework.configuration.parsers.IConfigurationParser;
	import org.vostokframework.domain.loading.ILoadingSettingsFactory;
	import org.vostokframework.domain.loading.settings.LoadingSettings;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class XMLConfigurationParser implements IConfigurationParser
	{
		 
		private static const DEFAULT_SETTINGS_NODE_NAME:String = "default-settings";
		private static const PACKAGES_NODE_NAME:String = "packages";
		 
		private var _assetPackageParser:AssetPackageXMLNodeParser;
		private var _settingsParser:LoadingSettingsXMLNodeParser;
		private var _settingsFactory:ILoadingSettingsFactory;
		
		/**
		 * description
		 */
		public function XMLConfigurationParser(assetPackageParser:AssetPackageXMLNodeParser, settingsParser:LoadingSettingsXMLNodeParser, settingsFactory:ILoadingSettingsFactory)
		{
			_assetPackageParser = assetPackageParser;
			_settingsParser = settingsParser;
			_settingsFactory = settingsFactory;
		}
		
		public function parse(configuration:*):VostokFrameworkConfiguration
		{
			if (!configuration) throw new ArgumentError("Argument <configuration> must not be null.");
			if (!(configuration as XML))
			{
				var errorMessage:String = "Argument <configuration> must be of type XML.\n";
				errorMessage += "Received type: " + ReflectionUtil.getClassPath(configuration) + "\n";
				errorMessage += "Received object: " + configuration;
				
				throw new ArgumentError(errorMessage);
			}
			
			var settingsNode:XML = (configuration as XML).children().(name().localName == DEFAULT_SETTINGS_NODE_NAME)[0];
			
			var defaultSettings:LoadingSettings = _settingsParser.parse(settingsNode);
			if (defaultSettings) _settingsFactory.setDefaultLoadingSettings(defaultSettings);
			
			var packagesNode:XMLList = (configuration as XML).children().(name().localName == PACKAGES_NODE_NAME);
			var packages:ICollection = _assetPackageParser.parse(packagesNode);
			
			var $configuration:VostokFrameworkConfiguration = new VostokFrameworkConfiguration(defaultSettings, packages);
			return $configuration;
		}
		
	}

}