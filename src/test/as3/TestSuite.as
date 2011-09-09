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
	import org.vostokframework.application.monitoring.monitors.CompositeLoadingMonitorTests;
	import org.vostokframework.application.monitoring.monitors.CompositeLoadingMonitorTestsIntegration;
	import org.vostokframework.application.monitoring.monitors.LoadingMonitorTests;
	import org.vostokframework.application.monitoring.monitors.LoadingMonitorWrapperTestsIntegration;
	import org.vostokframework.application.services.AssetPackageServiceTests;
	import org.vostokframework.application.services.AssetServiceTests;
	import org.vostokframework.application.services.LoadingServiceTestsCancel;
	import org.vostokframework.application.services.LoadingServiceTestsContainsAssetData;
	import org.vostokframework.application.services.LoadingServiceTestsExists;
	import org.vostokframework.application.services.LoadingServiceTestsGetAssetData;
	import org.vostokframework.application.services.LoadingServiceTestsGetMonitor;
	import org.vostokframework.application.services.LoadingServiceTestsIntegration;
	import org.vostokframework.application.services.LoadingServiceTestsIsLoading;
	import org.vostokframework.application.services.LoadingServiceTestsIsQueued;
	import org.vostokframework.application.services.LoadingServiceTestsLoad;
	import org.vostokframework.application.services.LoadingServiceTestsMergeAssets;
	import org.vostokframework.application.services.LoadingServiceTestsRemoveAssetData;
	import org.vostokframework.application.services.LoadingServiceTestsResume;
	import org.vostokframework.application.services.LoadingServiceTestsStop;
	import org.vostokframework.domain.assets.AssetFactoryTests;
	import org.vostokframework.domain.assets.AssetPackageFactoryTests;
	import org.vostokframework.domain.assets.AssetPackageRepositoryTests;
	import org.vostokframework.domain.assets.AssetPackageTests;
	import org.vostokframework.domain.assets.AssetRepositoryTests;
	import org.vostokframework.domain.assets.AssetTests;
	import org.vostokframework.domain.assets.UrlAssetParserTests;
	import org.vostokframework.domain.loading.loaders.VostokLoaderTests;
	import org.vostokframework.domain.loading.policies.ElaborateLoadingPolicyTests;
	import org.vostokframework.domain.loading.policies.ElaborateLoadingPolicyTestsHighestLowest;
	import org.vostokframework.domain.loading.policies.LoadingPolicyTests;
	import org.vostokframework.domain.loading.states.fileloader.CanceledFileLoaderTests;
	import org.vostokframework.domain.loading.states.fileloader.CompleteFileLoaderTests;
	import org.vostokframework.domain.loading.states.fileloader.FailedFileLoaderTests;
	import org.vostokframework.domain.loading.states.fileloader.FileLoadingAlgorithmTests;
	import org.vostokframework.domain.loading.states.fileloader.LoadingFileLoaderTests;
	import org.vostokframework.domain.loading.states.fileloader.LoadingFileLoaderTestsCancel;
	import org.vostokframework.domain.loading.states.fileloader.LoadingFileLoaderTestsInstantiation;
	import org.vostokframework.domain.loading.states.fileloader.LoadingFileLoaderTestsStop;
	import org.vostokframework.domain.loading.states.fileloader.QueuedFileLoaderTests;
	import org.vostokframework.domain.loading.states.fileloader.QueuedFileLoaderTestsCancel;
	import org.vostokframework.domain.loading.states.fileloader.QueuedFileLoaderTestsLoad;
	import org.vostokframework.domain.loading.states.fileloader.QueuedFileLoaderTestsStop;
	import org.vostokframework.domain.loading.states.fileloader.StoppedFileLoaderTests;
	import org.vostokframework.domain.loading.states.fileloader.StoppedFileLoaderTestsCancel;
	import org.vostokframework.domain.loading.states.fileloader.StoppedFileLoaderTestsLoad;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.DelayableFileLoadingAlgorithmTests;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.LatencyTimeoutFileLoadingAlgorithmTests;
	import org.vostokframework.domain.loading.states.fileloader.algorithms.MaxAttemptsFileLoadingAlgorithmTests;
	import org.vostokframework.domain.loading.states.queueloader.CanceledQueueLoaderTests;
	import org.vostokframework.domain.loading.states.queueloader.CanceledQueueLoaderTestsContainsChild;
	import org.vostokframework.domain.loading.states.queueloader.CanceledQueueLoaderTestsGetChild;
	import org.vostokframework.domain.loading.states.queueloader.CompleteQueueLoaderTests;
	import org.vostokframework.domain.loading.states.queueloader.CompleteQueueLoaderTestsContainsChild;
	import org.vostokframework.domain.loading.states.queueloader.CompleteQueueLoaderTestsGetChild;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTests;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsAddChild;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsAddChildren;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsCancel;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsCancelChild;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsContainsChild;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsGetChild;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsInstanciation;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsLoad;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsRemoveChild;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsResumeChild;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsStop;
	import org.vostokframework.domain.loading.states.queueloader.LoadingQueueLoaderTestsStopChild;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsAddChild;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsAddChildren;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsCancel;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsCancelChild;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsContainsChild;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsGetChild;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsLoad;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsRemoveChild;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsResumeChild;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsStop;
	import org.vostokframework.domain.loading.states.queueloader.QueuedQueueLoaderTestsStopChild;
	import org.vostokframework.domain.loading.states.queueloader.StoppedQueueLoaderTests;
	import org.vostokframework.domain.loading.states.queueloader.StoppedQueueLoaderTestsAddChild;
	import org.vostokframework.domain.loading.states.queueloader.StoppedQueueLoaderTestsAddChildren;
	import org.vostokframework.domain.loading.states.queueloader.StoppedQueueLoaderTestsCancel;
	import org.vostokframework.domain.loading.states.queueloader.StoppedQueueLoaderTestsCancelChild;
	import org.vostokframework.domain.loading.states.queueloader.StoppedQueueLoaderTestsContainsChild;
	import org.vostokframework.domain.loading.states.queueloader.StoppedQueueLoaderTestsGetChild;
	import org.vostokframework.domain.loading.states.queueloader.StoppedQueueLoaderTestsLoad;
	import org.vostokframework.domain.loading.states.queueloader.StoppedQueueLoaderTestsRemoveChild;
	import org.vostokframework.domain.loading.states.queueloader.StoppedQueueLoaderTestsResumeChild;

	/**
	 * @author Flávio Silva
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuite
	{
		
		//org.vostokframework.domain.assets
		public var assetTests:AssetTests;
		public var assetFactoryTests:AssetFactoryTests;
		public var assetPackageTests:AssetPackageTests;
		public var assetPackageFactoryTests:AssetPackageFactoryTests;
		public var assetRepositoryTests:AssetRepositoryTests;
		public var assetPackageRepositoryTests:AssetPackageRepositoryTests;
		public var urlAssetParserTests:UrlAssetParserTests;
		
		//org.vostokframework.application.services
		public var assetServiceTests:AssetServiceTests;
		public var assetPackageServiceTests:AssetPackageServiceTests;
		
		//org.vostokframework.domain.loading.loaders
		public var vostokLoaderTests:VostokLoaderTests;
		
		//org.vostokframework.application.monitoring
		public var compositeLoadingMonitorTests:CompositeLoadingMonitorTests;
		public var compositeLoadingMonitorTestsIntegration:CompositeLoadingMonitorTestsIntegration;
		public var loadingMonitorTests:LoadingMonitorTests;
		public var loadingMonitorWrapperTestsIntegration:LoadingMonitorWrapperTestsIntegration;
		
		//org.vostokframework.domain.loading.policies
		public var loadingPolicyTests:LoadingPolicyTests;
		public var elaborateLoadingPolicyTests:ElaborateLoadingPolicyTests;
		public var elaborateLoadingPolicyTestsHighestLowest:ElaborateLoadingPolicyTestsHighestLowest;
		
		//org.vostokframework.domain.loading.states.fileloader
		public var canceledFileLoaderTests:CanceledFileLoaderTests;
		public var completeFileLoaderTests:CompleteFileLoaderTests;
		public var failedFileLoaderTests:FailedFileLoaderTests;
		public var fileLoadingAlgorithmTests:FileLoadingAlgorithmTests;
		public var loadingFileLoaderTests:LoadingFileLoaderTests;
		public var loadingFileLoaderTestsCancel:LoadingFileLoaderTestsCancel;
		public var loadingFileLoaderTestsInstantiation:LoadingFileLoaderTestsInstantiation;
		public var loadingFileLoaderTestsStop:LoadingFileLoaderTestsStop;
		public var queuedFileLoaderTests:QueuedFileLoaderTests;
		public var queuedFileLoaderTestsCancel:QueuedFileLoaderTestsCancel;
		public var queuedFileLoaderTestsLoad:QueuedFileLoaderTestsLoad;
		public var queuedFileLoaderTestsStop:QueuedFileLoaderTestsStop;
		public var stoppedFileLoaderTests:StoppedFileLoaderTests;
		public var stoppedFileLoaderTestsCancel:StoppedFileLoaderTestsCancel;
		public var stoppedFileLoaderTestsLoad:StoppedFileLoaderTestsLoad;
		
		//org.vostokframework.domain.loading.states.fileloader.algorithms
		public var delayableFileLoadingAlgorithmTests:DelayableFileLoadingAlgorithmTests;
		public var latencyTimeoutFileLoadingAlgorithmTests:LatencyTimeoutFileLoadingAlgorithmTests;
		public var maxAttemptsFileLoadingAlgorithmTests:MaxAttemptsFileLoadingAlgorithmTests;
		
		//org.vostokframework.domain.loading.states.queueloader
		public var canceledQueueLoaderTests:CanceledQueueLoaderTests;
		public var canceledQueueLoaderTestsContainsChild:CanceledQueueLoaderTestsContainsChild;
		public var canceledQueueLoaderTestsGetChild:CanceledQueueLoaderTestsGetChild;
		
		public var completeQueueLoaderTests:CompleteQueueLoaderTests;
		public var completeQueueLoaderTestsContainsChild:CompleteQueueLoaderTestsContainsChild;
		public var completeQueueLoaderTestsGetChild:CompleteQueueLoaderTestsGetChild;
		
		public var loadingQueueLoaderTests:LoadingQueueLoaderTests;
		public var loadingQueueLoaderTestsAddChild:LoadingQueueLoaderTestsAddChild;
		public var loadingQueueLoaderTestsAddChildren:LoadingQueueLoaderTestsAddChildren;
		public var loadingQueueLoaderTestsCancel:LoadingQueueLoaderTestsCancel;
		public var loadingQueueLoaderTestsCancelChild:LoadingQueueLoaderTestsCancelChild;
		public var loadingQueueLoaderTestsContainsChild:LoadingQueueLoaderTestsContainsChild;
		public var loadingQueueLoaderTestsGetChild:LoadingQueueLoaderTestsGetChild;
		public var loadingQueueLoaderTestsInstanciation:LoadingQueueLoaderTestsInstanciation;
		public var loadingQueueLoaderTestsLoad:LoadingQueueLoaderTestsLoad;
		public var loadingQueueLoaderTestsRemoveChild:LoadingQueueLoaderTestsRemoveChild;
		public var loadingQueueLoaderTestsResumeChild:LoadingQueueLoaderTestsResumeChild;
		public var loadingQueueLoaderTestsStop:LoadingQueueLoaderTestsStop;
		public var loadingQueueLoaderTestsStopChild:LoadingQueueLoaderTestsStopChild;
		
		public var queuedQueueLoaderTestsAddChild:QueuedQueueLoaderTestsAddChild;
		public var queuedQueueLoaderTestsAddChildren:QueuedQueueLoaderTestsAddChildren;
		public var queuedQueueLoaderTestsCancel:QueuedQueueLoaderTestsCancel;
		public var queuedQueueLoaderTestsCancelChild:QueuedQueueLoaderTestsCancelChild;
		public var queuedQueueLoaderTestsContainsChild:QueuedQueueLoaderTestsContainsChild;
		public var queuedQueueLoaderTestsGetChild:QueuedQueueLoaderTestsGetChild;
		public var queuedQueueLoaderTestsLoad:QueuedQueueLoaderTestsLoad;
		public var queuedQueueLoaderTestsRemoveChild:QueuedQueueLoaderTestsRemoveChild;
		public var queuedQueueLoaderTestsResumeChild:QueuedQueueLoaderTestsResumeChild;
		public var queuedQueueLoaderTestsStop:QueuedQueueLoaderTestsStop;
		public var queuedQueueLoaderTestsStopChild:QueuedQueueLoaderTestsStopChild;
		
		public var stoppedQueueLoaderTests:StoppedQueueLoaderTests;
		public var stoppedQueueLoaderTestsAddChild:StoppedQueueLoaderTestsAddChild;
		public var stoppedQueueLoaderTestsAddChildren:StoppedQueueLoaderTestsAddChildren;
		public var stoppedQueueLoaderTestsCancel:StoppedQueueLoaderTestsCancel;
		public var stoppedQueueLoaderTestsCancelChild:StoppedQueueLoaderTestsCancelChild;
		public var stoppedQueueLoaderTestsContainsChild:StoppedQueueLoaderTestsContainsChild;
		public var stoppedQueueLoaderTestsGetChild:StoppedQueueLoaderTestsGetChild;
		public var stoppedQueueLoaderTestsLoad:StoppedQueueLoaderTestsLoad;
		public var stoppedQueueLoaderTestsRemoveChild:StoppedQueueLoaderTestsRemoveChild;
		public var stoppedQueueLoaderTestsResumeChild:StoppedQueueLoaderTestsResumeChild;
		
		//org.vostokframework.application.services
		public var loadingServiceTestsCancel:LoadingServiceTestsCancel;
		public var loadingServiceTestsContainsAssetData:LoadingServiceTestsContainsAssetData;
		public var loadingServiceTestsExists:LoadingServiceTestsExists;
		public var loadingServiceTestsGetAssetData:LoadingServiceTestsGetAssetData;
		public var loadingServiceTestsGetMonitor:LoadingServiceTestsGetMonitor;
		public var loadingServiceTestsIsLoading:LoadingServiceTestsIsLoading;
		public var loadingServiceTestsIsQueued:LoadingServiceTestsIsQueued;
		public var loadingServiceTestsLoad:LoadingServiceTestsLoad;
		public var loadingServiceTestsMergeAssets:LoadingServiceTestsMergeAssets;
		public var loadingServiceTestsRemoveAssetData:LoadingServiceTestsRemoveAssetData;
		public var loadingServiceTestsResume:LoadingServiceTestsResume;
		public var loadingServiceTestsStop:LoadingServiceTestsStop;
		public var loadingServiceTestsIntegration:LoadingServiceTestsIntegration;
		
		public function TestSuite()
		{
			
		}

	}

}