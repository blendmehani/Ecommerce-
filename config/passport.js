// (function () {
//   'use strict';

// const sql = require('mssql');
// const passport = require('passport');
// const LocalStrategy = require('passport-local').Strategy;
// const debug = require('debug');




// const connection = new sql.ConnectionPool('mssql://sa:BM@261195@BLENDMEHANI/Ecommerce');

// // const connection = new sql.Connection('mssql://username:password@localhost/database');
// const bcrypt = require('bcrypt-nodejs');
// // var dbconfig = require('./database');
// // var connection = mysql.createConnection(dbconfig.connection);

// const deserializeQuery = 'SELECT * FROM [Admin] WHERE AId =';
// const strategyQuery = 'SELECT AId, [username], [password] FROM [Admin] WHERE [username] = @usernameParam';


// module.exports = function () {
//   // serialize sessions
//   passport.serializeUser((user, done) => {
//     done(null, user.id);
//   });

//   passport.deserializeUser((id, done) => {
//     const request = new sql.Request();
//     request.query(`${deserializeQuery} ${id}`, (err, recordset) => {
//       done(err, recordset[0]);
//     });
//   });

//   // use local strategy
//   passport.use('local-login',new LocalStrategy(
//     (username, password, done) => {
//       const ps = new sql.PreparedStatement();
//       ps.input('usernameParam', sql.NVarChar);
//       ps.prepare(strategyQuery, (err) => {
//         // catch prepare error
//         if (err) {
//           return done(err);
//         }

//         ps.execute({
//           usernameParam: username,
//         }, (err, recordset) => {
//           // catch execute error
//           if (err) {
//             return done(err);
//           }

//           ps.unprepare((err) => {
//             // catch unprepare error
//             if (err) {
//               return done(err);
//             }
//           });

//           // user does not exist
//           if (recordset.length <= 0) {
//             return done(null, false, {
//               message: 'Invalid username or password',
//             });
//           }
//           else {
//             const user = recordset[0];
//             // compare input to hashed password in database
//             const isValid = bcrypt.compareSync(password, user.password);

//             if (isValid) {
//               // user
//               return done(null, user);
//             }
//             else {
//               // password is invalid
//               return done(null, false, {
//                 message: 'Invalid username or password',
//               });
//             }
//           }
//         });
//       });
//     }));
// };
// })();




const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;
const debug = require('debug');
const bcrypt = require('bcrypt-nodejs');
const sql = require('mssql');



module.exports = function(passport) {

 passport.serializeUser(function(user, done){
  done(null, user);
 });

 passport.deserializeUser(function(user, done){
   done(null,user);
 })

//  passport.deserializeUser(function(user, done){
//   connection.query("SELECT * FROM [Admin] WHERE username = "+[user.username],
//    function(err, recordset){
//     done(err, recordset.recordset[0]);
//    });
//  });


 passport.use(
  'local-login',
  new LocalStrategy({
   usernameField : 'username',
   passwordField: 'password',
   passReqToCallback: true
  },
  function(req, username, password, done){
    var request = new sql.Request();
   request.query("SELECT * FROM [Admin] WHERE username = '"+[username]+"'",
   function(err, recordset){
    if(err)
     return done(err);
    if(!recordset.recordset.length){
     return done(null, false, req.flash('loginMessage', 'No User Found'));
    }
    if(!bcrypt.compareSync(password, recordset.recordset[0].password))
//    if(!bcrypt.compareSync(password, recordset.recordset[0]))
     return done(null, false, req.flash('loginMessage', 'Wrong Password'));

    return done(null, recordset.recordset[0]);
   });
  })
 );
};


passport.use(
  'local-signup',
  new LocalStrategy({
   usernameField : 'username',
   passwordField: 'password',
   passReqToCallback: true
  },
  function(req, username, password, done){
    const request = new sql.Request();
    
   request.query("SELECT * FROM [Admin] WHERE username = '"+[username]+"'", 
    function(err, recordset){  
    if(err)
     return done(err);
    if(recordset.recordset.length>0){
     return done(null, false, req.flash('signupMessage', 'That is already taken'));
    }else{
     var newUserMssql = {
      username: username,
      password: bcrypt.hashSync(password, null, null)
     };

    //  var insertQuery = "INSERT INTO [Admin] (username, password) values (?, ?)";
     var request = new sql.Request();
     request.query("INSERT INTO [Admin] values('"+newUserMssql.username+"','"+newUserMssql.password+"')",
         function(err, recordset){
      
      if(err){
      console.log(err);
      }

       return done(null, recordset.rowsAffected);
  //     return status(204).send();

      });
    }
   });
  })
 );