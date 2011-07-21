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
package org.vostokframework.loadingmanagement.domain.loaders
{
	import org.as3utils.URLUtil;
	import org.vostokframework.VostokFramework;
	import org.vostokframework.assetmanagement.domain.Asset;
	import org.vostokframework.assetmanagement.domain.AssetType;
	import org.vostokframework.assetmanagement.domain.settings.ApplicationDomainSetting;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingSecuritySettings;
	import org.vostokframework.assetmanagement.domain.settings.AssetLoadingSettings;
	import org.vostokframework.assetmanagement.domain.settings.SecurityDomainSetting;
	import org.vostokframework.loadingmanagement.domain.PlainLoader;

	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoaderFactory
	{
		

		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function AssetLoaderFactory()
		{
			
		}
		
		public function create(asset:Asset):AssetLoader
		{
			var fileLoader:PlainLoader = getFileLoader(asset.type, asset.src, asset.settings);
			var assetLoader:AssetLoader = new AssetLoader(asset.identification.toString(), asset.priority, fileLoader, asset.settings.policy.maxAttempts);
			return assetLoader;
			
			//TODO:settings.policy.latencyTimeout
		}
		
		protected function getFileLoader(type:AssetType, url:String, settings:AssetLoadingSettings):PlainLoader
		{
			var killExternalCache:Boolean = settings.cache.killExternalCache;
			var baseURL:String = settings.extra.baseURL;
			
			url = parseUrl(url, killExternalCache, baseURL);
			
			if (type.equals(AssetType.IMAGE))
			{
				var loader:Loader = new Loader();
				var request:URLRequest = new URLRequest(url);
				var loaderContext:LoaderContext = createLoaderContext(settings.security);
				
				return new VostokLoader(loader, request, loaderContext);
			}
			
			//TODO:settings.extra.userDataContainer
			//TODO:settings.extra.userTotalBytes
			
			//TODO:settings.media.audioLinkage
			//TODO:settings.media.autoCreateVideo
			//TODO:settings.media.autoResizeVideo
			//TODO:settings.media.autoStopStream
			//TODO:settings.media.bufferPercent
			//TODO:settings.media.bufferTime
			
			return null;
		}
		
		protected function parseUrl(url:String, killExternalCache:Boolean, baseURL:String):String
		{
			if (killExternalCache) url = URLUtil.appendVar(url, VostokFramework.KILL_CACHE_VAR_NAME, String(new Date().getTime()));
			if (baseURL != null) url = baseURL + url;
			
			return url;
		}
		
		protected function createLoaderContext(security:AssetLoadingSecuritySettings):LoaderContext
		{
			var checkPolicyFile:Boolean = security.checkPolicyFile;
			var ignoreLocalSecurityDomain:Boolean = security.ignoreLocalSecurityDomain;
			
			var applicationDomain:ApplicationDomain = getApplicationDomain(security.applicationDomain);
			var securityDomain:SecurityDomain = getSecurityDomain(security.securityDomain);
			
			//if (ignoreLocalSecurityDomain && isLocal) securityDomain = null;//TODO:implement it
			
			return new LoaderContext(checkPolicyFile, applicationDomain, securityDomain);
		}
		
		protected function getApplicationDomain(setting:ApplicationDomainSetting):ApplicationDomain
		{
			if (!setting) return null;
			
			var applicationDomain:ApplicationDomain;
			
			if (setting.equals(ApplicationDomainSetting.APART))
			{
				applicationDomain = new ApplicationDomain();
			}
			else if (setting.equals(ApplicationDomainSetting.CHILD))
			{
				applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			}
			else if (setting.equals(ApplicationDomainSetting.CURRENT))
			{
				applicationDomain = ApplicationDomain.currentDomain;
			}
			
			return applicationDomain;
		}
		
		protected function getSecurityDomain(setting:SecurityDomainSetting):SecurityDomain
		{
			if (!setting) return null;
			
			var securityDomain:SecurityDomain;
			
			if (setting.equals(SecurityDomainSetting.CURRENT))
			{
				securityDomain = SecurityDomain.currentDomain;
			}
			
			return securityDomain;
		}
		
	}

}