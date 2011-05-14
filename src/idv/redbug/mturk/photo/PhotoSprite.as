/*******************************************
 * author	: Redbug
 * e-mail	: l314kimo@gmail.com
 * blog		: http://redbug0314.blogspot.com
 * purpose	:		
 *******************************************/

package idv.redbug.mturk.photo
{
    import fl.controls.RadioButton;
    import fl.controls.RadioButtonGroup;
    import fl.motion.Color;
    
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.StyleSheet;
    import flash.text.TextColorType;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    
    import org.osflash.signals.Signal;
    
    public class PhotoSprite extends Sprite
    {
        private const MAX_DESCRIPTION :uint = 150;
        
        private var _model          :PhotoModel;
        private var _bitmap         :DisplayObject;
        private var _title_txt      :TextField;
        private var _tags_txt       :TextField;
        private var _description_txt:TextField;
        private var _reference_txt  :TextField;
        
        private var _ct_restaurant_rb  :RadioButton;
        private var _ct_dish_rb        :RadioButton; 
        private var _ct_logo_rb        :RadioButton;
        private var _ct_none_rb        :RadioButton;
        private var _ct_rb_group       :RadioButtonGroup;
        
        private var _box                :Sprite; 
        private var _index              :int;
        
        private var _sgSelected         :Signal;
        
        public function PhotoSprite( bitmap:DisplayObject, model:PhotoModel, index:int)
        {
            _model = model;
            _bitmap = bitmap;
            _index = index;
            _sgSelected = new Signal( int );
            
            makeUI();
            this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );	//removed in onAddedToStage()
        }
        
        private function makeURL( url:String, value:String):String
        {
            if(url != ""){
                return "<u><a href='" + url + "' target='_blank'>" + value + "</a></u>";
            }
            else{
                return "This url doesn't exist!!"; 
            }
        }
        
        private function onAddedToStage( event:Event ):void
        {
            this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );	
        }
        
        private function makeUI():void
        {
            var width   :int = 150;
            var x       :int = 0;
            var y       :int = 0;
            var space   :int = 20;
            
            var center:TextFormat = new TextFormat();
            center.align="center";
            
            var color = 0xFF3366;
            
            //--  title --//
            _title_txt = new TextField();
            _title_txt.htmlText = "Photo Title:"
            _title_txt.setTextFormat( new TextFormat(null, null, color, true) );
            _title_txt.htmlText += "\n" + _model.title;
            _title_txt.setTextFormat(center);
            _title_txt.width = width;
            _title_txt.x = x;
            _title_txt.y = y;
            _title_txt.autoSize = TextFieldAutoSize.CENTER
            _title_txt.wordWrap = true;
            
            
            //--  restaurant photo --//
            _bitmap.x = ( width - _bitmap.width ) >> 1;
            _bitmap.y = _title_txt.height;
            
            
            //-- reference url --//
            var css:StyleSheet = new StyleSheet();
            
            var linkStyle:Object = { 
                color:"#0000FF",
                textAlign:"center"
            };
            css.setStyle("a", linkStyle);
            
            var reference_wraper:Sprite = new Sprite();
            reference_wraper.buttonMode = true;
            reference_wraper.useHandCursor = true;
            
            _reference_txt = new TextField();
            _reference_txt.styleSheet = css;
            _reference_txt.text = makeURL( _model.urlOwner, "view source page");
            _reference_txt.width = width;
            _reference_txt.x = x;
            _reference_txt.y = _bitmap.y + _bitmap.height;
            _reference_txt.autoSize = TextFieldAutoSize.CENTER
            _reference_txt.wordWrap = true;
            reference_wraper.addChild(_reference_txt );
            
            
            //-- radio buttons --//
            _ct_restaurant_rb = new RadioButton();
            _ct_dish_rb = new RadioButton();
            _ct_logo_rb = new RadioButton();
            _ct_none_rb = new RadioButton();
            _ct_rb_group = new RadioButtonGroup("ct_group");
            
            _ct_restaurant_rb.label = "Restaurant"; 
            _ct_restaurant_rb.value = PhotoModel.CT_RESTAURANT;
            
            _ct_dish_rb.label = "Dish"; 
            _ct_dish_rb.value = PhotoModel.CT_DISH;
            
            _ct_logo_rb.label = "Logo"; 
            _ct_logo_rb.value = PhotoModel.CT_LOGO;
            
            _ct_none_rb.label = "None of the above";
            _ct_none_rb.value = PhotoModel.CT_NONE;
            _ct_none_rb.width = 130;
            
            _ct_restaurant_rb.group = _ct_dish_rb.group = _ct_logo_rb.group = _ct_none_rb.group = _ct_rb_group;

            y = _bitmap.y + _bitmap.height;
            
            _ct_restaurant_rb.move(x, y + space); 
            _ct_dish_rb.move(x, _ct_restaurant_rb.y + space); 
            _ct_logo_rb.move(x, _ct_dish_rb.y + space); 
            _ct_none_rb.move(x, _ct_logo_rb.y + space);
            
            
            var contentType:int = _model.contentType; 
            
            if( contentType != -1 )
            {
                switch( contentType ){
                    case PhotoModel.CT_NONE:
                        _ct_none_rb.selected = true;
                        break;
                    case PhotoModel.CT_RESTAURANT:
                        _ct_restaurant_rb.selected = true;
                        break;
                    case PhotoModel.CT_DISH:
                        _ct_dish_rb.selected = true;
                        break;
                    case PhotoModel.CT_LOGO:
                        _ct_logo_rb.selected = true;
                        break;
                }
            }
            
            
            //-----  Box ------//
            _box = new Sprite();
            _box.x = x;
            _box.y = _ct_restaurant_rb.y;
            _box.graphics.beginFill(0xFFFFFF, 1.0); 
            _box.graphics.drawRect(0, 0, width, space * 4); 
            _box.graphics.endFill();   
            
            
            //-- tags --//
            _tags_txt = new TextField();
            _tags_txt.text = "Tags: \n";
            _tags_txt.setTextFormat( new TextFormat(null, null, color, true) );
            
            var tags:String = _model.tags;
            tags = (tags == "")? "None.":tags;
                
            _tags_txt.appendText( tags );
            
            _tags_txt.width = width;
            _tags_txt.x = x;
            _tags_txt.y = _box.y + _box.height + space;
            _tags_txt.autoSize = TextFieldAutoSize.CENTER
            _tags_txt.wordWrap = true;
            
            
            //-- description --//
            _description_txt = new TextField();
            _description_txt.text = "Description: \n";
            _description_txt.setTextFormat( new TextFormat(null, null, color, true) );
            
            var description:String;
            if( model.from == "F" ){
                description = _model.description.substr(0, MAX_DESCRIPTION); 
                description = ( description == "" )? "None.":description + "...";
            } else{
                description = _model.description;
                description = ( description == "" )? "None.":description;
            }
            
            _description_txt.appendText( description );
            _description_txt.width = width;
            _description_txt.x = x;
            _description_txt.y = _tags_txt.y + _tags_txt.height + space;
            _description_txt.autoSize = TextFieldAutoSize.CENTER
            _description_txt.wordWrap = true;
            
            
            this.addChild( _title_txt );
            this.addChild( _bitmap );
            this.addChild( _box ); 
            this.addChild( _ct_restaurant_rb ); 
            this.addChild( _ct_dish_rb ); 
            this.addChild( _ct_logo_rb );
            this.addChild( _ct_none_rb );
            this.addChild( _tags_txt );
            this.addChild( _description_txt );
            this.addChild( reference_wraper );
            
            _ct_rb_group.addEventListener( MouseEvent.CLICK, onClickRadioButton );
        }

        private function onClickRadioButton(event:Event):void {
            _model.contentType = event.target.selection.value;
            _sgSelected.dispatch( _index );
        }
        
        public function get bitmap():DisplayObject
        {
            return _bitmap;
        }
        
        public function set bitmap( value:DisplayObject ):void
        {
            _bitmap = value;
        }

        public function get model():PhotoModel
        {
            return _model;
        }

        public function set model(value:PhotoModel):void
        {
            _model = value;
        }

        public function get sgSelected():Signal
        {
            return _sgSelected;
        }

        public function set sgSelected(value:Signal):void
        {
            _sgSelected = value;
        }

        public function get index():int
        {
            return _index;
        }

        public function set index(value:int):void
        {
            _index = value;
        }

    }
}