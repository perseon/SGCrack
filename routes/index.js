var express = require('express');
var router = express.Router();

function calculateKey(pcodcd, plver, plprg, mcodn){

  mlcod = pcodcd.substring(0,6).split('').reduce((result, current,index)=>{return result + current.charCodeAt()*(index+1)},0) + mcodn * plver + plprg.charCodeAt()

  return parseInt((Math.sqrt(mlcod*Math.sqrt(mlcod))% 1)*1000000)

}


router.get('/', function (req, res) {
  // Render the form
  res.render('form')
})



router.post('/', function(req, res, next) {
  let seed = req.body.seed
  let versiune = req.body.ver
  console.log(typeof seed)
  if(seed === "" || versiune == ""){ 
    res.render('error', { message: "Nu sunt definite toate valorile",error:{status:1}});
  } else{
    let result = [calculateKey(seed,versiune,"C",6),calculateKey(seed,versiune,"S",6)];
    res.render('index', { result: result, seed, versiune });
  }
});

module.exports = router;
