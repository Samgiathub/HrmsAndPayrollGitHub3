

-- =============================================
-- Author:		MUKTI CHAUHAN
-- Create date: 01122018
-- Description:	Quick Interview Details
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0060_QuickInterviewDetails] 
 @Resume_Id					numeric(18) output
,@cmp_id					numeric(18,0)
,@Rec_Post_Id			    INT
,@Emp_First_Name			varchar(150)
,@Emp_Middle_Name			varchar(150)
,@Emp_Last_Name				varchar(150)
,@Date_Of_Birth				datetime  =null
,@Primary_email				varchar(100)
,@Resume_Name				varchar(50)
,@Resume_Status				tinyint
,@S_Emp_Id					INT
,@From_Date                 datetime
,@To_Date                   datetime
,@status					INT
,@BypassInterview			int
,@tran_type				    char(1)
,@File_Name varchar(max)  output
,@Gender varchar(5)
,@Contact_No varchar(15)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
declare @Interview_Schedule_Id			numeric(18,0)
declare @filename1 varchar(max)

if Upper(@tran_type) ='I' 
	begin
		if exists (Select Resume_Id  from T0055_Resume_Master WITH (NOLOCK)  Where cmp_id=@CMP_ID AND Emp_First_Name=@Emp_First_Name  AND Emp_Last_Name=@Emp_Last_Name AND Date_Of_Birth = @Date_Of_Birth)
		begin
				set @Resume_Id=0
				raiserror('@@Already Exists@@',16,2)
				return -1 
		end
		select @Resume_Id = isnull(max(Resume_Id),0) + 1 from T0055_Resume_Master WITH (NOLOCK)
		insert into T0055_Resume_Master(
											Resume_Id
											,cmp_id
											,Rec_Post_Id
											,Resume_Code
											,Emp_First_Name
											,Emp_Second_Name
											,Emp_Last_Name
											,Date_Of_Birth											
											,Primary_email
											,Resume_Name
											,Resume_Status	
											,Resume_Posted_date		
										--	,[File_Name]	
											,Gender	
											,Initial		
											,Mobile_No		
											,System_Date		
										)
								Values (
											@Resume_Id
											,@cmp_id
											,@Rec_Post_Id
											,'R' + cast(@cmp_id as varchar(50)) +':1'+ cast(@Resume_Id as varchar(50))
											,@Emp_First_Name
											,@Emp_Middle_Name
											,@Emp_Last_Name
											,@Date_Of_Birth
											,@Primary_email
											,@Resume_Name
											,@Resume_Status
											,CONVERT(VARCHAR(10),GETDATE(),120)
										--	,@File_Name
											,@Gender
											,'Mr.'
											,@Contact_No
											,CONVERT(VARCHAR(10),GETDATE(),120)
										)
					
			set	@filename1=	cast(@cmp_id as varchar(10)) + '_' +  cast(@Resume_Id as varchar(10)) + '_' + @File_Name	
			--print @Resume_Id
			update T0055_Resume_Master set [File_Name]=@filename1 where Resume_Id=@Resume_Id
			
		--if exists (Select Interview_Schedule_Id  from T0055_HRMS_Interview_Schedule Where cmp_id= @cmp_id  and Resume_Id = @Resume_Id)
		--begin
		if (@BypassInterview=1)
		BEGIN
		--print 'ss'
			select @Interview_Schedule_Id = isnull(max(Interview_Schedule_Id),0) +1 from T0055_HRMS_Interview_Schedule WITH (NOLOCK)
			insert into T0055_HRMS_Interview_Schedule 
			(
				 Interview_Schedule_Id
				,Rec_Post_Id
				,Cmp_Id
				,S_Emp_Id
				,From_Date
				,To_Date
				,Resume_Id
				,Status
				,BypassInterview
			)	
			values
			(
				 @Interview_Schedule_Id
				,@Rec_Post_Id
				,@cmp_id
				,@S_Emp_Id
				,@From_Date
				,@To_Date
				,@Resume_Id
				,@status
				,@BypassInterview
			)	
		End
		--exec P0055_HRMS_Interview_Schedule 0,0,@Rec_Post_Id,@cmp_id,@S_Emp_Id,0,0,0,@From_Date,@To_Date,null,null,@Resume_Id,null,null,null,null,null,null,null,@status,'I',null
		
	End
END
select @Resume_Id as Resume_Id
--select @filename1 as File_Name1
return 
