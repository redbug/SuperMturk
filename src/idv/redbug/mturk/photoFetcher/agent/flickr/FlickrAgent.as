/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photoFetcher.agent.flickr{
	import com.adobe.webapis.flickr.*;
	import com.adobe.webapis.flickr.Photo;
	import com.adobe.webapis.flickr.events.FlickrResultEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.Timer;
	
	import idv.redbug.mturk.photo.PhotoModel;
	import idv.redbug.mturk.photoFetcher.agent.ApiAgent;
	import idv.redbug.mturk.photoFetcher.agent.flickr.extraInfo.GetExtraCmd;
	import idv.redbug.mturk.photoFetcher.agent.flickr.extraInfo.GetPhotosExtraCmd;
	
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;
    
    public class FlickrAgent extends ApiAgent
    {
        private static var _instance    :FlickrAgent;
        
        private const API_KEY           :String = "951cdc97f89d9507d0eaab00c7f9c40d";
        private const API_SECRET        :String = "f9aadc2577c31930";
        
		private const FLICKR_URL        :String = "flickr.com";
		private const CROSSDOMAIN_URL   :String = "http://api.flickr.com/crossdomain.xml";
        private const EXTRAS_OPTION     :String = "description,owner_name,tags,views,url_sq,url_t,url_s,url_m,url_z,url_l,url_o";
        
        private var _api                :FlickrService;
        
        private var _sgAuthGetFrob      :NativeSignal;
        private var _sgPhotosSearch     :NativeSignal;

		public function FlickrAgent( enforcer:SingletonEnforcer )
        {
            
		}
        
        public static function get instance():FlickrAgent
        {
            if( _instance == null)
            {
                _instance = new FlickrAgent( new SingletonEnforcer() );
                _instance.initialize();
            }
            
            return  _instance;
        }
        
        private function initialize():void
        {
            _agentId = ApiAgent.ID_FLICKR;
            
            Security.allowDomain( FLICKR_URL );
            Security.loadPolicyFile( CROSSDOMAIN_URL );
            _api = new FlickrService( API_KEY );
            _api.secret = API_SECRET;
            
            _sgAuthGetFrob = new NativeSignal( _api, FlickrResultEvent.AUTH_GET_FROB, FlickrResultEvent );
            _sgPhotosSearch = new NativeSignal( _api, FlickrResultEvent.PHOTOS_SEARCH, FlickrResultEvent ); 
            
            _sgAuthGetFrob.add( onConnectReady );
            _sgPhotosSearch.add( onSearchComplete );
        }
        
        override public function reset():void
        {
            super.reset();
        }

        override public function destroy():void
        {
            super.destroy();
            
            _api = null;
            
            _sgAuthGetFrob.removeAll();
            _sgAuthGetFrob = null;
            
            _sgPhotosSearch.removeAll();
            _sgPhotosSearch = null;
            
            _instance = null;
        }
        
        override public function connect():void
        {
            if( _isConnected ){
                _sgConnectComplete.dispatch( _agentId );
            }else{
                _api.auth.getFrob();
            }
        }

        override public function onConnectReady( event:Event=null ):void
        {
            var flickrResultEvt:FlickrResultEvent = event as FlickrResultEvent;
            
            if ( flickrResultEvt.success ) {
                _isConnected = true;
                _sgConnectComplete.dispatch( _agentId );        
            } else {
                onConnectError( event );
            }
            
        }
        
        override public function onConnectError( event:Event=null ):void 
        {
            var flickrResultEvt:FlickrResultEvent = event as FlickrResultEvent;
            var error:* = flickrResultEvt.data.error;          
            
            _sgError.dispatch( "[agent]F_Server GrabberError -- " + "Connect Failed: Error obtaining Frob from F_Server!\n" + "Error Code:" + error.errorCode + "\nError Messages:" + error.errorMessage );
            
            if ( _numRetried_connect < MAX_RETRY ){
                // if connect failed, connect again.
                _timer.delay = 1000;
                
                _sgTimer.addOnce( reconnect );
                _timer.start();
            }else{
                _sgError.dispatch( "[agent]Connect to F_server failed!" );     
            }
        }
        
        private function reconnect():void
        {
            _timer.stop();
            _numRetried_connect++;
            connect();        
        }
        
        override public function search( keyword:String, numResult:int ):void
        {
            _keyword = keyword;
            _numResult = numResult;
            
            var keywordEncoded:String = encodeURI( keyword );
            _sgLog.dispatch( "keyword (URL encoded) : " + keywordEncoded ); 
            /*
             * The possible values of sorting parameter are:
             * date-posted-asc, date-posted-desc, date-taken-asc, date-taken-desc, interestingness-desc, interestingness-asc, and relevance. 
             */
            _api.photos.search("", keywordEncoded, "any", keywordEncoded, null, null, null, null, -1, EXTRAS_OPTION, numResult, 1, "relevance");
        }
        
		override public function onSearchComplete( event:Event=null ):void {
            
            var flickrResultEvent:FlickrResultEvent = event as FlickrResultEvent;
            
            if( flickrResultEvent.success ){
                
                var pagedPhotoList  :PagedPhotoList = flickrResultEvent.data.photos as PagedPhotoList;
                var photoModel      :PhotoModel;
                var photoList       :Array = pagedPhotoList.photos;
                var numPhotos       :int = photoList.length;
                
                //resort the photo list by the views property
                photoList.sortOn("views", Array.NUMERIC|Array.DESCENDING)
                
                if ( pagedPhotoList.total > 0) {

                    _photoModelList = new Vector.<PhotoModel>( numPhotos );

                    var photo:Photo;
                    for( var i:int=0; i<numPhotos; ++i)
                    {
                        photo = photoList[i];
                        
                        //show the view times of the photo
                        //trace("views", photo.views);
                        
                        photoModel = new PhotoModel();
                        
                        photoModel.title = photo.title;
                        photoModel.urlOwner = "http://www.flickr.com/photos/" + photo.ownerId + "/" + photo.id;
                        
                        /******************************************************************************************************
                         * default to the safer size, however these sizes will be override by GetSizeCmd if no timeout occurs.
                         ******************************************************************************************************/
                        if( photo.extras.url_z ){
                            photoModel.urlSource = photo.extras.url_z;
                        }
                        else if( photo.extras.url_m ){
                            photoModel.urlSource = photo.extras.url_m;
                        }else{
                            photoModel.urlSource = photo.extras.url_s;
                        }
                        
                        if( photo.extras.url_s ){
                            photoModel.urlThumb = photo.extras.url_s;
                        }else{
                            photoModel.urlThumb = photo.extras.url_t;
                        }
                        
                        /***********************************************
                         * width and height will be update in GetSizeCmd
                         ***********************************************/ 
                        photoModel.width = -1;
                        photoModel.height = -1;
                        
                        photoModel.description = photo.description;
                        photoModel.tags = photo.tags.join();
                        photoModel.contentType = -1;
                        photoModel.from = "F";
                        
                        //trace( photoModel );
                        _photoModelList[i] = photoModel;
                    }
                    
                    var cmd:GetPhotosExtraCmd = new GetPhotosExtraCmd( _api, photoList, _photoModelList, 0);
                    cmd.sgCommandComplete.addOnce( dispatchSearchComplete );
                    cmd.start();                    
                }
                //no search result from flickr
                else{
                    dispatchSearchComplete();
                }
                
            }else{                
                onSearchError( event );
            }
		}
        
        private function dispatchSearchComplete():void
        {
            for( var i:int = 0; i < _photoModelList.length; ++i )
            {
                trace(_photoModelList[i].width, "X", _photoModelList[i].height);
            }           
            _sgSearchComplete.dispatch( _photoModelList, _agentId );        
        }
        
        override public function onSearchError( event:Event=null ):void
        {
            var flickrResultEvent:FlickrResultEvent = event as FlickrResultEvent;
            var error:* = flickrResultEvent.data.error;  
            
            _sgError.dispatch( "[agent]F_Server SearchError:\n" + "Error Code:" + error.errorCode + "\nError Messages:" + error.errorMessage );
            
            if ( _numRetried_search < MAX_RETRY ){
                // if search failed, connect again.
                _timer.delay = 1000;
                
                _sgTimer.addOnce( reSearch );
                _timer.start();
            }else{
                _sgError.dispatch( "[agent]F_Server search doesn't work!" );     
            }
        }
        
        private function reSearch():void
        {
            _timer.stop();
            _numRetried_search++;
            search( _keyword, _numResult );        
        }
        
	}
}

class SingletonEnforcer{}