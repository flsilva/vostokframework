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
package org.vostokframework.loadingmanagement.domain.monitors
{
	import org.as3collections.IList;
	import org.as3collections.IMap;
	import org.as3collections.lists.ReadOnlyArrayList;
	import org.as3collections.maps.HashMap;
	import org.as3collections.maps.TypedMap;
	import org.as3utils.ReflectionUtil;
	import org.as3utils.StringUtil;
	import org.vostokframework.loadingmanagement.domain.errors.DuplicateLoadingMonitorError;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class LoadingMonitorRepository
	{
		private var _monitorMap:IMap;//key = ILoadingMonitor.id (String) | value = ILoadingMonitor 

		/**
		 * description
		 */
		public function LoadingMonitorRepository()
		{
			_monitorMap = new TypedMap(new HashMap(), String, ILoadingMonitor);
		}
		
		/**
		 * description
		 * 
		 * @throws 	ArgumentError 	if the <code>report</code> argument is <code>null</code>.
		 * @return
		 */
		public function add(monitor:ILoadingMonitor): void
		{
			if (!monitor) throw new ArgumentError("Argument <monitor> must not be null.");
			
			if (_monitorMap.containsKey(monitor.id))
			{
				var message:String = "There is already an ILoadingMonitor object stored with id:\n";
				message += "<" + monitor.id + ">\n";
				message += "Use the method <LoadingMonitorRepository().exists()> to check if an ILoadingMonitor object already exists.\n";
				
				throw new DuplicateLoadingMonitorError(monitor.id, message);
			}
			
			_monitorMap.put(monitor.id, monitor);
		}
		
		/**
		 * description
		 * 
		 * @return
 		 */
		public function clear(): void
		{
			_monitorMap.clear();
		}

		/**
		 * description
		 * 
		 * @param 	assetId    
		 * @throws 	ArgumentError 	if the <code>identification</code> argument is <code>null</code>.
		 * @return
		 */
		public function exists(id:String): Boolean
		{
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			
			return _monitorMap.containsKey(id);
		}

		/**
		 * description
		 * 
		 * @param 	identification    
		 * @throws 	ArgumentError 	if the <code>identification</code> argument is <code>null</code>.
		 * @return
		 */
		public function find(id:String): ILoadingMonitor
		{
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			
			return _monitorMap.getValue(id);
		}

		/**
		 * description
		 * 
		 * @return
 		 */
		public function findAll(): IList
		{
			if (isEmpty()) return null;
			var l:IList = new ReadOnlyArrayList(_monitorMap.getValues().toArray());
			
			return l;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function isEmpty(): Boolean
		{
			return _monitorMap.isEmpty();
		}

		/**
		 * description
		 * 
		 * @param 	assetId    
		 * @throws 	ArgumentError 	if the <code>assetId</code> argument is <code>null</code> or <code>empty</code>.
		 * @return
		 */
		public function remove(id:String): Boolean
		{
			if (StringUtil.isBlank(id)) throw new ArgumentError("Argument <id> must not be null nor an empty String.");
			
			return _monitorMap.remove(id) != null;
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function size(): int
		{
			return _monitorMap.size();
		}
		
		/**
		 * description
		 * 
		 * @return
		 */
		public function toString(): String
		{
			return "[" + ReflectionUtil.getClassName(this) + "] <" + _monitorMap.getValues() + ">";
		}

	}

}