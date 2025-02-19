CREATE PROCEDURE [dbo].[P0052_Hrms_RecruitmentRequest_Approval]
	 @RecApp_Id			numeric(18,0) output
	,@Cmp_Id			numeric(18,0)
	,@Rec_Req_ID		numeric(18,0)
	,@Approver_EmpId	numeric(18,0)=0
	,@Is_Final			int	=0
	,@RecApp_Status		int
	,@Rpt_Level         int 
	,@Job_Title			varchar(50) --added on 28 mar 2015
	,@Grade_Id			numeric(18,0) --added on 28 Mar 2015
	,@Desig_Id			numeric(18,0) --added on 28 Mar 2015
	,@Branch_Id			numeric(18,0) --added on 28 Mar 2015
	,@Type_Id			numeric(18,0) --added on 28 Mar 2015
	,@Dept_Id			numeric(18,0) --added on 28 Mar 2015
	,@Skill_detail		nvarchar(1000) --added on 28 Mar 2015
	,@Job_Description	nvarchar(1000) --added on 28 Mar 2015
	,@No_of_vacancies	numeric(3,0)   --added on 28 Mar 2015
	,@Qualification_detail	varchar(500) --added on 28 Mar 2015
	,@Experience_Detail	varchar(500)   --added on 28 Mar 2015
	,@BusinessSegment_Id numeric(18,0) --added on 28 Mar 2015
	,@Vertical_Id		numeric(18,0)  --added on 28 Mar 2015
	,@SubVertical_Id	numeric(18,0)  --added on 28 Mar 2015
	,@Type_Of_Opening	numeric(18,0) --added on 1 Feb 2016
	,@JD_CodeId			numeric(18,0) --added on 1 Feb 2016
	,@Budgeted			bit		--added on 1 Feb 2016
	,@Exp_Min			FLOAT		--added on 1 Feb 2016
	,@Exp_Max			FLOAT		--added on 1 Feb 2016
	,@Rep_EmployeeId	Varchar(max)--numeric(18,0) --added on 1 Feb 2016
	,@tran_type			varchar(1) 
	,@User_Id			numeric(18,0) = 0
	,@IP_Address		varchar(30)= '' 	
	,@Justification			varchar(1000) --Mukti(03122018)
	,@CTCBudget				numeric(18,2)--Mukti(03122018)
	,@Is_Left_ReplaceEmpId	bit        
	,@Comments varchar(1000)
	,@Attach_Doc varchar(2000)
	,@Document_ID varchar(200)
	,@Experience_Type int
	,@MIN_CTC_Budget float 
	,@Category_ID int
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

--added on 30 mar 2015
if @Grade_Id = 0
	set @Grade_Id = null
if @Branch_Id = 0
	set @Branch_Id = null
if @Type_Id = 0
	set @Type_Id = null
if @Dept_Id = 0
	set @Dept_Id = null
if @Desig_Id = 0
	set @Desig_Id = null
if @BusinessSegment_Id = 0
	set @BusinessSegment_Id = null
if @SubVertical_Id = 0
	set @SubVertical_Id = null
if @Vertical_Id = 0
	set @Vertical_Id = null
if @JD_CodeId = 0  --added on 1 Feb 2016
	set @JD_CodeId = null	
