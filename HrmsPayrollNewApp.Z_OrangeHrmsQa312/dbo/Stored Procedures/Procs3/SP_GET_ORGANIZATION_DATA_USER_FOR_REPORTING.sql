CREATE PROCEDURE [dbo].[SP_GET_ORGANIZATION_DATA_USER_FOR_REPORTING]    
  @cmp_id as numeric,  
  @branch_id as NUMERIC,  
  @emp_id as NUMERIC,  
  @int_level as NUMERIC,  
  @MaxLevel as NUMERIC  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
       
    delete from TBL_ORGANIZATION_DISPLAY --where emp_id=@emp_id  
	Declare @CrosCmpid int
	Declare @count int = 1
	Declare @rowcount int 
	select @rowcount = count (1) from T0010_COMPANY_MASTER where is_GroupOFCmp = (select top 1 is_GroupOFCmp  from T0010_COMPANY_MASTER where Cmp_Id = @cmp_id ) and Cmp_Id <> 1
	
	exec SP_GET_ORGANIZATION_TREE @cmp_id,@branch_id,@emp_id,@int_level,@MaxLevel  

      WHILE ( @count
        
        ) <= @rowcount 
BEGIN
	select @CrosCmpid = T.Cmp_Id from 
	(
	select ROW_NUMBER() OVER(order by Cmp_id) as rm, Cmp_Id from T0010_COMPANY_MASTER where is_GroupOFCmp = (select top 1 is_GroupOFCmp  from T0010_COMPANY_MASTER where Cmp_Id = 1 ) and Cmp_Id <> 1 
	) T where T.rm = @count
	set @count = @count + 1
	--select @CrosCmpid
   exec SP_GET_ORGANIZATION_TREE @CrosCmpid,@branch_id,@emp_id,@int_level,@MaxLevel  
END
      
    --Select EMP_ID from TBL_ORGANIZATION_DISPLAY  
      
    --select * from V0095_INCREMENT where increment_id in (147,11,10)-- in (Select EMP_ID from TBL_ORGANIZATION_DISPLAY) order by Increment_Effective_Date desc  
  
     Select  convert(nvarchar(2000),Qry.Emp_id) + ','   
      From   
     (
	 Select Row_ID,EMP_ID from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)) Qry  
     left outer join (select emp_id from V0095_Increment_All_Data where emp_left<>'Y' and Increment_ID in   
     (select Increment_ID from t0080_emp_master WITH (NOLOCK) where emp_id in (select emp_id from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK))))Q on Qry.emp_id = q.emp_id  order by qry.Row_ID  
     for xml path ('')  
  
     --Select  convert(nvarchar,Qry.Emp_id) Emp_ID  
     -- From   
     --(Select Row_ID,EMP_ID from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)) Qry  
     --left outer join (select emp_id,Cmp_ID from V0095_Increment_All_Data where emp_left<>'Y' and Increment_ID in   
     --(select Increment_ID from t0080_emp_master WITH (NOLOCK) where emp_id in (select emp_id from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK))))Q on Qry.emp_id = q.emp_id  order by qry.Row_ID  
      
--select  * from TBL_ORGANIZATION_DISPLAY  
return  
  
  
  
  