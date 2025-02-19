



  ---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_TRAINING_DETAILS]   
  @Cmp_ID  numeric  
 ,@From_Date  datetime  
 ,@To_Date  datetime   
 ,@Branch_ID  numeric   = 0  
 ,@Cat_ID        numeric = 0  
 ,@Grd_ID  numeric = 0  
 ,@Type_ID       numeric = 0    
 ,@Dept_ID  numeric  = 0  
 ,@Desig_ID  numeric = 0  
 ,@Emp_ID  numeric  = 0  
 ,@Constraint varchar(5000) = ''  
 ,@training_id    numeric =8  
  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
  
 SELECT TA.Training_App_ID, TA.Training_Title ,TA.Training_Desc , TA.For_Date ,TA.Posted_Emp_ID , TA.Skill_ID,TR.Training_End_Date, TA.App_Status,      
               TR.Training_Apr_ID,TR.Login_ID,TR.Place,TR.Training_Date,TR.Faculty,TR.Company_Name, TR.Description,TR.Training_Cost,TR.Apr_Status,TA.Cmp_ID   
             --  TF.emp_score, TF.emp_comments, TF.emp_suggestion, TF.sup_score, TF.sup_comments, TF.sup_suggestion  
   FROM  T0100_Training_Application TA  WITH (NOLOCK) inner JOIN  
                     T0120_Training_Approval TR WITH (NOLOCK) ON TA.Training_App_ID =TR.Training_App_ID  
          --Where TR.Apr_Status ='A'  and TA.For_Date >= @From_Date and TA.For_Date <= @To_Date  
           where TR.Apr_Status ='A' and tr.Training_Date >= cast(@From_Date as varchar(12)) and tr.Training_End_Date <= @To_Date and ta.cmp_id = @cmp_id and tr.training_apr_id = isnull(@training_id,0)-- order by emp_first_name asc  
                        
 RETURN  
  
  
  