--if @Rep_EmployeeId = 0	--added on 1 Feb 2016
--	set @Rep_EmployeeId = null	
--added on 30 mar 2015 - end

 --Added by Mukti start on 01042019 -- For Kataria Client 
	 IF (Upper(@tran_type) ='I' or Upper(@tran_type) ='U')
		BEGIN
			Declare @Employee_Strength_Setting tinyint
			select @Employee_Strength_Setting = setting_value from T0040_SETTING WITH (NOLOCK) where cmp_id = @Cmp_ID and setting_name = 'Restrict Entry based on Employee Strength Master'
			
			IF @Employee_Strength_Setting = 1
				Begin
					IF @Branch_ID > 0 AND @Desig_Id > 0
					Begin
						Declare @Branch_Desig_Wise_Count Numeric(18,0)
						Set @Branch_Desig_Wise_Count = 0

						Declare @Branch_Desig_Strength_Count Numeric(18,0)
						Set @Branch_Desig_Strength_Count = 0

						Select 
							@Branch_Desig_Wise_Count = Count(1)
						FROM							
							(SELECT	
								I1.EMP_ID, I1.DESIG_ID, I1.BRANCH_ID,I1.Dept_ID
							FROM	T0095_INCREMENT I1 WITH (NOLOCK)
							INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON E.EMP_ID = I1.EMP_ID AND (E.Emp_Left_Date IS NULL OR ISNULL(Emp_Left,'N') = 'N')
							INNER JOIN (
										SELECT	
											MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
										FROM	T0095_INCREMENT I2 WITH (NOLOCK)
										INNER JOIN (
														SELECT	
															MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
														FROM	T0095_INCREMENT I3 WITH (NOLOCK)
														WHERE	I3.Increment_Effective_Date <= Getdate() AND Cmp_ID = @Cmp_ID
														GROUP BY I3.Emp_ID
													) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
										WHERE	I2.Cmp_ID = @Cmp_Id 
										GROUP BY I2.Emp_ID
									) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
							WHERE	I1.Cmp_ID=@Cmp_Id	
							AND NOT EXISTS(SELECT 1 FROM T0200_EMP_EXITAPPLICATION EE WITH (NOLOCK) WHERE EE.EMP_ID = I1.EMP_ID AND EE.status NOT IN('R','LR'))									
							) I
						WHERE I.Branch_ID = @Branch_ID AND I.Desig_Id = @Desig_Id  AND I.Dept_ID=@Dept_Id

						Select @Branch_Desig_Strength_Count = ESM.Strength
							From T0040_Employee_Strength_Master ESM WITH (NOLOCK)
							INNER JOIN(
										Select Max(Effective_Date) as For_Date,Branch_ID,Desig_Id,DEPT_ID 
											From T0040_Employee_Strength_Master WITH (NOLOCK) 
										Where Branch_Id <> 0 and Desig_Id <> 0 AND Cmp_Id=@CMP_ID
										Group By Branch_ID,Desig_Id,DEPT_ID
							) as Qry 
						ON ESM.Effective_Date = Qry.For_Date AND ESM.Branch_Id = Qry.Branch_Id AND ESM.Desig_Id = Qry.Desig_Id and ESM.Dept_Id=QRY.DEPT_ID
						WHERE ESM.Cmp_Id=@CMP_ID AND ESM.Branch_Id=@BRANCH_ID AND ESM.Desig_Id=@Desig_Id and ESM.Dept_Id=@DEPT_ID
						
