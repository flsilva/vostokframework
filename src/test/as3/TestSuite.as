/*
 * Licensed under the MIT License
 * 
 * Copyright 2010 (c) Flávio Silva, http://flsilva.com
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

package 
{
	import org.vostokframework.AssetPackageServiceTests;
	import org.vostokframework.AssetServiceTests;
	import org.vostokframework.assetmanagement.AssetFactoryTests;
	import org.vostokframework.assetmanagement.AssetPackageFactoryTests;
	import org.vostokframework.assetmanagement.AssetPackageRepositoryTests;
	import org.vostokframework.assetmanagement.AssetPackageTests;
	import org.vostokframework.assetmanagement.AssetRepositoryTests;
	import org.vostokframework.assetmanagement.AssetTests;
	import org.vostokframework.assetmanagement.UrlAssetParserTests;
	import org.vostokframework.assetmanagement.utils.LocaleUtilTests;
	import org.vostokframework.loadingmanagement.AssetLoaderQueueManagerTests;
	import org.vostokframework.loadingmanagement.RequestLoaderManagerTests;
	import org.vostokframework.loadingmanagement.RequestLoaderQueueManagerTests;
	import org.vostokframework.loadingmanagement.RequestLoaderTests;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoaderTests;
	import org.vostokframework.loadingmanagement.assetloaders.AssetLoaderTestsLoad;
	import org.vostokframework.loadingmanagement.assetloaders.VostokLoaderTests;
	import org.vostokframework.loadingmanagement.monitors.AssetLoadingMonitorTests;
	import org.vostokframework.loadingmanagement.monitors.RequestLoadingMonitorTests;

	/**
	 * @author Flávio Silva
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuite
	{
		
		//org.vostokframework
		public var assetServiceTests:AssetServiceTests;
		public var assetPackageServiceTests:AssetPackageServiceTests;
		
		//org.vostokframework.assetmanagement
		public var assetTests:AssetTests;
		public var assetFactoryTests:AssetFactoryTests;
		public var assetPackageTests:AssetPackageTests;
		public var assetPackageFactoryTests:AssetPackageFactoryTests;
		public var assetRepositoryTests:AssetRepositoryTests;
		public var assetPackageRepositoryTests:AssetPackageRepositoryTests;
		public var urlAssetParserTests:UrlAssetParserTests;
		
		//org.vostokframework.assetmanagement.utils
		public var localeUtilTests:LocaleUtilTests;
		
		//org.vostokframework.loadingmanagement
		public var assetLoaderQueueManagerTests:AssetLoaderQueueManagerTests;
		public var requestLoaderTests:RequestLoaderTests;
		public var requestLoaderManagerTests:RequestLoaderManagerTests;
		public var requestLoaderQueueManagerTests:RequestLoaderQueueManagerTests;
		
		//org.vostokframework.loadingmanagement.assetloaders
		public var assetLoaderTests:AssetLoaderTests;
		public var assetLoaderTestsLoad:AssetLoaderTestsLoad;
		public var vostokLoaderTests:VostokLoaderTests;
		
		//org.vostokframework.loadingmanagement.monitors
		public var assetLoadingMonitorTests:AssetLoadingMonitorTests;
		public var requestLoadingMonitorTests:RequestLoadingMonitorTests;
		
		public function TestSuite()
		{
			
		}

	}

}