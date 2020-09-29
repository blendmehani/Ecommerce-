const express = require('express');
const chalk = require('chalk');
const morgan = require('morgan');
const debug = require('debug')('app');
const path = require('path');
const sql = require('mssql');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const passport = require('passport');
const flash = require('connect-flash');
var session = require('express-session');
const upload = require('express-fileupload');


var urlencodedParser = bodyParser.urlencoded({ extended: true});

const app = express();
const port = process.env.PORT || 3000;

const config = {
  user: 'blendmehani',
  password: 'BM@261195',
  server: 'blendmehani.database.windows.net', // You can use 'localhost\\instance' to connect to named instance
  database: 'Ecommerce',
  

  options: {
    rowCollectionOnDone: true,
    encrypt: true
  }
};

sql.connect(config).catch((err) => debug(err));

app.use(morgan('combined'));
app.use(express.static(path.join(__dirname, 'public')));
app.use('/css', express.static(path.join(__dirname, 'nodemodules/bootstrap/dist/css')));
app.use('/js', express.static(path.join(__dirname, 'nodemodules/bootstrap/dist/js')));
app.use('/js', express.static(path.join(__dirname, 'nodemodules/jquery/dist/')));

app.use(cookieParser());

app.set('views', './src/views');
//app.set('view engine', 'pug');
app.set('view engine', 'ejs');

const nav = [
  { link: '/', title: 'Home' },
  { link: '/hotdeals', title: 'Hot Deals' },
  { link: '/laptops', title: 'Laptops' },
  { link: '/smartphones', title: 'Smartphones' },
  { link: '/cameras', title: 'Cameras' },
  { link: '/accessories', title: 'Accessories' }]


  //


app.use(session({
  secret: 'justasecret',
 
  saveUninitialized: true,
  resave:true,
  
  httpOnly: true,
  secure: true
 }));

 app.use(passport.initialize());
app.use(passport.session());
app.use(flash());
require('./config/passport.js')(passport);
require('./app/loginRoute.js')(app, passport);


const laptopRouter = require('./src/routes/laptopRouter')(nav);
const smartphoneRouter = require('./src/routes/smartphoneRouter')(nav);
const cameraRouter = require('./src/routes/cameraRouter')(nav);
const accessoryRouter = require('./src/routes/accessoryRouter')(nav);
const hotdealsRouter = require('./src/routes/hotdealsRouter')(nav);
app.use('/Laptops', laptopRouter);
app.use('/SmartPhones', smartphoneRouter);
app.use('/Cameras', cameraRouter);
app.use('/Accessories', accessoryRouter);
app.use('/hotdeals', hotdealsRouter);


app.get('/', (req, res) => {

  (async function query() {
    var request = new sql.Request();
    const { recordset } = await request.query("SELECT TOP 10 p.*,ISNULL(r.Rating, 0) AS Rating,ISNULL(r.RatingNumber,0) AS RatingNumber FROM Product p LEFT JOIN Rating r on p.PId =r.PId WHERE DateInserted > DATEADD(DAY, -14, GETDATE()) ORDER BY DateInserted DESC");
    const rating = await request.query("SELECT TOP 10 * FROM Rating ORDER BY RatingNumber, Rating DESC");
    const hotdeals = await request.query("SELECT TOP 1 OldPrice,Price FROM Product WHERE OldPrice IS NOT NULL OR OldPrice != 0 ORDER BY (OldPrice-Price)/OldPrice DESC");
    debug(hotdeals);
    res.render(
      'index',
      {
        nav,
        // page_name : 'all_categories',
        title: 'BWTech',
        products: recordset,
        ratings: rating.recordset,
        hotdeals: hotdeals.recordset[0]
      });
  }());

});

// app.post('/', urlencodedParser, (req, res) => {
//   var month = req.body.prodoptions;
//   if(month = 1)
//     res.render('products');

// });

