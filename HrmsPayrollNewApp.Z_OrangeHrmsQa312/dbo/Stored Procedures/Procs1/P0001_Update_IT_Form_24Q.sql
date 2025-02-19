

/*
Created To Update IT_24Q Form
Mayur modi on 15/05/2019
*/
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
 CREATE PROCEDURE [dbo].[P0001_Update_IT_Form_24Q]
  @Cmp_ID NUMERIC(18, 0),
  @Trans_id NUMERIC(18, 0),
  @IT_24Q_id INT,
  @cnt INT
AS
  BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

      IF @cnt = 0
        BEGIN
            UPDATE t0100_it_form_design
            SET    column_24q = 0
            WHERE  cmp_id = @Cmp_ID

            UPDATE t0100_it_form_design
            SET    column_24q = @IT_24Q_id
            WHERE  tran_id = @Trans_id
                   AND cmp_id = @Cmp_ID
        END
      ELSE
        BEGIN
            UPDATE t0100_it_form_design
            SET    column_24q = @IT_24Q_id
            WHERE  tran_id = @Trans_id
                   AND cmp_id = @Cmp_ID
        END
  END  




