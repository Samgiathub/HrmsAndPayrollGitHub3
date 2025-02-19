
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_FileNumber]

 @Cmp_Id		numeric
,@Emp_Id		numeric
	--Hardik 31/10/2018 for Competent Client
AS
BEGIN
	
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


   -- select * from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and emp_id=@Emp_Id

--declare @fileNumber varchar(max)
--set @fileNumber=

declare @fileNumber varchar(max)
set @fileNumber=''

if(@Emp_Id<>0)
begin

select @fileNumber= LEFT(Alpha_Emp_Code, 3)+format(GETDATE(),'ddMMyyhhmmss') from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id and emp_id=@Emp_Id
print @fileNumber

end
else
 begin 
 print 11
--select LEFT(Alpha_Emp_Code, 3)+format(GETDATE(),'ddMMyyhhmmss'),emp_id,Alpha_Emp_Code,Emp_Full_Name,format(GETDATE(),'ddMMyyhhmmss')as today,Date_Of_Join,GETDATE() from T0080_EMP_MASTER where Cmp_ID=119 and emp_id=13961
 select @fileNumber= LEFT(Cmp_ID, 3)+format(GETDATE(),'ddMMyyhhmmss') from T0080_EMP_MASTER where Cmp_ID=@Cmp_Id --and emp_id=@Emp_Id
 end

    Select isnull(@fileNumber,'')as File_Number  --It returns Alpha Employee Code So Donot comment this line
END








