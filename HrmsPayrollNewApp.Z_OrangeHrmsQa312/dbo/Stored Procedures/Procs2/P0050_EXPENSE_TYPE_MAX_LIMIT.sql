  
  
-- =============================================  
-- Author:  <ANKIT>  
-- ALTER date: <17102014,,>  
-- Description: <Description,,>  
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[P0050_EXPENSE_TYPE_MAX_LIMIT]   
      @Tran_ID   NUMERIC(18,0) OUTPUT,  
      @Cmp_ID   NUMERIC(18,0) ,  
      @Expense_Type_ID NUMERIC(18,0) ,  
   @Grd_Id   VARCHAR(50),  
   @Amount   NUMERIC(18,2),  
   @Flag_GrdDesig tinyint=0,  
   @Flag_CityCat tinyint=0,  
   @EffectDate datetime,  
   @CityCatID numeric(18,0),  
   @CityCatAmnt numeric(8,2),  
   @DesigID numeric(18,0),  
   @Tran_Type   VARCHAR(1)  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
BEGIN  
 If Upper(@Tran_Type) = 'I'  
   BEGIN  
    --IF EXISTS (SELECT TRAN_ID  FROM T0050_EXPENSE_TYPE_MAX_LIMIT WHERE CMP_ID = @Cmp_ID AND Expense_Type_ID = @Expense_Type_ID and City_Cat_ID=@CityCatID and Amount=@Amount and (GRD_ID = @Grd_Id or Desig_ID=@DesigID))    
    -- BEGIN  
    -- --print 'sdp'  
    --  set @Tran_ID = 0  
    --  Return   
    -- END  
      
    SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)   
  
    INSERT INTO T0050_EXPENSE_TYPE_MAX_LIMIT  
               (TRAN_ID,CMP_ID,Expense_Type_ID,Grd_Id,Amount,Flag_Grd_Desig,City_Cat_ID,City_Cat_Amount,Desig_ID,Effective_Date,City_Cat_Flag)  
    VALUES     (@Tran_ID,@Cmp_ID,@Expense_Type_ID,@Grd_Id,@Amount,@Flag_GrdDesig,@CityCatID,@CityCatAmnt,@DesigID,@EffectDate,@Flag_CityCat)   
      
     end   
 Else If  Upper(@tran_type) ='U'   
   BEGIN  
      
      
    --DELETE FROM T0050_EXPENSE_TYPE_MAX_LIMIT WHERE  Expense_Type_ID = @Expense_Type_ID AND CMP_ID = @CMP_ID      
      
    SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM T0050_EXPENSE_TYPE_MAX_LIMIT WITH (NOLOCK)  
      
      
    --UPDATE    T0050_EXPENSE_TYPE_MAX_LIMIT  
    --SET       Amount = @Amount,  
    --City_Cat_Amount=@CityCatAmnt,  
    --Flag_Grd_Desig=@Flag_GrdDesig,  
    --City_Cat_Flag=@Flag_CityCat  
    ----Amount=@Amount  
    --WHERE     Tran_ID = @Tran_ID And Expense_Type_ID = @Expense_Type_ID And Cmp_ID = @Cmp_ID and City_Cat_ID=@CityCatID  
    --and Effective_Date=@EffectDate  
      
    INSERT INTO T0050_EXPENSE_TYPE_MAX_LIMIT  
               (TRAN_ID,CMP_ID,Expense_Type_ID,Grd_Id,Amount,Flag_Grd_Desig,City_Cat_ID,City_Cat_Amount,Desig_ID,Effective_Date,City_Cat_Flag)  
    VALUES     (@Tran_ID,@Cmp_ID,@Expense_Type_ID,@Grd_Id,@Amount,@Flag_GrdDesig,@CityCatID,@CityCatAmnt,@DesigID,@EffectDate,@Flag_CityCat)   
      
    --IF EXISTS (SELECT TRAN_ID FROM T0050_EXPENSE_TYPE_MAX_LIMIT WHERE Grd_ID = @Grd_Id AND EXPENSE_TYPE_ID <> @EXPENSE_TYPE_ID )   
    -- BEGIN  
    --  SET @Tran_ID = 0  
    --  RETURN  
    -- END  
      
    --UPDATE    T0050_EXPENSE_TYPE_MAX_LIMIT  
    --SET       Amount = @Amount  
    --WHERE     Tran_ID = @Tran_ID And Expense_Type_ID = @Expense_Type_ID And Cmp_ID = @Cmp_ID  
   END  
 Else If  Upper(@tran_type) ='D'  
   BEGIN   
    DELETE FROM T0050_EXPENSE_TYPE_MAX_LIMIT WHERE  TRAN_ID = @Tran_ID AND CMP_ID = @CMP_ID  
   END  
     
 RETURN  
END  
  
   