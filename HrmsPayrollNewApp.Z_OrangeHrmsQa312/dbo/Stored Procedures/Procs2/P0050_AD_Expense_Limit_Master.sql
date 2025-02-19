    
    
    
-- =============================================    
-- Author:  Ripal Patel    
-- Create date: 04Nov2014    
-- Description: <Description,,>    
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---    
    
-- =============================================    
CREATE PROCEDURE [dbo].[P0050_AD_Expense_Limit_Master]    
 @AD_Exp_Master_ID as numeric(18, 0) output ,    
 @Cmp_ID as numeric(18, 0),    
 @AD_ID as numeric(18, 0),    
 @AD_Exp_Name as varchar(255),    
 @Max_Limit_Type as varchar(50),    
 @Fixed_Max_Limit as numeric(18,2),    
 @StDate_Year as datetime,    
 @NoOfYear as int,    
 @Tran_type as CHAR(1),    
 @User_Id as numeric(18,0) = 0    
AS    
BEGIN    
    
SET NOCOUNT ON     
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
SET ARITHABORT ON    
    
     
 if @Fixed_Max_Limit = 0    
  set @Fixed_Max_Limit = null    
 if @StDate_Year ='01-01-1900'    
  set @StDate_Year = null    
 if @NoOfYear = 0    
  set @NoOfYear = null    
     set @AD_Exp_Name = dbo.fnc_ReverseHTMLTags(@AD_Exp_Name) --added by Ronak 081021      
 IF @Tran_type = 'I'    
 BEGIN    
      
  if exists(select 1 from T0050_AD_Expense_Limit_Master WITH (NOLOCK) where upper(AD_Exp_Name) = upper(@AD_Exp_Name) and Cmp_ID = @Cmp_ID)    
  Begin    
   raiserror('Data already exists',16,2)    
   return    
  End    
      
      
  select @AD_Exp_Master_ID = isnull(max(AD_Exp_Master_ID),0)+1 from T0050_AD_Expense_Limit_Master WITH (NOLOCK)    
  INSERT INTO T0050_AD_Expense_Limit_Master    
      (AD_Exp_Master_ID,Cmp_ID,AD_ID,AD_Exp_Name,Max_Limit_Type,Fixed_Max_Limit,StDate_Year,    
       NoOfYear,Created_Date,Created_By)    
   VALUES    
      (@AD_Exp_Master_ID,@Cmp_ID,@AD_ID,@AD_Exp_Name,@Max_Limit_Type,@Fixed_Max_Limit,@StDate_Year,    
       @NoOfYear,getdate(),@User_Id)    
           
 End    
 Else IF @Tran_type = 'U'    
 BEGIN    
      
  if exists(select 1 from T0050_AD_Expense_Limit_Master WITH (NOLOCK) where upper(AD_Exp_Name) = upper(@AD_Exp_Name) and Cmp_ID = @Cmp_ID     
     and AD_Exp_Master_ID <> @AD_Exp_Master_ID)    
  Begin    
   raiserror('Data already exists',16,2)    
   return    
  End    
      
      
  UPDATE T0050_AD_Expense_Limit_Master    
      SET AD_ID = @AD_ID,    
       AD_Exp_Name = @AD_Exp_Name,    
       Max_Limit_Type = @Max_Limit_Type,    
       Fixed_Max_Limit = @Fixed_Max_Limit,    
       StDate_Year = @StDate_Year,    
       NoOfYear = @NoOfYear,    
       Modify_Date = getdate(),    
       Modify_By = @User_Id    
    WHERE AD_Exp_Master_ID = @AD_Exp_Master_ID    
       
 End    
 Else IF @Tran_type = 'D'    
 BEGIN    
     
  if Exists(select 1 from T0110_RC_LTA_Travel_Detail WITH (NOLOCK) where AD_Exp_Master_ID = @AD_Exp_Master_ID) OR    
     Exists(select 1 from T0110_RC_Dependant_Detail WITH (NOLOCK) where  AD_Exp_Master_ID = @AD_Exp_Master_ID) OR    
     Exists(select 1 from T0110_RC_Reimbursement_Detail WITH (NOLOCK) where   AD_Exp_Master_ID = @AD_Exp_Master_ID)    
   Begin    
   raiserror('Reference already exists',16,2)    
   return    
   End    
     
  delete from T0050_AD_Expense_Limit where AD_Exp_Master_ID = @AD_Exp_Master_ID    
      
  delete from T0050_AD_Expense_Limit_Master where AD_Exp_Master_ID = @AD_Exp_Master_ID    
      
 End    
     
END    
    