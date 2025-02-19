

create PROCEDURE [dbo].[Get_Final_File_Approve_Id]

 @Cmp_Id		numeric
 ,@Emp_Id		numeric
,@File_App_Id  numeric

	
AS
BEGIN
		
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @Final_File_Apr_Id numeric
--set @Review_Emp_Id=0

 begin 

 select @Final_File_Apr_Id=  File_Apr_Id from T0080_File_Approval where File_App_Id =@File_App_Id and Emp_ID=@Emp_Id and Cmp_Id=@Cmp_Id
 
					
 end

    Select isnull(@Final_File_Apr_Id,0)as Final_File_Apr_Id  
END


