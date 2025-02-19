
CREATE PROCEDURE [dbo].[SP_MOBILE_HRMS_WEBSERVICE_GetEmployeeName_Using Emp_id]              
   @Cmp_ID INT = 187              
 ,@Emp_ID INT = 28201              
 
AS                                  
BEGIN      
   select  Concat(Alpha_Emp_Code ,'-', Emp_Full_Name) as 'Employee Name' from T0080_EMP_MASTER where emp_id=@emp_id and cmp_id=@cmp_id   
                
END 

              
              

  
  