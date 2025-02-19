


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0052_ResumeFinal_Approval]
	 @CanApp_Id			numeric(18,0) output
	,@Cmp_Id			numeric(18,0)
	,@ResumeFinal_ID	numeric(18,0)
	,@Approver_EmpId	numeric(18,0)
	,@Is_Final			int	
	,@CanApp_Status		int
	,@Resume_ID			numeric(18,0)	--added 1 apr 2015
    ,@Resume_Status		int				--added 1 apr 2015
    ,@Rec_post_Id		numeric(18,0)	--added 1 apr 2015
    ,@Comments			varchar(500)	--added 1 apr 2015
	,@Branch_id			numeric(18,0)	--added 1 apr 2015
	,@Grd_id			numeric(18,0)	--added 1 apr 2015
	,@Desig_id			numeric(18,0)	--added 1 apr 2015
	,@Dept_id			numeric(18,0)	--added 1 apr 2015
	,@Joining_date		datetime		--added 1 apr 2015
	,@Basic_Salay		numeric(18,2)	--added 1 apr 2015
	,@Login_id			numeric(18,0)	--added 1 apr 2015
	,@Total_CTC			numeric(18,2)	--added 1 apr 2015
	,@ReportingManager_Id	numeric(18,0)	--added 1 apr 2015
	,@Remarks			varchar(100)	--added 1 apr 2015
	,@ShiftId			numeric(18,0)	--added 1 apr 2015
	,@EmploymentTypeId	numeric(18,0)	--added 1 apr 2015
	,@Rpt_Level			int				--added 1 apr 2015
	,@Vertical_id		numeric(18,0)= null  --added 10 july 2017
	,@SubVertical_id	numeric(18,0)= null  --added 10 july 2017
	,@tran_type			varchar(1) 
	,@User_Id			numeric(18,0) = 0
	,@IP_Address		varchar(30)= '' 	
	,@R_Cmp_Id			numeric(18,0)= null   --Mukti 13042015  --Set null Change By Jaina 24-11-2016 
	,@Gross_Salary		numeric(18,2) = 0 -- sneha 14/09/2017
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	if	@Vertical_id = 0
		set @Vertical_id = NULL
	
	IF	@SubVertical_id = 0
		SET @SubVertical_id = NULL

	if Upper(@tran_type) = 'I'
	begin
		select @CanApp_Id = isnull(max(CanApp_Id),0) + 1 from T0052_ResumeFinal_Approval WITH (NOLOCK)
		insert into T0052_ResumeFinal_Approval
			(
				 CanApp_Id
				,Cmp_Id
				,ResumeFinal_ID
				,Approver_EmpId
				,Is_Final
				,Approved_Date
				,CanApp_Status
				,Resume_ID  --added 1 apr 2015-----------start
				,Resume_Status
				,Rec_post_Id
				,Comments
				,Branch_id
				,Grd_id
				,Desig_id
				,Dept_id
				,Joining_date
				,Basic_Salay
				,Login_id
				,Total_CTC
				,ReportingManager_Id
				,Remarks
				,ShiftId
				,EmploymentTypeId
				,Rpt_Level--added 1 apr 2015-----------end
				,R_Cmp_Id   --Mukti 13042015
				,Vertical_id	 --added 10 july 2017
				,SubVertical_id	 --added 10 july 2017
				,Gross_Salary	 --added 18 Sep 2017
			)
			values
			(
				 @CanApp_Id
				,@Cmp_Id
				,@ResumeFinal_ID
				,@Approver_EmpId
				,@Is_Final
				,GETDATE()
				,@CanApp_Status
				,@Resume_ID	--added 1 apr 2015-----------start
				,@Resume_Status
				,@Rec_post_Id
				,@Comments
				,@Branch_id
				,@Grd_id
				,@Desig_id
				,@Dept_id
				,@Joining_date
				,@Basic_Salay
				,@Login_id
				,@Total_CTC
				,@ReportingManager_Id
				,@Remarks
				,@ShiftId
				,@EmploymentTypeId
				,@Rpt_Level --added 1 apr 2015-----------end
				,@R_Cmp_Id  --Mukti 13042015
				,@Vertical_id		 --added 10 july 2017
				,@SubVertical_id	 --added 10 july 2017
				,@Gross_Salary		 --added 18 Sep 2017
			)
	End
	else if  Upper(@tran_type) = 'U'
	begin
		update T0052_ResumeFinal_Approval
		set    Approver_EmpId	=	@Approver_EmpId
			  ,Is_Final			=	@Is_Final
			  ,Approved_Date	=	GETDATE()
			  ,CanApp_Status	=	@CanApp_Status	
			  ,Resume_ID		=	@Resume_ID		--added 1 apr 2015-----------start
			  ,Resume_Status	=	@Resume_Status
			  ,Rec_post_Id		=	@Resume_Status
			  ,Comments			=   @Comments
			  ,Branch_id		=   @Branch_id
			  ,Grd_id			=	@Grd_id
			  ,Desig_id			=   @Desig_id
			 ,Dept_id			=   @Dept_id
			 ,Joining_date		=   @Joining_date
			 ,Basic_Salay		=	@Basic_Salay
			 ,Login_id			=   @Login_id
			 ,Total_CTC			=	@Total_CTC
			 ,ReportingManager_Id =	@ReportingManager_Id	
			 ,Remarks			=	@Remarks
			 ,ShiftId			=	@ShiftId
			 ,EmploymentTypeId	=	@EmploymentTypeId
			 ,Rpt_Level			=	@Rpt_Level		--added 1 apr 2015-----------end
			,Vertical_id		=   @Vertical_id	--added 10 july 2017
			 ,SubVertical_id	=	@SubVertical_id	--added 10 july 2017
			 ,R_Cmp_Id=@R_Cmp_Id   --Mukti 13042015
			 ,Gross_Salary		=   @Gross_Salary  --added 18 Sep 2017
		WHERE CanApp_Id = @CanApp_Id
	End
	else if Upper(@tran_type) = 'D'
	begin
		delete from T0052_ResumeFinal_Approval where CanApp_Id=@CanApp_Id
	End
	
	--if @Is_Final= 1
	--begin	
	--	update T0060_RESUME_FINAL set Resume_Status=1 where Tran_ID=@ResumeFinal_ID
	--End
	
	if @Is_Final=1
		begin	
			update T0060_RESUME_FINAL
			set Resume_Status = 1 
			where  Tran_ID=@ResumeFinal_ID
		End
		
		
		If @CanApp_Status = 2
			Begin
				update T0060_RESUME_FINAL
				set Resume_Status = 2 
				where Tran_ID=@ResumeFinal_ID
			End
END

