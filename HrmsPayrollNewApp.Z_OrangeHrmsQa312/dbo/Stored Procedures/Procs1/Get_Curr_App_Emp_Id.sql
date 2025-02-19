


CREATE PROCEDURE [dbo].[Get_Curr_App_Emp_Id]

 @Cmp_Id		numeric
 ,@Emp_Id		numeric
 ,@Scheme_id numeric

	
AS
BEGIN
		
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @app_em_id numeric
--set @Review_Emp_Id=0

 begin 

 select  @app_em_id=(select App_Emp_ID from  T0050_Scheme_Detail d where Scheme_Id=@Scheme_id and
                      Cmp_Id=@Cmp_Id and App_Emp_ID=@Emp_Id and
          Rpt_Level=( select  max(Rpt_Level)  from T0050_Scheme_Detail where  Scheme_Id=@Scheme_id 
		  and Cmp_Id=@Cmp_Id ))
 ----(	select App_Emp_ID from  T0050_Scheme_Detail d -- on d.Scheme_Id=s.Scheme_ID
	----				where Scheme_Id=@Scheme_id and Cmp_Id=@Cmp_Id and App_Emp_ID=@Emp_Id)
					print @app_em_id--and type='File Management' and s.Cmp_Id=119
					

 end

    Select isnull(@app_em_id,0)as app_emp_id  
END