app.post('/search', urlencodedParser, (req, res) => {
  // document.getElementById("myForm").submit();
 
  // var month = req.body.formhere;
  // console.log(month);
  // if(month = 1)
  //   res.json(month);
  if (req.body.formhere == 0){


    (async function query() {
      var request = new sql.Request();
      const { recordset } = await request.query("SELECT * FROM product WHERE Name LIKE '%"+req.body.searchhere+"%'");
      const recordset1 = await request.query('select * from ProductSubCategory');
      const ratings = await request.query("SELECT TOP 5 * FROM Rating  ORDER BY Rating, RatingNumber DESC");
      if(recordset.recordset!=null){
      var category =recordset[0].PCID;
      if(category ==1){
       var categoryName='laptops';
      }else if(category==2){
       var categoryName='smartphones';
      }else if(category==3){
       var categoryName='cameras';
      }else if(category==4){
       var categoryName='accessories';
      }else{
        var categoryName='nocat'
      }
    }
      if(recordset.recordset !=null){
      res.render(
        'products',
        {
          nav,
          page_name : categoryName,
          title: 'BWTech',
          products: recordset,
          subcategory: recordset1.recordset,
          ratings: ratings.recordset
        });
      }
      else{
        res.render(
          'products',
          {
            nav,
            page_name : 'no Products',
            title: 'BWTech',
            products: recordset,
            subcategory: recordset1.recordset,
            ratings: ratings.recordset
          });
      }
    }());
    
  }

  else if ( req.body.formhere == 1){ 
 
    (async function query() {
      var request = new sql.Request();
      const { recordset } = await request.query("SELECT * FROM Laptops WHERE Name LIKE '%"+req.body.searchhere+"%'");
      const recordset1 = await request.query('select * from ProductSubCategory where PCId = 1'); 
      const ratings = await request.query("SELECT TOP 5 * FROM Rating  ORDER BY Rating, RatingNumber DESC"); 
      res.render(
        'products',
        {
          nav,
          page_name : 'laptops',
          title: 'BWTech',
          products: recordset,
          subcategory: recordset1.recordset,
          ratings: ratings.recordset
        });
    }());
  }
    
  else if ( req.body.formhere == 2){

    (async function query() {
      var request = new sql.Request();
      const { recordset } = await request.query("SELECT * FROM SmartPhones WHERE Name LIKE '%"+req.body.searchhere+"%'");
      const recordset1 = await request.query('select * from ProductSubCategory where PCId = 2');
      const ratings = await request.query("SELECT TOP 5 * FROM Rating  ORDER BY Rating, RatingNumber DESC");   
      res.render(
        'products',
        {
          nav,
          page_name : 'smartphones',
          title: 'BWTech',
          products: recordset,
          subcategory: recordset1.recordset,
          ratings: ratings.recordset
        });
    }()); 
  }    
  else if (req.body.formhere == 3){

    (async function query() {
      var request = new sql.Request();
      const { recordset } = await request.query("SELECT * FROM Cameras WHERE Name LIKE '%"+req.body.searchhere+"%'");
      const recordset1 = await request.query('select * from ProductSubCategory where PCId = 3');  
      const ratings = await request.query("SELECT TOP 5 * FROM Rating  ORDER BY Rating, RatingNumber DESC"); 
      res.render(
        'products',
        {
          nav,
          page_name : 'cameras',
          title: 'BWTech',
          products: recordset,
          subcategory: recordset1.recordset,
          ratings: ratings.recordset
        });
    }()); 
 
  }
  else if (req.body.formhere == 4){

    (async function query() {
      var request = new sql.Request();
      const { recordset } = await request.query("SELECT * FROM Accessories WHERE Name LIKE '%"+req.body.searchhere+"%'");
      const recordset1 = await request.query('select * from ProductSubCategory where PCId = 4');  
      const ratings = await request.query("SELECT TOP 5 * FROM Rating  ORDER BY Rating, RatingNumber DESC"); 
      res.render(
        'products',
        {
          nav,
          page_name : 'accessories',
          title: 'BWTech',
          products: recordset,
          subcategory: recordset1.recordset,
          ratings: ratings.recordset
        });
    }()); 
 
  }
});