--PRINT @Branch_Desig_Strength_Count
--PRINT @Branch_Desig_Wise_Count+@No_of_vacancies
						if (@Branch_Desig_Wise_Count+@No_of_vacancies) > @Branch_Desig_Strength_Count
							Begin
								set @Rec_Req_ID = 0
								RAISERROR ('@@No of Vacancy is greater than employee strength master limit@@', 16, 2)
								return
							End
					End
				End 
			END
	--Added by Mukti end on 01042019 -- For Kataria Client

	if Upper(@tran_type) = 'I'
		begin
			IF Exists(Select 1 From T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK) Where  Rec_Req_ID=@Rec_Req_ID  And Rpt_Level = @Rpt_Level)
				Begin					
					Set @RecApp_Id= 0
					Select @RecApp_Id
					Return 
				End
		else
			begin
			select @RecApp_Id = isnull(max(RecApp_Id),0) + 1 from T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK)
			insert into T0052_Hrms_RecruitmentRequest_Approval
			(
				 RecApp_Id
				,Cmp_Id
				,Rec_Req_ID
				,Approver_EmpId
				,Is_Final
				,Approved_Date
				,RecApp_Status
				,Rpt_Level			--added on 28 mar 2015
				,Job_Title			--added on 28 mar 2015
				,Grade_Id			--added on 28 Mar 2015
				,Desig_Id			 --added on 28 Mar 2015
				,Branch_Id			--added on 28 Mar 2015
				,Type_Id			 --added on 28 Mar 2015
				,Dept_Id			--added on 28 Mar 2015
				,Skill_detail		 --added on 28 Mar 2015
				,Job_Description	--added on 28 Mar 2015
				,No_of_vacancies	  --added on 28 Mar 2015
				,Qualification_detail	 --added on 28 Mar 2015
				,Experience_Detail	   --added on 28 Mar 2015
				,BusinessSegment_Id  --added on 28 Mar 2015
				,Vertical_Id		  --added on 28 Mar 2015
				,SubVertical_Id	  --added on 28 Mar 2015
				,Type_Of_Opening	--added on 1 Feb 2016
				,JD_CodeId		--added on 1 Feb 2016
				,Budgeted		--added on 1 Feb 2016
				,Exp_Min		--added on 1 Feb 2016
				,Exp_Max		--added on 1 Feb 2016
				,Rep_EmployeeId----27 Jan 2015end
				,Justification
				,CTC_Budget
				,Is_Left_ReplaceEmpId
				,Comments
				,Attach_Doc
				,Document_ID
				,Experience_Type
				,MIN_CTC_Budget
				,Category_ID
			)
			values
			(
				 @RecApp_Id
				,@Cmp_Id
				,@Rec_Req_ID
				,@Approver_EmpId
				,@Is_Final
				,GETDATE()
				,@RecApp_Status
				,@Rpt_Level			--added on 28 mar 2015
				,@Job_Title			--added on 28 mar 2015
				,@Grade_Id			--added on 28 Mar 2015
				,@Desig_Id			--added on 28 Mar 2015
				,@Branch_Id			--added on 28 Mar 2015
				,@Type_Id			--added on 28 Mar 2015
				,@Dept_Id			--added on 28 Mar 2015
				,@Skill_detail		--added on 28 Mar 2015
				,@Job_Description	--added on 28 Mar 2015
				,@No_of_vacancies	--added on 28 Mar 2015
				,@Qualification_detail --added on 28 Mar 2015
				,@Experience_Detail	   --added on 28 Mar 2015
				,@BusinessSegment_Id  --added on 28 Mar 2015
				,@Vertical_Id		  --added on 28 Mar 2015
				,@SubVertical_Id	  --added on 28 Mar 2015
				,@Type_Of_Opening	--added on 1 Feb 2016
				,@JD_CodeId		--added on 1 Feb 2016
				,@Budgeted		--added on 1 Feb 2016
				,@Exp_Min		--added on 1 Feb 2016
				,@Exp_Max		--added on 1 Feb 2016
				,@Rep_EmployeeId----27 Jan 2015 end
			    ,@Justification
			    ,@CTCBudget
			    ,@Is_Left_ReplaceEmpId
			    ,@Comments
			    ,@Attach_Doc
			    ,@Document_ID
			    ,@Experience_Type
			    ,@MIN_CTC_Budget
				,@Category_ID
			)
				Select @RecApp_Id
				--Return 	
		end
		end
	else if  Upper(@tran_type) = 'U'
		begin
			update T0052_Hrms_RecruitmentRequest_Approval
			set    Approver_EmpId	=	@Approver_EmpId
				  ,Is_Final			=	@Is_Final
				  ,Approved_Date	=	GETDATE()
				  ,RecApp_Status	=	@RecApp_Status	
				  ,Job_Title		=	@Job_Title		--added on 28 mar 2015
				  ,Grade_Id			=   @Grade_Id		--added on 28 Mar 2015
				  ,Desig_Id			=   @Desig_Id		--added on 28 Mar 2015
				  ,Branch_Id			=   @Branch_Id			--added on 28 Mar 2015
				  ,Type_Id			=   @Type_Id		--added on 28 Mar 2015
				  ,Dept_Id			=	@Dept_Id		--added on 28 Mar 2015
				  ,Skill_detail		=	@Skill_detail	--added on 28 Mar 2015
				  ,Job_Description	=   @Job_Description		--added on 28 Mar 2015
				  ,No_of_vacancies	=   @No_of_vacancies		--added on 28 Mar 2015
				  ,Qualification_detail = @Qualification_detail	--added on 28 Mar 2015
				  ,Experience_Detail	=	@Experience_Detail		--added on 28 Mar 2015
				  ,BusinessSegment_Id =   @BusinessSegment_Id		--added on 28 Mar 2015
				  ,Vertical_Id		=   @Vertical_Id			--added on 28 Mar 2015
				  ,SubVertical_Id	    =   @SubVertical_Id		--added on 28 Mar 2015
				  ,Type_Of_Opening	=	@Type_Of_Opening	--added on 1 Feb 2016
				  ,JD_CodeId	=	@JD_CodeId		--added on 1 Feb 2016
				  ,Budgeted		=	@Budgeted		--added on 1 Feb 2016
				  ,Exp_Min		=	@Exp_Min		--added on 1 Feb 2016
				  ,Exp_Max		=	@Exp_Max		--added on 1 Feb 2016
				  ,Rep_EmployeeId =  @Rep_EmployeeId----27 Jan 2015 end
				  ,Justification =@Justification
				  ,CTC_Budget=@CTCBudget
				  ,Is_Left_ReplaceEmpId=@Is_Left_ReplaceEmpId
				  ,Comments=@Comments
				  ,Attach_Doc=@Attach_Doc
				  ,Document_ID=@Document_ID
			      ,Experience_Type=@Experience_Type
			      ,MIN_CTC_Budget=@MIN_CTC_Budget
				  ,Category_ID=@Category_ID
			Where RecApp_Id = @RecApp_Id
		End
	else if Upper(@tran_type) = 'D'
		begin
			delete from T0052_Hrms_RecruitmentRequest_Approval where RecApp_Id=@RecApp_Id
		End
		
	
	if @Is_Final=1
		begin	
			update T0050_HRMS_Recruitment_Request
			set App_status = 1 
			where Rec_Req_ID = @Rec_Req_ID
		End
		
		
		If @RecApp_Status = 2
			Begin
				update T0050_HRMS_Recruitment_Request
				set App_status = 2 
				where Rec_Req_ID = @Rec_Req_ID
			End
		
	
END

