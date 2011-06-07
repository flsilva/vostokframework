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
	import org.vostokframework.loadingmanagement.domain.PlainLoader;
	import org.vostokframework.loadingmanagement.domain.events.LoaderEvent;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * description
	 * 
	 * @author Flávio Silva
	 */
	public class VostokLoader extends PlainLoader
	{
		/**
		 * @private
 		 */
		private var _context:LoaderContext;
		private var _loader:Loader;
		private var _request:URLRequest;
		
		/**
		 * description
		 * 
		 * @param loader
		 * @param request
		 * @param context
		 */
		public function VostokLoader(loader:Loader, request:URLRequest, context:LoaderContext = null)
		{
			if (!loader) throw new ArgumentError("Argument <loader> must not be null.");
			if (!request) throw new ArgumentError("Argument <request> must not be null.");
			
			_loader = loader;
			_request = request;
			_context = context;
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (!LoaderEvent.typeBelongs(type))
			{
				_loader.contentLoaderInfo.addEventListener(type, listener, useCapture, priority, useWeakReference);
				return;
			}
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * description
		 */
		override public function cancel(): void
		{
			removeFileLoaderListeners();
			
			try
			{
				_loader.close();
			}
			catch (error:Error)
			{
				throw error;
			}
			finally
			{
				_loader.unload();
			}
		}
		
		override public function dispose():void
		{
			try
			{
				_loader.close();
			}
			catch (error:Error)
			{
				//do nothing
			}
			finally
			{
				_loader.unload();
			}
			
			_loader = null;
			_request = null;
			_context = null;
		}
		
		override public function hasEventListener(type:String):Boolean
		{
			if (!LoaderEvent.typeBelongs(type))
			{
				return _loader.contentLoaderInfo.hasEventListener(type);
			}
			
			return super.hasEventListener(type);
		}
		
		/**
		 * description
		 */
		override public function load(): void
		{
			addFileLoaderListeners();
			_loader.load(_request, _context);
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			if (!LoaderEvent.typeBelongs(type))
			{
				_loader.contentLoaderInfo.removeEventListener(type, listener, useCapture);
				return;
			}
			
			super.removeEventListener(type, listener, useCapture);
		}
		
		override public function stop():void
		{
			try
			{
				_loader.close();
			}
			catch (error:Error)
			{
				throw error;
			}
			finally
			{
				_loader.unload();
			}
		}
		
		override public function willTrigger(type:String):Boolean
		{
			if (!LoaderEvent.typeBelongs(type))
			{
				return _loader.contentLoaderInfo.willTrigger(type);
			}
			
			return super.willTrigger(type);
		}
		
		private function addFileLoaderListeners():void
		{
			_loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(Event.OPEN, openHandler, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
		}
		
		private function removeFileLoaderListeners():void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.INIT, initHandler, false);
			_loader.contentLoaderInfo.removeEventListener(Event.OPEN, openHandler, false);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler, false);
		}
		
		private function initHandler(event:Event):void
		{
			try
			{
				var data:DisplayObject = _loader.content;
				dispatchEvent(new LoaderEvent(LoaderEvent.INIT, data));
			}
			catch (error:SecurityError)
			{
				dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, error.message));
			}
		}
		
		private function openHandler(event:Event):void
		{
			try
			{
				var data:DisplayObject = _loader.content;
				dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, data));
			}
			catch (error:SecurityError)
			{
				dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, error.message));
			}
		}
		
		private function completeHandler(event:Event):void
		{
			complete();
		}
		
		private function complete():void
		{
			removeFileLoaderListeners();
			
			try
			{
				var data:DisplayObject = _loader.content;
				dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, data));
			}
			catch (error:SecurityError)
			{
				dispatchEvent(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, error.message));
			}
		}

	}

}