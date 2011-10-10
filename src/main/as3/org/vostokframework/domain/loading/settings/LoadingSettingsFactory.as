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
package org.vostokframework.domain.loading.settings
{
	import org.vostokframework.domain.loading.ILoadingSettingsFactory;
	import org.vostokframework.domain.loading.LoadPriority;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingSettingsFactory implements ILoadingSettingsFactory
	{
		/**
		 * @private
		 */
		private var _defaultLoadingSettings:LoadingSettings;
		
		public function get defaultLoadingSettings(): LoadingSettings { return _defaultLoadingSettings; }
		
		/**
		 * description
		 * 
		 * @param asset
		 * @param fileLoader
		 */
		public function LoadingSettingsFactory()
		{
			var defaultLoadingSettings:LoadingSettings = createDefaultLoadingSettings();
			setDefaultLoadingSettings(defaultLoadingSettings);
		}
		
		public function create():LoadingSettings
		{
			return _defaultLoadingSettings.clone();
		}
		
		/**
		 * description
		 * 
		 * @param settings
		 * @throws 	ArgumentError 	if the <code>settings</code> argument is <code>null</code>.
		 */
		public function setDefaultLoadingSettings(settings:LoadingSettings): void
		{
			if (!settings) throw new ArgumentError("Argument <settings> must not be null.");
			_defaultLoadingSettings = settings;
		}
		
		/**
		 * @private
		 */
		protected function createDefaultLoadingSettings():LoadingSettings
		{
			var cache:LoadingCacheSettings = new LoadingCacheSettings();
			var extra:LoadingExtraSettings = new LoadingExtraSettings();
			var media:LoadingMediaSettings = new LoadingMediaSettings();
			var policy:LoadingPolicySettings = new LoadingPolicySettings();
			var security:LoadingSecuritySettings = new LoadingSecuritySettings();
			
			cache.allowInternalCache = true;
			cache.killExternalCache = false;
			
			media.autoCreateVideo = false;
			media.autoResizeVideo = false;
			media.autoStopStream = false;
			media.bufferPercent = .1;
			
			policy.latencyTimeout = 12000;
			policy.maxAttempts = 2;
			policy.priority = LoadPriority.MEDIUM;
			
			var settings:LoadingSettings = new LoadingSettings();
			settings.cache = cache;
			settings.extra = extra;
			settings.media = media;
			settings.policy = policy;
			settings.security = security;
			
			return settings;
		}
		
	}

}