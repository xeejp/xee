/*--------------------------------------------------------------------------*
 *  
 *  footerFixed.js
 *  
 *  MIT-style license. 
 *  
 *  2007 Kazuma Nishihata [to-R]
 *  http://blog.webcreativepark.net
 *  
 *--------------------------------------------------------------------------*/

new function(){
	
	var footerId = "footer";
	//メイン
	function footerFixed(){
          var dh = document.getElementsByTagName("body")[0].clientHeight;
          document.getElementById('footer').style.top = "0px";
          document.getElementById('main').style.top = "0px";
          document.getElementById('main').style.minHeight = "0px";  
          var ft = document.getElementById('footer').offsetTop;
          var mt = document.getElementById('main').offsetTop;
          var fh = document.getElementById('footer').offsetHeight;
          if (window.innerHeight){
            var wh = window.innerHeight;
          }else if(document.documentElement && document.documentElement.clientHeight != 0){
            var wh = document.documentElement.clientHeight;
          }
          if(ft+fh<wh){
            document.getElementById('main').style.minHeight = (wh-mt-fh-15)+"px";  
          }
          ft = document.getElementById('footer').offsetTop;
          if(ft+fh<wh){
            document.getElementById('footer').style.position = "relative";
            document.getElementById('footer').style.top = (wh-fh-ft-1)+"px";
          }
	}
	
	//文字サイズ
	function checkFontSize(func){
	
		//判定要素の追加	
		var e = document.createElement("div");
		var s = document.createTextNode("S");
		e.appendChild(s);
		e.style.visibility="hidden"
		e.style.position="absolute"
		e.style.top="0"
		document.body.appendChild(e);
		var defHeight = e.offsetHeight;
		
		//判定関数
		function checkBoxSize(){
			if(defHeight != e.offsetHeight){
				func();
				defHeight= e.offsetHeight;
			}
		}
		setInterval(checkBoxSize,1000)
	}
	
	//イベントリスナー
	function addEvent(elm,listener,fn){
		try{
			elm.addEventListener(listener,fn,false);
		}catch(e){
			elm.attachEvent("on"+listener,fn);
		}
	}

	addEvent(window,"load",footerFixed);
	addEvent(window,"load",function(){
		checkFontSize(footerFixed);
	});
	addEvent(window,"resize",footerFixed);
}