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
package org.vostokframework.application.services
{
	import org.vostokframework.application.LoadingContext;
	import org.vostokframework.configuration.VostokFrameworkConfiguration;
	import org.vostokframework.configuration.parsers.IConfigurationParser;
	import org.vostokframework.configuration.parsers.xml.AssetPackageXMLNodeParser;
	import org.vostokframework.configuration.parsers.xml.AssetXMLNodeParser;
	import org.vostokframework.configuration.parsers.xml.LoadingSettingsXMLNodeParser;
	import org.vostokframework.configuration.parsers.xml.XMLConfigurationParser;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class XMLConfigurationService
	{
		/**
		 * @private
		 */
		private var _loadingContext: LoadingContext;
		
		/**
		 * description
		 */
		public function XMLConfigurationService()
		{
			_loadingContext = LoadingContext.getInstance();
		}
		
		public function configure(configuration:XML): void
		{
			if (!configuration) throw new ArgumentError("Argument <configuration> must not be null.");
			
			var settingsParser:LoadingSettingsXMLNodeParser = new LoadingSettingsXMLNodeParser(_loadingContext.loadingSettingsFactory);
			var assetParser:AssetXMLNodeParser = new AssetXMLNodeParser(settingsParser);
			var assetPackageParser:AssetPackageXMLNodeParser = new AssetPackageXMLNodeParser(assetParser);
			
			var parser:IConfigurationParser = new XMLConfigurationParser(assetPackageParser, settingsParser, _loadingContext.loadingSettingsFactory);
			var $configuration:VostokFrameworkConfiguration = parser.parse(configuration);
			
			var configurationService:ConfigurationService = new ConfigurationService();
			configurationService.configure($configuration);
		}

	}

}