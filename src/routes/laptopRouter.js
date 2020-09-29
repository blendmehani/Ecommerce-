const express = require('express');
const sql = require('mssql');
const laptopRouter = express.Router();
const bodyParser = require('body-parser');
const debug = require('debug')('app:laptopRouter');

var urlencodedParser = bodyParser.urlencoded({ extended: false});

const app = express();

function router(nav) {


  laptopRouter.route('/').get((req, res) => {
     
    (async function query() {
      var request = new sql.Request();
      const { recordset } = await request.query('select l.*, ISNULL(r.Rating, 0) AS Rating, ISNULL(r.RatingNumber, 0) AS RatingNumber from Laptops l LEFT JOIN Rating r on l.PId =r.PId');
      const recordset1 = await request.query('select * from ProductSubCategory where PCId = 1');  
      const ratings = await request.query("SELECT TOP 5 * FROM Rating  ORDER BY Rating, RatingNumber DESC");  


      // res.send(newRecordset);
      // res.send(req.body)
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
  });


  laptopRouter.route('/:id').get((req, res) => {
    (async function query() {
      const { id } = req.params;

      var request = new sql.Request();
      const {recordset} = await request.input('id', sql.Int, id).query('select * from Laptops where PId = @id');
      const relatedproducts = await request.input('id', sql.Int, id).query("SELECT TOP 4 RP.*,ISNULL(r.Rating, 0) AS Rating,ISNULL(r.RatingNumber,0) AS RatingNumber FROM RelatedProd(1,'"+recordset[0].subcategory+"') RP LEFT JOIN Rating R ON RP.PId = R.PId WHERE RP.PId NOT IN (@id)");
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
          page_name: 'laptops',
          title: 'BWTech',
          reviews: reviews.recordset,
          rating: rating.recordset[0],
          product: recordset[0],
          relatedproducts: relatedproducts.recordset
        }
      );
    }()); 

  });

  return laptopRouter;

}

module.exports = router;