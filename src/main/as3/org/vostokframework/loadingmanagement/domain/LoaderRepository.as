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
package org.vostokframework.loadingmanagement.domain
{
	import org.as3collections.lists.TypedList;
	import org.as3collections.IIterator;
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.lists.ArrayList;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.lists.UniqueList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.as3utils.ReflectionUtil;
	import org.as3utils.StringUtil;
	import org.vostokframework.loadingmanagement.domain.errors.DuplicateLoaderError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoaderRepository
	{
		private var _loaderMap:IMap;//key = AssetLoader().id (String) | value = AssetLoader 

		/**
		 * description
		 */
		public function LoaderRepository()
		{
			_loaderMap = new TypedMap(new HashMap(), String, StatefulLoader);
		}
		
		/**
		 * description
		 * 
		 * @param 	loader
		 * @throws 	ArgumentError 	if the <code>loader</code> argument is <code>null</code>.
		 * @throws 	org.vostokframework.loadermanagement.errors.DuplicateStatefulLoaderError 	if already exists an <code>StatefulLoader</code> object stored with the same <code>id</code> of the provided <code>loader</code> argument.
		 * @return
		 */
		public function add(loader:StatefulLoader): void
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			
			if (_loaderMap.containsKey(loader.id))
			{
				var message:String = "There is already an StatefulLoader object stored with id:\n";
				message += "<" + loader.id + ">\n";
				message += "Use the method <StatefulLoaderRepository().exists()> to check if a StatefulLoader object already exists.\n";
				message += "For further information please read the documentation section about the StatefulLoader object.";
				
				throw new DuplicateLoaderError(loader.id, message);
			}
			
			_loaderMap.put(loader.id, loader);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function clear(): void
		{
			_loaderMap.clear();
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function exists(loaderId:String): Boolean
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			return _loaderMap.containsKey(loaderId);
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function find(loaderId:String): StatefulLoader
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			return _loaderMap.getValue(loaderId);
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function findAll(): IList
		{
			if (isEmpty()) return null;
			var l:IList = new ReadOnlyArrayList(_loaderMap.getValues().toArray());
			
			return l;
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function findAllLoading(): IList
		{
			var list1:IList = new ArrayList(findByStatus(LoaderStatus.CONNECTING).toArray());
			var list2:IList = new ArrayList(findByStatus(LoaderStatus.LOADING).toArray());
			//TODO: otimizar
			var unique:UniqueList = new UniqueList(new ArrayList());
			unique.addAll(list1);
			unique.addAll(list2);
			
			return new ReadOnlyArrayList(unique.toArray());
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function findByStatus(status:LoaderStatus): IList
		{
			if (!status) throw new ArgumentError("Argument <status> must not be null.");
			
			var it:IIterator = _loaderMap.getValues().iterator();
			var loader:StatefulLoader;
			var list:IList = new ArrayList();
			
			while (it.hasNext())
			{
				loader = it.next();
				if (loader.status.equals(status))
				{
					list.add(loader);
				}
			}
			
			return new ReadOnlyArrayList(list.toArray());
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function isEmpty(): Boolean
		{
			return _loaderMap.isEmpty();
		}

		/**
		 * description
		 * 
		 * @param 	loaderId    
		 * @throws 	ArgumentError 	if the <code>loaderId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function remove(loaderId:String): Boolean
		{
			if (StringUtil.isBlank(loaderId)) throw new ArgumentError("Argument <loaderId> must not be null nor an empty String.");
			
			return _loaderMap.remove(loaderId) != null;
		}
		
		/**
		 * description
		 * 
		 * @param 	loaders    
		 * @throws 	ArgumentError 	if the <code>loaders</code> argument is <code>null</code>.
		 * @return
		 */
		public function removeAll(loaders:IList): Boolean
		{
			if (!loaders) throw new ArgumentError("Argument <loaders> must not be null.");
			if (loaders.isEmpty()) return false;
			
			var prevSize:int = size();
			var $loaders:IList = new TypedList(loaders, StatefulLoader);
			var it:IIterator = $loaders.iterator();
			var loader:StatefulLoader;
			
			while (it.hasNext())
			{
				loader = it.next();
				remove(loader.id);
			}
			
			return size() != prevSize;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function size(): int
		{
			return _loaderMap.size();
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function toString(): String
		{
			return "[" + ReflectionUtil.getClassName(this) + "] <" + _loaderMap.getValues() + ">";
		}
		
		public function totalLoading():int
		{
			var loadings:IList = findAllLoading();
			if (!loadings) return 0;
			return loadings.size();
		}

	}

}