/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package 
{
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;
    
    import com.adobe.serialization.json.JSON;
    import com.adobe.serialization.json.JSONParseError;
    
    import fl.controls.Button;
    
    import flash.display.*;
    import flash.errors.IOError;
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.filters.DropShadowFilter;
    import flash.media.Sound;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.net.URLVariables;
    import flash.net.navigateToURL;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    
    import idv.redbug.mturk.photo.PhotoModel;
    import idv.redbug.mturk.photo.PhotoPageManager;
    import idv.redbug.mturk.photo.PhotoSprite;
    import idv.redbug.mturk.photoFetcher.agent.ApiAgent;
    import idv.redbug.mturk.photoFetcher.agent.flickr.FlickrAgent;
    import idv.redbug.mturk.photoFetcher.agent.google.GoogleAgent;
    import idv.redbug.mturk.photoFetcher.command.AgentCmd;
    import idv.redbug.robotbody.CoreContext;
    import idv.redbug.robotbody.commands.AsyncCommand;
    import idv.redbug.robotbody.model.scene.BaseScene;
    import idv.redbug.robotbody.model.scene.IScene;
    import idv.redbug.robotbody.util.Toolkits;
    
    import org.osflash.signals.events.GenericEvent;
    import org.osflash.signals.natives.NativeSignal;
    
    
	public class SceneA extends BaseScene
	{
		private const MY_SWF		:Array = ["Preloader.swf"];
		private const MY_TXT		:Array = [];
		private const MY_MUSIC		:Array = [];
		private const MY_XML		:Array = [];

        private const NUM_PHOTO_PER_PAGE :int = 4;
        private const NUM_SEARCH_RESULT  :int = 10;  // for each api agent
        
        private const DEBUG                 :Boolean = false;
        
        private const REMOTE_URL            :String = "http://122.248.249.104:3389/"
        //private const LOCAL_URL             :String = "http://192.168.11.36:8000/"
        private const LOCAL_URL             :String = "http://localhost:8000/"

        private const MAX_RETRY             :int = 5;   // for URLLoader's resubmiting to our server.   
            
        private var _server_url            :String;
        
        //Loader
        private var _urlLoader           :URLLoader;
        private var _imageLoader         :BulkLoader;
        
        //-------------- API ------------------//
        private var _apiAgent           :ApiAgent;
        private var _flickrAgent        :FlickrAgent;
        private var _googleAgent        :GoogleAgent;
        
        // UI
        private var _photoDisplayPanel   :Sprite;
        private var _controlPanel        :Sprite;
        private var _next_btn            :Button;
        private var _previous_btn        :Button;
        private var _submit_btn          :Button;
        private var _currentPage_txt     :TextField;
        private var _preloader_mc        :MovieClip;
        
        //property
        private var _restaurantId        :String;
        private var _restaurantName      :String;
        private var _restaurantAddr      :String;
        private var _hitId               :String;
        private var _assignmentId        :String;
        private var _workerId            :String;
        
        //photoe list
        private var _photoModelList      :Vector.<PhotoModel>;
        private var _thumbBitmapList     :Vector.<DisplayObject>;
        private var _photoSpriteList     :Vector.<Sprite>;
        private var _selectedList        :Vector.<Boolean>;
        
        //photo page manager
        private var _photoPageManager   :PhotoPageManager;
        
        private var _numPhotos          :int;
        private var _auditorMode        :Boolean;
        
        private var _numRetried_submit  :int;
        
        private var _timer              :Timer;
        private var _sgTimer            :NativeSignal;
        
        
		//---------------------------------------------------------------------
		//  Override following functions for using the core framework of Robotbody:
		//		init()
		//		run()
		//		destroy()
		//		switchTo()		
		//		accessSWF()
		//		accessTXT()
		//		accessMP3()
		//		accessXML()
		//---------------------------------------------------------------------
		
		override public function init():void
		{
            resManager.dir_asset = '/media/swf/asset/';
            
            if( DEBUG ){
                _server_url = LOCAL_URL;
            }else{
                _server_url = REMOTE_URL;
            }
            

            _auditorMode = false;
            _numRetried_submit = 0;
            
            _timer = new Timer( 1000 );
            _sgTimer = new NativeSignal( _timer, TimerEvent.TIMER, TimerEvent );
            
            // Agent initialization
            _flickrAgent = FlickrAgent.instance;
            _googleAgent = GoogleAgent.instance;
            
            _flickrAgent.sgError.add( onAPIAgentError );
            _googleAgent.sgError.add( onAPIAgentError );
            
            _urlLoader = new URLLoader();
            
            _imageLoader = new BulkLoader("imageLoader");
            
            _imageLoader.addEventListener(BulkLoader.COMPLETE, onAllItemsLoaded);
            _imageLoader.addEventListener(BulkLoader.ERROR, onBulkLoaderError);
            _imageLoader.addEventListener(BulkLoader.HTTP_STATUS, onHTTPStatusError);
            
//            _imageLoader.addEventListener(BulkLoader.PROGRESS, onAllItemsProgress);
            
            var stageWidth:int = sceneManager.stage.stageWidth;
            
            _photoDisplayPanel = new Sprite();
            _photoDisplayPanel.x = 50;
            _photoDisplayPanel.y = 60;
            _photoDisplayPanel.visible = true;
            addToContextView( _photoDisplayPanel );
            
            var y:int = 450;            
            var width:int = 300;
            var height:int = 80;
            
            _controlPanel = new Sprite();
            _controlPanel.y = y;
            _controlPanel.x = ( stageWidth >> 1 ) - 150;
//            _controlPanel.buttonMode = true;
//            _controlPanel.useHandCursor	= true;
            _controlPanel.graphics.lineStyle( 2, 0x3399FF, 0.8 );
            _controlPanel.graphics.beginFill( 0xffffff, 0.3 )
            _controlPanel.graphics.drawRoundRect(0, 0, width, height, 30, 30);
            _controlPanel.graphics.endFill();
            
            var shadow:DropShadowFilter = new DropShadowFilter();  
  
            shadow.color = 0x000000;  
            shadow.blurY = 8;  
            shadow.blurX = 8;  
            shadow.angle = 100;  
            shadow.alpha = .8;  
            shadow.distance = 3;
            var filtersArray:Array = new Array(shadow);  
              
            _controlPanel.filters = filtersArray;  
            
            
            _controlPanel.addEventListener( MouseEvent.MOUSE_DOWN, onStratDragging, false, 0, true );				
            _controlPanel.addEventListener( MouseEvent.MOUSE_UP, onStopDragging, false, 0, true );
            _controlPanel.addEventListener( MouseEvent.CLICK, onPanelClick, false, 0, true );
            
            
            _currentPage_txt = new TextField();
            _currentPage_txt.autoSize = TextFieldAutoSize.CENTER;
            _currentPage_txt.x = ( _controlPanel.width - _currentPage_txt.width ) >> 1;
            _currentPage_txt.y = 15;
            _controlPanel.addChild( _currentPage_txt );
            
            _previous_btn = new Button();
            _previous_btn.x = _currentPage_txt.x - _previous_btn.width - 20;
            _previous_btn.y = _currentPage_txt.y;
            _previous_btn.useHandCursor = true;
            _previous_btn.buttonMode = true;
            _previous_btn.label = "previous";
            _previous_btn.enabled = true;
            _controlPanel.addChild( _previous_btn );
            
            
            _next_btn = new Button();
            _next_btn.x = _currentPage_txt.x + _currentPage_txt.width + 20;
            _next_btn.y = _currentPage_txt.y;
            _next_btn.useHandCursor = true;
            _next_btn.buttonMode = true;
            _next_btn.label = "next";
            _next_btn.enabled = true;
            _controlPanel.addChild( _next_btn );
            
            
            _submit_btn = new Button();
            _submit_btn.x = ( _controlPanel.width - _submit_btn.width ) >> 1;
            _submit_btn.y = _currentPage_txt.y + 30;
            _submit_btn.useHandCursor = true;
            _submit_btn.buttonMode = true;
            _submit_btn.label = "submit";
            _submit_btn.enabled = false;
            _controlPanel.addChild( _submit_btn );
            
            
			/***********************************************
			 * make a resource list for loading "SWF" files 
			 ***********************************************/
			super.makeSWFList(MY_SWF);

			/***********************************************
			 * make a resource list for loading "Text" files 
			 ***********************************************/
			super.makeTXTList(MY_TXT);
			
			/***********************************************
			 * make a resource list for loading "MP3" files 
			 ***********************************************/
			super.makeMP3List(MY_MUSIC);

			/***********************************************
			 * make a resource list for loading "XML" files 
			 ***********************************************/
			super.makeXMLList(MY_XML);
			
			super.init();
		}	
		
		override public function run():void
		{
//            _resManager.setAssetDir = "/media/";
            
			/***************************************
			 * access the resource from a Swf file
			 ***************************************/
			accessSWF();
			
			/***************************************
			 * access the resource from a text file
			 ***************************************/
			accessTXT();
			
			/***************************************
			 * access the resource from a mp3 file
			 ***************************************/
			accessMP3();
			
			/***************************************
			 * access the resource from a xml file
			 ***************************************/
			accessXML();
            
            var flashVar = Toolkits.getFlashVars( sceneManager.root )
            
            if(flashVar && flashVar['auditor_mode'] == "True"){
                
                _auditorMode = true;
                _restaurantId = flashVar['restaurant_id'];
                
                _submit_btn.enabled = true;
                
                if (ExternalInterface.available) {
                    
                    var photoList:Object = JSON.decode( ExternalInterface.call( "getPhotoList" ) );
                    _photoModelList = new Vector.<PhotoModel>();
                    
                    for each(var photo:Object in photoList)
                    {
                        var p = new PhotoModel( photo );
                        //trace(p);
                        _photoModelList.push( p );
                    }
                    
                    var numPhoto:uint = _photoModelList.length;
                    var thumbURLList:Vector.<String> = new Vector.<String>( numPhoto );
                    _thumbBitmapList = new Vector.<DisplayObject>( numPhoto );
                    _photoSpriteList = new Vector.<Sprite>( numPhoto );
                    _selectedList = new Vector.<Boolean>( numPhoto );
                    _numPhotos = numPhoto;
                    
                    for( var i:int = 0; i < numPhoto; ++i )
                    {
                        thumbURLList[i] = _photoModelList[i].urlThumb;
                        //trace(thumbURLList[i]);
                    }
                    
                    if( numPhoto ){
                        loadTumbnail( thumbURLList );
                    }else{
                        removeFromContextView( _preloader_mc );
                        
                        var stageWidth:int = sceneManager.stage.stageWidth;
                        
                        var error_txt:TextField = new TextField();
                        error_txt.defaultTextFormat = new TextFormat('Arial', 64, 0xFF3366, true);
                        error_txt.text = "No photo!";
                        error_txt.autoSize = TextFieldAutoSize.CENTER;
                        error_txt.x = (stageWidth - error_txt.width) >> 1;
                        error_txt.y = 100;
                            
                        _photoDisplayPanel.addChild(error_txt);
                    }
                    
                }else{
                    showMessageOnSWFContainer( "This SWF Do Not Have Any External Container!" );
                }    
                
            }
            else{
                getExternalParameter();
            }    
		}

        private function showMessageOnSWFContainer( message:String ):void
        {
            ExternalInterface.call( "showErrorMessage", message );
        }
        
        private function onAPIAgentError( errorMessage:String ):void
        {
            showMessageOnSWFContainer( errorMessage );
        }
        
        private function onPanelClick( event:MouseEvent ):void
        {
            //trace("click");
        }
        
        private function getExternalParameter():void
        {
            // get html query string
            var queryObject:Object = Toolkits.getQueryStringFromHTML();
            _hitId = queryObject.hitId;
            _assignmentId = queryObject.assignmentId;
            _workerId = queryObject.workerId;
            
            // get flash var
            var flashVar:Object = Toolkits.getFlashVars( sceneManager.root);
            
            if( flashVar ){
                _restaurantName = flashVar['restaurant_name'];
                _restaurantId = flashVar['restaurant_id'];
                _restaurantAddr = flashVar['restaurant_addr'];
            }
            
            if( _assignmentId == "ASSIGNMENT_ID_NOT_AVAILABLE" ){
                displayPreview();                
            }

            search();
        }
        
        private function displayPreview():void
        {
            var stageWidth:int = sceneManager.stage.stageWidth;
            var previewMask:Sprite = new Sprite();
            
            previewMask.graphics.beginFill( 0x111111, 0.3 );
            previewMask.graphics.drawRoundRect(0, 0, 600, 50, 50, 50);     
            previewMask.graphics.endFill();
            previewMask.x = ( stageWidth - previewMask.width ) >> 1;
            previewMask.y = 0;
            
            
            var preview_txt:TextField = new TextField();
            preview_txt.autoSize = TextFieldAutoSize.LEFT;
            preview_txt.text = "Preview";
            var textFormat:TextFormat = new TextFormat( "Arial", 36, 0xdeddee, true );
            preview_txt.setTextFormat( textFormat );
            previewMask.addChild( preview_txt );
            preview_txt.x = ( previewMask.width - preview_txt.width ) >> 1;
            
            addToContextView( previewMask );
            
            _next_btn.enabled = false;
            _previous_btn.enabled = false;
            _submit_btn.enabled = false;
        }
                
        private function onSubmit( event:MouseEvent=null ):void
        {
            _submit_btn.enabled = false;
            
            var photoList:Array = []
            for each( var photo:PhotoModel in _photoModelList )
            {
                photoList.push(photo);
            }
            
            var result      :Object = new Object();
            
            result.photoList = photoList;
            result.rId = _restaurantId;
            result.hitId = _hitId;
            result.assignmentId = _assignmentId;
            result.workerId = _workerId;
            
            var urlRequest:URLRequest;
            
            if( _auditorMode ){
                urlRequest = new URLRequest( _server_url + 'review/update_by_reviewer/');
            }else{
                urlRequest = new URLRequest( _server_url + 'restaurant/update_by_turk/');
            }
            
            urlRequest.data = JSON.encode( result );
            urlRequest.contentType = "application/json";
            urlRequest.method = URLRequestMethod.POST;
            
            _urlLoader.addEventListener( Event.COMPLETE, onSubmitComplete, false ,0, true );
            _urlLoader.addEventListener( IOErrorEvent.IO_ERROR, onLoadingError, false, 0, true );
            _urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
            _urlLoader.addEventListener( HTTPStatusEvent.HTTP_STATUS, onStatus, false, 0, true );
            _urlLoader.load(urlRequest);            
        }
        
        private function onSecurityError( event:SecurityErrorEvent ):void
        {
            showMessageOnSWFContainer( "Security Error: " + event.text );
        }
        
        private function onLoadingError( event:IOErrorEvent ):void
        {
            _urlLoader.removeEventListener( IOErrorEvent.IO_ERROR, onLoadingError );
            
            showMessageOnSWFContainer( "request error from: " + event.text );
            
            if ( _numRetried_submit < MAX_RETRY ){
                
                _timer.delay = 1000;
                
                _sgTimer.addOnce( resubmit );
                _timer.start();
            }else{
                showMessageOnSWFContainer( event.text + "doesn't response!" );
            }
        }
        
        private function resubmit():void
        {
            _timer.stop();
            _numRetried_submit++;
            onSubmit();        
        }
        
        private function onStatus( evt:HTTPStatusEvent ):void
        {
            trace( "http status: " + evt.status );
        }
        
        private function onSubmitComplete( event:Event ):void
        {
            trace( "result from server:", event.target.data );
            
            if( _auditorMode ){
                navigateToURL( new URLRequest(_server_url + 'review/viewer_auditor/'), "_self" );                
            }else{
                ExternalInterface.call( "callBackFromFlash" );
            }
        }
        
        private function updateCurrentPage():void
        {
            _currentPage_txt.text = _photoPageManager.currentPage + " / " + _photoPageManager.totalPage;
        }
        
        private function isDone( index:int ):void
        {
            if( !_selectedList[ index ] ){
                //trace("selected");
                _selectedList[ index ] = true;
                _numPhotos--;
                
                if( _numPhotos == 0 ){
                    _submit_btn.enabled = true;
                }
            }
        }
        
        private function onAllItemsLoaded( evt:Event=null ):void
        {
            trace("done!");
            
            removeFromContextView( _preloader_mc );
            
            addToContextView( _controlPanel );
                
            _photoPageManager = new PhotoPageManager( _photoDisplayPanel, _photoSpriteList, NUM_PHOTO_PER_PAGE );
            _photoPageManager.sgPageUpdate.add( updateCurrentPage );
            
            _photoPageManager.nextPage();
            
            _next_btn.addEventListener( MouseEvent.CLICK, _photoPageManager.nextPage, false, 0, true );
            _previous_btn.addEventListener( MouseEvent.CLICK, _photoPageManager.previousPage, false, 0, true );
            _submit_btn.addEventListener( MouseEvent.CLICK, onSubmit, false, 0, true );
        }

        private function onStratDragging( event:MouseEvent ):void
        {
            event.currentTarget.startDrag();
            event.stopImmediatePropagation();
        }
        
        private function onStopDragging( event:MouseEvent ):void
        {
            event.currentTarget.stopDrag();
            event.stopImmediatePropagation();
        }
        
        private function onBulkLoaderError( evt:ErrorEvent ):void
        {
            var item:LoadingItem = evt.target as LoadingItem;
            
            if ( item ){
                
                if( item.errorEvent is SecurityErrorEvent ){
                    showMessageOnSWFContainer( "Loading Picture Security Error:" + evt.text );
                }
                else if ( item.errorEvent is IOError ) {
                    showMessageOnSWFContainer( "Loading Picture IO Error:" + evt.text );
                }
                else{
                    showMessageOnSWFContainer( "Loading Picture Unknown Error:" + evt );
                }
                
                trace("item id", item.id);
               
                _photoModelList.splice( int( item.id ), 1 );      
                _thumbBitmapList.splice( int( item.id ), 1 );     
                _photoSpriteList.splice( int( item.id ), 1 );     
                _selectedList.splice( int( item.id ), 1 );        
                _numPhotos = _photoSpriteList.length;
                
                for(var index:String in _photoSpriteList)
                {
                    PhotoSprite( _photoSpriteList[index] ).index = int( index ); 
                }
               
                onAllItemsLoaded();
                
            }else{
                showMessageOnSWFContainer( "Unkown loading error:" + evt );
            }
        }
        
        private function onHTTPStatusError( evt:HTTPStatusEvent ):void
        {
            trace( "status:", evt.status );
        }
        
        private function loadTumbnail( thumbURLList:Vector.<String> ):void
        {
            var numPhoto:int = thumbURLList.length;
            
            for(var i:int = 0; i < numPhoto; ++i){
//trace(i, thumbURLList[i]);
                _imageLoader.add( thumbURLList[i], { id:i, type:BulkLoader.TYPE_IMAGE, maxTries:5 } );
                _imageLoader.get( String( i )  ).addEventListener( BulkLoader.ERROR, onBulkLoaderError, false, 0, true );
                _imageLoader.get( String( i )  ).addEventListener( BulkLoader.COMPLETE, onOneImageLoaded, false, 0, true );
            }
            _imageLoader.start();
        }
        
        private function onOneImageLoaded( evt:Event ):void
        {
            var item:LoadingItem = evt.target as LoadingItem;
            item.removeEventListener( BulkLoader.COMPLETE, onOneImageLoaded );
            
            var index:int = int( item.id );
//trace("image", index, "has been loaded");

            var photoSprite:PhotoSprite = new PhotoSprite( item.content, _photoModelList[ index ], index)
            photoSprite.sgSelected.add( isDone );

            _thumbBitmapList[ index ] = item.content;
            _photoSpriteList[ index ] = photoSprite; 
        }
        
        private function makeURL( url:String, value:String):String
        {
            if(url != ""){
                return "<u><a href='" + url + "' >" + value + "</a></u>";
            }
            else{
                return "This url doesn't exist!!"; 
            }
        }

        private function loadDefaultImage():void
        {
            var photoList:Array=[];
            var numPhoto:int;     
            
            var photo:PhotoModel = createDefaultImage();
            photoList.push( photo );
            numPhoto = photoList.length;
            
            var thumbURLList:Vector.<String> = new Vector.<String>( numPhoto );
            _photoModelList = new Vector.<PhotoModel>( numPhoto );
            _thumbBitmapList = new Vector.<DisplayObject>( numPhoto );
            _photoSpriteList = new Vector.<Sprite>( numPhoto );
            _selectedList = new Vector.<Boolean>( numPhoto );
            _numPhotos = numPhoto;
            
            for( var i:int = 0; i < numPhoto; ++i )
            {
                thumbURLList[i] = photoList[i].urlThumb;
//trace(photoList[i].urlThumb);                
                _photoModelList[i] = new PhotoModel( photoList[i] );
            }
            
            loadTumbnail( thumbURLList );
        }
        
        private function createDefaultImage():PhotoModel
        {
            var photo:PhotoModel = new PhotoModel();
            photo.title = "Gulu Restaurant";
            photo.urlOwner = "http://dl.dropbox.com/u/9612126/logo_s.png";
            photo.urlSource = "http://dl.dropbox.com/u/9612126/logo_s.png";
            photo.urlThumb = "http://dl.dropbox.com/u/9612126/logo_t.png";
            photo.width = 500;
            photo.height = 500;
            photo.description = "Gulu restaurant logo";
            photo.tags = "gulu, restaurant, logo";
            photo.contentType = -1;
            photo.from = "X";
            
            return photo;        
        }
        
        private function search():void
        {
            var photoList:Array = [];
            var cmd:AsyncCommand = new AsyncCommand(0,
                new AgentCmd( _restaurantName, NUM_SEARCH_RESULT, photoList, _googleAgent, _restaurantAddr),
                new AgentCmd( _restaurantName, NUM_SEARCH_RESULT, photoList, _flickrAgent, _restaurantAddr)
            );
            
            cmd.sgCommandComplete.add( 
                function():void{
                    
                    var numPhoto:int = photoList.length;
                    
                    //if no photo collected from google and flickr, we make one photo to workaround. XD
                    if( numPhoto == 0 ){
                        var photo:PhotoModel = createDefaultImage();
                        photoList.push( photo );
                        numPhoto = photoList.length;
                    }
                    
                    var thumbURLList:Vector.<String> = new Vector.<String>( numPhoto );
                    _photoModelList = new Vector.<PhotoModel>( numPhoto );
                    _thumbBitmapList = new Vector.<DisplayObject>( numPhoto );
                    _photoSpriteList = new Vector.<Sprite>( numPhoto );
                    _selectedList = new Vector.<Boolean>( numPhoto );
                    _numPhotos = numPhoto;
                    
                    for( var i:int = 0; i < numPhoto; ++i )
                    {
                        thumbURLList[i] = photoList[i].urlThumb;
                        _photoModelList[i] = new PhotoModel( photoList[i] );
                    }

                    loadTumbnail( thumbURLList );
            } );
            cmd.start();
        }
        
		override public function destroy():void
		{
			//-----make sure performing folllowing tasks before calling the parent's destory().------------------------
			//Unregister all event listners (particularly Event.ENTER_FRAME, and mouse and keyboard listener).
			//Stop any currently running intervals (via clearInterval()).
			//Stop any Timer objects(via the Time's class instance method stop()).
			//Stop any sounds from playing.
			//Stop the main timeline if it's currently playing.
			//Stop any movie clips that are currently playing.
			//Close any connected nework object, such as an instances of Loader, URLLoader, Socket, XMLSocket, LocalConnection, NetConnection, and NetStream
			//Nullify all references to Camera or Microphone.
			//--------------------------------------------------------------------------------------------------------
			
			super.destroy();
		}

		override public function switchTo(targetScene:IScene):void
		{
			super.switchTo(targetScene);
		}
		
		override public function accessSWF():void
		{
            var preloader_swf:MovieClip = resManager.get("Preloader.swf") as MovieClip;
            
            _preloader_mc = preloader_swf.getChildByName("preloader_mc") as MovieClip;
            addToContextView( _preloader_mc );
            
            var stageWidth:int = sceneManager.stage.stageWidth;
            
            _preloader_mc.x = (stageWidth) >> 1;
            _preloader_mc.y = 100; 
		}	

		override public function accessTXT():void
		{
		}	
		
		override public function accessMP3():void
		{
		}
		
		override public function accessXML():void
		{
			
		}
		
		override public function onKeyDown(event:KeyboardEvent):void
		{
			
			switch(event.keyCode){				
				case Keyboard.F3: 
					sceneManager.switchPerformancePanel();
					break;
			}
			
		}
		
		override public function onClick(event:MouseEvent):void
		{
			
		}
	}
}