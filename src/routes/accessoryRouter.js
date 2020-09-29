const express = require('express');
const sql = require('mssql');
const accessoryRouter = express.Router();
const bodyParser = require('body-parser');
const debug = require('debug')('app:accessoryRouter');

var urlencodedParser = bodyParser.urlencoded({ extended: false});

const app = express();

function router(nav) {


  accessoryRouter.route('/').get((req, res) => {
     
    (async function query() {
      var request = new sql.Request();
      const { recordset } = await request.query('select a.*, ISNULL(r.Rating, 0) AS Rating, ISNULL(r.RatingNumber, 0) AS RatingNumber from Accessories a LEFT JOIN Rating r on a.PId =r.PId');
      const recordset1 = await request.query('select * from ProductSubCategory where PCId = 4');  
      const ratings = await request.query("SELECT TOP 5 * FROM Rating ORDER BY Rating, RatingNumber DESC");  

      const newRecordset=[] 
      for(let i =0;i<20;i++){
       newRecordset.push(recordset[i]);
      }
      // res.send(newRecordset);
      // res.send(req.body)
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
  });


  accessoryRouter.route('/:id').get((req, res) => {
    (async function query() {
      const { id } = req.params;

      var request = new sql.Request();
      const {recordset} = await request.input('id', sql.Int, id).query('select * from Accessories where PId = @id');
      const relatedproducts = await request.input('id', sql.Int, id).query("SELECT TOP 4 RP.*,ISNULL(r.Rating, 0) AS Rating,ISNULL(r.RatingNumber,0) AS RatingNumber FROM RelatedProd(4,'"+recordset[0].subcategory+"') RP LEFT JOIN Rating R ON RP.PId = R.PId WHERE RP.PId NOT IN (@id)");
      const reviews = await request.input('id', sql.Int, id).query('select * from Review where PId = @id');
      const rating = await request.input('id', sql.Int, id).query('select * from Rating where PId = @id');
      debug(reviews);
      if(rating.rowsAffected == 0){
        rating.recordset.push(0);
      }
      debug(reviews);
      res.render(
        'product',
        {
          nav,
          page_name: 'accessories',
          title: 'BWTech',
          reviews: reviews.recordset,
          rating: rating.recordset[0],
          product: recordset[0],
          relatedproducts: relatedproducts.recordset
        }
      );
    }()); 

  });

  return accessoryRouter;

}

module.exports = router;