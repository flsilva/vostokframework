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
package org.vostokframework.assetmanagement.domain.settings
{

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class AssetLoadingSettings
	{
		/**
		 * description
		 */
		private var _cache:AssetLoadingCacheSettings;
		private var _extra:AssetLoadingExtraSettings;
		private var _media:AssetLoadingMediaSettings;
		private var _policy:AssetLoadingPolicySettings;
		private var _security:AssetLoadingSecuritySettings;
		
		/**
		 * description
		 */
		public function get cache(): AssetLoadingCacheSettings { return _cache; }
		
		public function set cache(value:AssetLoadingCacheSettings): void
		{
			if (!value) throw new ArgumentError("Value must not be null.");
			_cache = value;
		}

		/**
		 * description
		 */
		public function get extra(): AssetLoadingExtraSettings { return _extra; }
		
		public function set extra(value:AssetLoadingExtraSettings): void
		{
			if (!value) throw new ArgumentError("Value must not be null.");
			_extra = value;
		}

		/**
		 * description
		 */
		public function get media(): AssetLoadingMediaSettings { return _media; }
		
		public function set media(value:AssetLoadingMediaSettings): void
		{
			if (!value) throw new ArgumentError("Value must not be null.");
			_media = value;
		}

		/**
		 * description
		 */
		public function get policy(): AssetLoadingPolicySettings { return _policy; }
		
		public function set policy(value:AssetLoadingPolicySettings): void
		{
			if (!value) throw new ArgumentError("Value must not be null.");
			_policy = value;
		}

		/**
		 * description
		 */
		public function get security(): AssetLoadingSecuritySettings { return _security; }
		
		public function set security(value:AssetLoadingSecuritySettings): void
		{
			if (!value) throw new ArgumentError("Value must not be null.");
			_security = value;
		}
		
		/**
		 * description
		 * 
		 * @param policy
		 * @param cache
		 * @param security
		 * @param media
		 * @param extra
		 */
		public function AssetLoadingSettings()
		{
			
		}

	}

}