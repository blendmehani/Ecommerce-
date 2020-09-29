const express = require('express');
const sql = require('mssql');
const hotdealsRouter = express.Router();
const bodyParser = require('body-parser');
const debug = require('debug')('app:laptopRouter');

var urlencodedParser = bodyParser.urlencoded({ extended: false});

const app = express();

function router(nav) {


  hotdealsRouter.route('/').get((req, res) => {
     
    (async function query() {
      var request = new sql.Request();
      const { recordset } = await request.query('SELECT p.*, ISNULL(r.Rating, 0) AS Rating, ISNULL(r.RatingNumber, 0) AS RatingNumber FROM Product p LEFT JOIN Rating r on p.PId =r.PId WHERE p.OldPrice IS NOT NULL ORDER BY (p.OldPrice-p.Price) DESC');

      const recordset1 = await request.query('select * from ProductSubCategory where PCId = 1');  
      const ratings = await request.query("SELECT TOP 5 * FROM Rating ORDER BY Rating, RatingNumber DESC");  


      res.render(
        'hotdeals',
        {
          nav,
          page_name : 'hotdeals',
          title: 'BWTech',
          products: recordset,
          subcategory: recordset1.recordset, 
          ratings: ratings.recordset
        });
    }());
  });

  hotdealsRouter.route('/:id').get((req, res) => {
    (async function query() {
      const { id } = req.params;

      var request = new sql.Request();
      const {recordset} = await request.input('id', sql.Int, id).query('select * from Product p inner join ProductSubCategory psc on psc.PSCId = p.PSCId inner join ProductCategory pc on pc.PCID = p.PCID where PId = @id');

      const relatedproducts = await request.query("SELECT TOP 4 RP.*,ISNULL(r.Rating, 0) AS Rating,ISNULL(r.RatingNumber,0) AS RatingNumber FROM RelatedProd(1,'"+recordset[0].subcategory+"') RP LEFT JOIN Rating R ON RP.PId = R.PId WHERE RP.PId NOT IN (@id)");
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
          page_name: 'hotdeals',
          title: 'BWTech',
          reviews: reviews.recordset,
          rating: rating.recordset[0],
          product: recordset[0],
          relatedproducts: relatedproducts.recordset
        }
      );
    }()); 

  });

  return hotdealsRouter;

}

module.exports = router;