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
package org.vostokframework.application
{
	import org.as3collections.IMap;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.as3utils.ReflectionUtil;
	import org.vostokframework.domain.assets.Asset;
	import org.vostokframework.domain.loading.settings.LoadingSettings;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingSettingsRepository
	{
		private var _loadingSettingsMap:IMap; 

		/**
		 * description
		 */
		public function LoadingSettingsRepository()
		{
			// IMap<String, LoadingSettings>
			// Asset().identification.toString() used for performance optimization
			_loadingSettingsMap = new TypedMap(new HashMap(), String, LoadingSettings);
		}
		
		/**
		 * description
		 * 
		 * @param 	loader
		 * @throws 	ArgumentError 	if the <code>loader</code> argument is <code>null</code>.
		 * @throws 	org.vostokframework.loadermanagement.errors.DuplicateLoaderError 	if already exists an <code>ILoader</code> object stored with the same <code>id</code> of the provided <code>loader</code> argument.
		 * @return
		 */
		public function add(asset:Asset, settings:LoadingSettings): void
		{
			if (!asset) throw new ArgumentError("Argument <asset> must not be null.");
			if (!settings) throw new ArgumentError("Argument <settings> must not be null.");
			
			_loadingSettingsMap.put(asset.identification.toString(), settings);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function clear(): void
		{
			_loadingSettingsMap.clear();
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function exists(asset:Asset): Boolean
		{
			if (!asset) throw new ArgumentError("Argument <asset> must not be null.");
			
			return _loadingSettingsMap.containsKey(asset.identification.toString());
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function find(asset:Asset): LoadingSettings
		{
			if (!asset) throw new ArgumentError("Argument <asset> must not be null.");
			
			return _loadingSettingsMap.getValue(asset.identification.toString());
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function isEmpty(): Boolean
		{
			return _loadingSettingsMap.isEmpty();
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function remove(asset:Asset): Boolean
		{
			if (!asset) throw new ArgumentError("Argument <asset> must not be null.");
			
			if (!exists(asset)) return false;
			
			return _loadingSettingsMap.remove(asset.identification.toString());
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function size(): int
		{
			return _loadingSettingsMap.size();
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function toString(): String
		{
			return "[" + ReflectionUtil.getClassName(this) + "] <" + _loadingSettingsMap.getValues() + ">";
		}
		
	}

}