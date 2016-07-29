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
  //ƒƒCƒ“
  function footerFixed(){
    //ƒhƒLƒ…ƒƒ“ƒg‚Ì‚‚³
    var dh = document.getElementsByTagName("body")[0].clientHeight;
    //ƒtƒbƒ^[‚Ìtop‚©‚ç‚ÌˆÊ’u
    document.getElementById(footerId).style.top = "0px";
    var ft = document.getElementById(footerId).offsetTop;
    //ƒtƒbƒ^[‚Ì‚‚³
    var fh = document.getElementById(footerId).offsetHeight;
    //ƒEƒBƒ“ƒhƒE‚Ì‚‚³
    if (window.innerHeight){
      var wh = window.innerHeight;
    }else if(document.documentElement && document.documentElement.clientHeight != 0){
      var wh = document.documentElement.clientHeight;
    }
    if(ft+fh<wh){
      document.getElementById(footerId).style.position = "relative";
      document.getElementById(footerId).style.top = (wh-fh-ft-1)+"px";
    }
  }

  //•¶ŽšƒTƒCƒY
  function checkFontSize(func){

    //”»’è—v‘f‚Ì’Ç‰Á	
    var e = document.createElement("div");
    var s = document.createTextNode("S");
    e.appendChild(s);
    e.style.visibility="hidden"
      e.style.position="absolute"
      e.style.top="0"
      document.body.appendChild(e);
    var defHeight = e.offsetHeight;

    //”»’èŠÖ”
    function checkBoxSize(){
      if(defHeight != e.offsetHeight){
        func();
        defHeight= e.offsetHeight;
      }
    }
    setInterval(checkBoxSize,1000)
  }

  //ƒCƒxƒ“ƒgƒŠƒXƒi[
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
