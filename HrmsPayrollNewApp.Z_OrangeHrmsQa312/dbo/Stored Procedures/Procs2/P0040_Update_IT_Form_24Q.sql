

/*
Created To Update IT_24Q Form
Mayur modi on 15/05/2019
*/
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
 CREATE PROCEDURE [dbo].[P0040_Update_IT_Form_24Q]
  @Cmp_ID NUMERIC(18, 0),
  @Trans_id NUMERIC(18, 0),
  @IT_24Q_id INT,
  @Financial_Year VARCHAR(100),
  @cnt INT
AS
  BEGIN


	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON


      IF @cnt = 0
        BEGIN
            UPDATE T0100_IT_FORM_DESIGN
            SET    COLUMN_24Q = 0
            WHERE  CMP_ID = @Cmp_ID AND Financial_Year = @Financial_Year

            UPDATE T0100_IT_FORM_DESIGN
            SET    column_24q = @IT_24Q_id
            WHERE  tran_id = @Trans_id
                   AND cmp_id = @Cmp_ID AND Financial_Year = @Financial_Year
        END
      ELSE
        BEGIN
            UPDATE T0100_IT_FORM_DESIGN
            SET    COLUMN_24Q = @IT_24Q_id
            WHERE  TRAN_ID = @Trans_id
                   AND cmp_id = @Cmp_ID AND Financial_Year = @Financial_Year
        END
  END  




