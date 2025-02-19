

CREATE PROCEDURE [dbo].[Get_Max_Rpt_level]

 @Cmp_Id		numeric
 ,@Emp_Id		numeric


	
AS
BEGIN
		
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @rpt_level numeric
--set @Review_Emp_Id=0

 begin 

 select @rpt_level=  max(rpt_level) from T0095_EMP_SCHEME s 
					inner join T0050_Scheme_Detail d on d.Scheme_Id=s.Scheme_ID
					where emp_id=@Emp_Id and type='File Management' and s.Cmp_Id=@Cmp_Id 
					and Effective_Date=(select max(Effective_Date) from T0095_EMP_SCHEME where Emp_ID=@Emp_Id and type='file Management' and Cmp_Id=@Cmp_Id) 
 
					--max(rpt_level) from T0095_EMP_SCHEME s 
					--inner join T0050_Scheme_Detail d on d.Scheme_Id=s.Scheme_ID
					--where emp_id=@Emp_Id and type='File Management' and s.Cmp_Id=@Cmp_Id
					

 end

    Select isnull(@rpt_level,0)as Rpt_level  
END


