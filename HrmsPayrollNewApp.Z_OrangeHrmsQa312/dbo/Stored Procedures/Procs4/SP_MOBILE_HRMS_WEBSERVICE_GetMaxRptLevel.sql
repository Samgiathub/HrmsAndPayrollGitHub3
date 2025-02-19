CREATE PROCEDURE [dbo].[SP_MOBILE_HRMS_WEBSERVICE_GetMaxRptLevel]                  
   @Cmp_ID INT = 0                  
 ,@Emp_ID INT = 0  
 ,@Schme_type varchar(50)=''
    
AS                                      
BEGIN          
Declare @Emp_cmp_id as int ,
@scheme_id  int
,@MaxLevel int
		
     set @Emp_cmp_id=(select top 1 cmp_id from t0080_emp_Master where emp_id=@Emp_ID and Emp_Left='N' )  
     
	 
	 set @scheme_id=(select Max(Scheme_ID) from T0095_EMP_SCHEME where type=@Schme_type and Emp_id=@emp_id and Effective_Date=(select Max(Effective_date) from T0095_EMP_SCHEME  where Emp_ID=@emp_id and cmp_id=@Emp_cmp_id and Type=@Schme_type))             
	 
	 set @MaxLevel=(select isnull(max(rpt_level),0) from T0050_Scheme_Detail where Scheme_Id=@scheme_id) 
  

  
  
     
END                          
                  
                  