app.post('/review', urlencodedParser, (req, res) => {

  //  res.send(req.body.pagename)
    
    var request = new sql.Request();
    request.query("INSERT INTO Review(ReviewerName, ReviewerEmail, ReviewComment, Rating, PId) VALUES ('" + req.body.name + "', '" + req.body.email + "', '" + req.body.review + "', '" + req.body.rating + "', '" + req.body.id + "')", function (err, recordset) {
    if (err) {
      console.log(err);
      return res.send('Error occured');
    }
 
    res.status(204).send();

    // res.send(location.reload());


  });
});

app.use(upload());

app.post('/delete', urlencodedParser, (req, res) => {

  var request = new sql.Request();
  request.query('DELETE FROM Product where PId ='+req.body.PId, function (err, recordset) {
    if (err) {
      console.log(err);
      return res.send('Error occured');
    }
    res.redirect(req.get('referer'));
  })
});

app.post('/edit', urlencodedParser, (req,res) =>{

  var request = new sql.Request();
  request.query('UPDATE Product SET Price ='+req.body.price+', OldPrice ='+req.body.oldprice+'WHERE PId='+req.body.PId, function (err, recordset) {
    if (err) {
      console.log(err);
      return res.send('Error occured');
    }
    res.redirect(req.get('referer'));
  })
});


app.post('/insert', urlencodedParser, (req, res) => {
  if(req.files){  
    var file = req.files.photo1,
        photo1 = file.name;
        file.mv("./public/img/products/"+photo1)
    if(req.files.photo2 !=null){
      var file = req.files.photo2,
          photo2 = file.name;
          file.mv("./public/img/products/"+photo2)}
    else{
      photo2 = 'NULL';
    }      
    if(req.files.photo3 !=null){
       var file = req.files.photo3,
           photo3 = file.name;
           file.mv("./public/img/products/"+photo3)}
    else{
      photo3 = 'NULL';
    }  
    if(req.files.photo4 !=null){
       var file = req.files.photo4,
           photo4 = file.name;
           file.mv("./public/img/products/"+photo4)}
    else{
      photo4 = 'NULL';
    }         
    if(req.files.photo5 !=null){
       var file = req.files.photo5,
           photo5 = file.name;
           file.mv("./public/img/products/"+photo5)}
    else{
      photo5 = 'NULL';
    }    

      var datetime = new Date();
      //console.log(datetime.toISOString().slice(0,10));

      var category = req.body.category;
      var subcategory = null;
      if(category==1){
        subcategory = req.body.subcategory1;
      }else if(category ==2){
        subcategory = req.body.subcategory2;
      }else if(category==3){
        subcategory = req.body.subcategory3;
      }else if(category ==4){
        subcategory = req.body.subcategory4;
      }

    var request = new sql.Request();
    request.query("INSERT INTO Product(Name, Price, Description, DetailedDescription, Color, Size, Weight,Image1,Image2,Image3,Image4,Image5,PCID,PSCId,DateInserted) VALUES('" + req.body.name + "', '" 
    + req.body.price + "', '" + req.body.description + "', '" + req.body.specs + "', '" + req.body.color + "', '" + req.body.size + "', '" 
    + req.body.weight + "', '" + photo1 + "', '" + photo2 + "', '" + photo3 + "', '" + photo4 + "', '" + photo5 +"', '" 
    + req.body.category + "', '" + subcategory + "', '" + datetime.toISOString().slice(0,10) +  "')", function (err, recordset) {
      if (err) {
        console.log(err);
        return res.send('Error occured');
      }
   
      //res.status(204).send();
      res.redirect(req.get('referer'));
    })
  }



});
app.listen(port, () => {
  console.log(`${chalk.red('listening on port')} ${chalk.yellow(port)}`);
});
