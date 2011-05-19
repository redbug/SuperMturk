/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photoFetcher.agent.google
{
    import be.boulevart.google.ajaxapi.search.GoogleSearchResult;
    import be.boulevart.google.ajaxapi.search.images.GoogleImageSearch;
    import be.boulevart.google.ajaxapi.search.images.data.GoogleImage;
    import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageFiletype;
    import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageSafeMode;
    import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageSize;
    import be.boulevart.google.ajaxapi.search.images.data.types.GoogleImageType;
    import be.boulevart.google.events.GoogleAPIErrorEvent;
    import be.boulevart.google.events.GoogleApiEvent;
    
    import flash.events.Event;
    
    import idv.redbug.mturk.photo.PhotoModel;
    import idv.redbug.mturk.photoFetcher.agent.ApiAgent;
    import idv.redbug.mturk.photoFetcher.proxy.IProxy;
    
    import org.osflash.signals.Signal;
    import org.osflash.signals.natives.NativeSignal;

    public class GoogleAgent extends ApiAgent
    {
        private static var _instance    :GoogleAgent;
        
        private var _cnt_photo              :int;
        private var _api                    :GoogleImageSearch;
        
        private var _sgAPIError             :NativeSignal;
        private var _sgImageSearchResult    :NativeSignal;
        
        public function GoogleAgent( enforcer:SingletonEnforcer )
        {
            
        }

        public static function get instance():GoogleAgent
        {
            if( _instance == null)
            {
                _instance = new GoogleAgent( new SingletonEnforcer() );
                _instance.initialize();
            }
            
            return  _instance;
        }
        
        private function initialize():void
        {
            _agentId = ApiAgent.ID_GOOGLE;
            
            _api = new GoogleImageSearch();
            
            _sgAPIError = new NativeSignal( _api, GoogleAPIErrorEvent.API_ERROR, GoogleAPIErrorEvent ); 
            _sgImageSearchResult = new NativeSignal( _api, GoogleApiEvent.IMAGE_SEARCH_RESULT, GoogleApiEvent );
            
            _sgAPIError.add( onSearchError );
            _sgImageSearchResult.add( onSearchComplete );   
        }
        
        override public function reset():void
        {
            super.reset();
            _cnt_photo = 0;
        }
        
        override public function destroy():void
        {
            super.destroy();
            
            _api = null;
            
            _sgAPIError.removeAll();
            _sgAPIError = null;
            
            _sgImageSearchResult.removeAll();
            _sgImageSearchResult = null;
            
            _instance = null;
        }
        
        override public function connect():void
        {
            onConnectReady();
        }
        
        override public function onConnectReady( event:Event=null ):void
        {
            _sgConnectComplete.dispatch( _agentId );
        }
        
        override public function onConnectError( event:Event=null ):void
        {
        
        }
        
        override public function search( keyword:String, numResult:int, restaurantAddr:String=null ):void
        {
            if ( isValidateForAscii( restaurantAddr ) ){
                //for english
                _keyword = 'intitle:' + keyword + '("restaurant" OR ' + '"' + restaurantAddr +'")';
            }else{
                //for non-english
                _keyword = 'intitle:' + keyword + ' OR ' + '"' + restaurantAddr + '"';
            }
            
//            _keyword = keyword;
            _numResult = numResult;
            
//            _sgError.dispatch( "google: " + _keyword );
            
            search_helper( _keyword, 0 );          
        }
        
        private function search_helper( keyword:String, start:int ):void
        {
            _api.search( keyword, start, GoogleImageSafeMode.MODERATE, "large|xlarge|xxlarge", "", "", GoogleImageType.PHOTO );
        }
        
        override public function onSearchComplete( event:Event=null ):void
        {
            var resultObject    :GoogleSearchResult = GoogleApiEvent(event).data as GoogleSearchResult;
            var photoModel      :PhotoModel;
            
            
            var estimatedNumResults:int = resultObject.estimatedNumResults;
            _numResult = ( estimatedNumResults < _numResult )? estimatedNumResults: _numResult; 
            
            for each ( var image:GoogleImage in resultObject.results )
            {
                photoModel = new PhotoModel();
                
                photoModel.title = image.title;
//                photoModel.title = image.titleNoFormatting;
                photoModel.urlOwner = image.originalContextUrl;
                photoModel.urlSource = image.unescapedUrl;
                photoModel.urlThumb = image.thumbUrl;
                photoModel.width = int( image.width );
                photoModel.height = int( image.height );
                photoModel.description = image.contentNoFormatting;
                photoModel.tags = "";
                photoModel.contentType = -1;
                photoModel.from = "G";
                
//                trace( photoModel );
                _photoModelList.push( photoModel );
                _cnt_photo++;
                
                if( _cnt_photo == _numResult){
                    break;
                }
            }
            
            if( _cnt_photo < _numResult){
                search_helper( _keyword, _cnt_photo);
            }
            else{
                _sgSearchComplete.dispatch( _photoModelList, _agentId );
                reset();
            }
        }

        override public function onSearchError( event:Event=null ):void{
            var googleAPIErrEvt :GoogleAPIErrorEvent = event as GoogleAPIErrorEvent;
            
            _sgError.dispatch( "G_Server error has occured: " + googleAPIErrEvt.responseDetails, "responseStatus was: " + googleAPIErrEvt.responseStatus);
            
            if ( _numRetried_search < MAX_RETRY ){
                // if search failed, connect again.
                _timer.delay = 1000;
                
                _sgTimer.addOnce( reSearch );
                _timer.start();
            }else{
                _sgError.dispatch( "[agent]G_Server search doesn't work!" );     
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