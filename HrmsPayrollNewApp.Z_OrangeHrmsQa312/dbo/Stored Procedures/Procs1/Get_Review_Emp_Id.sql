

CREATE PROCEDURE [dbo].[Get_Review_Emp_Id]

 @Cmp_Id		numeric
--,@Emp_Id		numeric
,@Rpt_Level		int
,@File_App_Id	int
	
AS
BEGIN
		
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @Review_Emp_Id numeric
--set @Review_Emp_Id=0

 begin 

 select @Review_Emp_Id= Emp_ID from 
			(	select 0 as Rpt_Level,l.Emp_Id as E_Id,l.Emp_Id as Emp_ID,0 as File_Apr_Id,File_App_Id
				from T0080_File_Application l
				inner join T0011_LOGIN lg on lg.Login_ID=l.[User ID] 
				where --F_StatusId=4 and
				File_App_Id=@File_App_Id
			union
				select Rpt_Level,l.Emp_Id as E_Id,lg.Emp_ID,File_Apr_Id,File_App_Id 
				from T0115_File_Level_Approval l
				inner join T0011_LOGIN lg on lg.Login_ID=l.[User ID] 
				where --F_StatusId=4 and 
				File_App_Id=@File_App_Id
				)as t where File_App_Id=@File_App_Id and Rpt_Level=@Rpt_Level
 end

    Select isnull(@Review_Emp_Id,0)as Review_Emp_Id  
END


