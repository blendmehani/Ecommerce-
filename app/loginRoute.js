const express = require('express');
const bodyParser = require('body-parser');
const loginRoute = express.Router();
var urlencodedParser = bodyParser.urlencoded({ extended: true});
const debug = require('debug');
sql =require('mssql');

sql.close();
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


module.exports = function(app, passport) {

    app.get('/login', function(req, res){
     if(req.user==null)
     res.render('login.ejs', {message:req.flash('loginMessage')});
     else
     res.redirect('/api');
    });
  
    app.post('/login',urlencodedParser, passport.authenticate('local-login', {
        
     successRedirect: '/api',
     failureRedirect: '/login',
     failureFlash: 'true' ,
 
    }),
     function(req, res){
      if(req.body.remember){
       req.session.cookie.maxAge = 1000 * 60 * 3;
      }else{
       req.session.cookie.expires = false;
      }
      res.redirect('/');
     });


     
 app.get('/signup',isLoggedIn, function(req, res){

    res.render('signup.ejs', {message: req.flash('signupMessage')});

   
   });
  
   app.post('/signup',urlencodedParser, passport.authenticate('local-signup', {
    successRedirect: '/login',
    failureRedirect: '/signup',
    failureFlash: true

   }));





    app.get('/api', isLoggedIn, function(req, res){
    (async function query() {   
     var request = new sql.Request(); 
     const products = await request.query('SELECT PId,Name,Price,OldPrice FROM Product');
     res.render('api.ejs', {
      user:req.user,
      products: products.recordset
     });
    }());
    });

    app.get('/logout', function(req,res){
     req.logout();
     res.redirect('/login');
    })
   };

   function isLoggedIn(req, res, next){
 

        if(req.isAuthenticated()==true)
        return next();
        else{
        res.redirect('/login');
        }

 
   }
