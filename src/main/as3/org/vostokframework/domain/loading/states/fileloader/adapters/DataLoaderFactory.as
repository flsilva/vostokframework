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
package org.vostokframework.domain.loading.states.fileloader.adapters
{
	import org.as3coreaddendum.errors.IllegalStateError;
	import org.vostokframework.domain.assets.AssetType;
	import org.vostokframework.domain.loading.settings.ApplicationDomainSetting;
	import org.vostokframework.domain.loading.settings.LoadingSecuritySettings;
	import org.vostokframework.domain.loading.settings.LoadingSettings;
	import org.vostokframework.domain.loading.settings.SecurityDomainSetting;
	import org.vostokframework.domain.loading.states.fileloader.IDataLoader;
	import org.vostokframework.domain.loading.states.fileloader.IDataLoaderFactory;

	import flash.display.Loader;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class DataLoaderFactory implements IDataLoaderFactory
	{
		
		/**
		 * description
		 * 
		 */
		public function DataLoaderFactory()
		{
			
		}
		
		public function create(type:AssetType, url:String, settings:LoadingSettings):IDataLoader
		{
			var dataLoader:IDataLoader;
			var urlRequest:URLRequest = new URLRequest(url);
			
			switch(type)
			{
				case AssetType.IMAGE:
				case AssetType.SWF:
				{
					var loader:Loader = new Loader();
					var loaderContext:LoaderContext = createLoaderContext(settings.security);
					
					dataLoader = new NativeLoaderAdapter(loader, urlRequest, loaderContext);
					break;
				}
				
				case AssetType.CSS:
				case AssetType.JSON:
				case AssetType.TXT:
				case AssetType.XML:
				{
					var urlLoader:URLLoader = new URLLoader();
					urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
					
					dataLoader = new NativeURLLoaderAdapter(urlLoader, urlRequest);
					break;
				}
				
				case AssetType.AAC:
				case AssetType.VIDEO:
				{
					var netConnection:NetConnection = new NetConnection();
					netConnection.connect(null);
					
					var netStream:NetStream = new NetStream(netConnection);
					netStream.bufferTime = settings.media.bufferTime;
					netStream.checkPolicyFile = settings.security.checkPolicyFile;
					
					dataLoader = new NativeNetStreamAdapter(netStream, netConnection, urlRequest);
					dataLoader = new ProgressNetStream(dataLoader, netStream, settings.media.bufferPercent);
					
					if (settings.media.autoStopStream) dataLoader = new AutoStopNetStream(dataLoader, netStream);
					
					if (settings.media.autoCreateVideo)
					{
						dataLoader = new AutoCreateNetStreamVideo(dataLoader, netStream);
						if (settings.media.autoResizeVideo)
						{
							dataLoader = new AutoResizeNetStreamVideo(dataLoader, netStream);
						}
					}
					
					break;
				}
				
			}
			
			if (!dataLoader)
			{
				var errorMessage:String = "It was not possible to create a NativeDataLoader object for the received type:\n";
				errorMessage = "<type>: " + type + "\n";
				errorMessage = "<url>: " + url + "\n";
				
				throw new IllegalStateError(errorMessage);
			}
			
			//TODO:settings.media.audioLinkage
			
			return dataLoader;
		}
		
		protected function createLoaderContext(security:LoadingSecuritySettings):LoaderContext
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