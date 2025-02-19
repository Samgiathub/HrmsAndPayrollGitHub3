
CREATE PROCEDURE [dbo].[P0060_Appraisal_EmployeeKPA_WORKING_MEHUL_07042022] 
	 @Emp_KPA_Id Numeric(18,0) output
	,@Emp_Id	Numeric(18,0)
	,@Cmp_Id     Numeric(18,0)
	,@KPA_Content nvarchar(1500)  --changed By Deepali -04-Apr-22- for unicode 
	,@KPA_Target nvarchar(1000)  --changed By Deepali -04-Apr-22- for unicode 
	,@KPA_Weightage Numeric(18,2)
	,@tran_type char(1)
	,@desig_id varchar(max)=''
	,@uploadtype as int = 1
	,@Dept_Id varchar(max)=''--added on 11 Feb 2016
	,@Effective_Date datetime = null --added on 16 Sep 2016
	,@status		int =  1 --added on 04/08/2017
	,@User_Id			numeric(18,0) = 0
    ,@IP_Address			varchar(30)= '' 
    ,@KPA_Type_ID numeric(18,0) = null --Mukti(25012018)
	,@Performance_Measure  nvarchar(500)=''  --changed By Deepali -04-Apr-22- for unicode 
	,@Completion_Date datetime 
	,@Attach_Docs varchar(1000)
	,@Approval_Level varchar(10)='Final'
	,@KPA_InitiateId	int	=null
	,@Remarks	nvarchar(1500)=''
	,@Is_Active	bit=1
	,@SrNo integer
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET ARITHABORT ON;
if @KPA_Type_ID =0 
	set @KPA_Type_ID=NULL
if @KPA_InitiateId=0
	set @KPA_InitiateId=NULL
			
declare @col1 as varchar(max)
declare @empid as numeric(18,0)
declare @OldValue as nvarchar(max)
Declare @Emp_name as Varchar(250)
Declare @Cmp_name as Varchar(250)	
declare @OldKPA_Content as nVARCHAR(1000) --changed By Deepali -04-Apr-22- for unicode 
declare @OldKPA_Target as nVARCHAR(1000)
declare @OldKPA_Weightage as VARCHAR(10)
declare @OldEffective_Date as VARCHAR(40)
Declare @Olddesig_id as VARCHAR(max)
Declare @Olddept_id as VARCHAR(max)
DECLARE @wclSRNo AS INT
DECLARE @ALPHA_EMP_CODE AS VARCHAR(50)
DECLARE @Period VARCHAR(15)
   
   --set @KPA_Content = dbo.fnc_ReverseHTMLTags(@KPA_Content)  --added by mansi 091221  
   --   set @KPA_Target = dbo.fnc_ReverseHTMLTags(@KPA_Target)  --added by mansi 091221  
	  --      set @Remarks = dbo.fnc_ReverseHTMLTags(@Remarks)  --added by mansi 091221  

	  set @KPA_Content = dbo.fnc_ReverseHTMLTags_NewForUnicode(@KPA_Content)  --added by Deepali 05Apr22  
      set @KPA_Target = dbo.fnc_ReverseHTMLTags_NewForUnicode(@KPA_Target)  --added by Deepali 05Apr22
	  set @Remarks = dbo.fnc_ReverseHTMLTags_NewForUnicode(@Remarks)  --added by Deepali 05Apr22  

	If @tran_type  = 'I' 
		Begin
			if @uploadtype = 1  --employee wise
				begin		
				   if @KPA_Content <>''
					 Begin
					 -- IF NOT EXISTS(SELECT 1 FROM T0060_Appraisal_EmployeeKPA WHERE KPA_Content=@KPA_Content AND Remarks=@Remarks AND Cmp_Id=@Cmp_Id AND EMP_ID=@Emp_Id and Approval_Level=@Approval_Level)
						--BEGIN
							SELECT @Emp_KPA_Id = Isnull(max(Emp_KPA_Id),0) + 1 	FROM T0060_Appraisal_EmployeeKPA 
							INSERT INTO T0060_Appraisal_EmployeeKPA
							(Emp_KPA_Id,Cmp_Id,Emp_Id,KPA_Content,KPA_Target,KPA_Weightage,Effective_Date,status,KPA_Type_ID,KPA_Performace_Measure,Completion_Date,Attach_Docs,Approval_Level,KPA_InitiateId,Remarks,Is_Active,SrNo,SystemDate,UserId)  --sep 16 2016  
							VALUES(@Emp_KPA_Id,@Cmp_Id,@Emp_Id,@KPA_Content,@KPA_Target,@KPA_Weightage,@Effective_Date,@status,@KPA_Type_ID,@Performance_Measure,@Completion_Date,@Attach_Docs,@Approval_Level,@KPA_InitiateId,dbo.RemoveCharSpecialSymbolValue_New(@Remarks),@Is_Active,@SrNo,GetDate(),@User_Id) 
							---added on 18/08/2017 start
							
							--end
			IF @status=1
			BEGIN
				SELECT @ALPHA_EMP_CODE=ALPHA_EMP_CODE FROM T0080_EMP_MASTER WHERE EMP_ID=@Emp_Id
				 DECLARE @FinYear VARCHAR(20)
				 DECLARE @YearOfDate INT
				 
				 IF EXISTS(SELECT 1 FROM T0055_Hrms_Initiate_KPASetting WHERE Emp_Id = @Emp_Id AND KPA_StartDate=@Effective_Date)
					BEGIN
						UPDATE T0055_Hrms_Initiate_KPASetting
						SET  Initiate_Status = @status
						WHERE Emp_Id = @Emp_Id AND KPA_StartDate=@Effective_Date
					END

				 SET @YearOfDate = YEAR(@Effective_Date) 
				 IF (MONTH(@Effective_Date) >= 4)					
					SET @FinYear = CAST(@YearOfDate AS CHAR(4)) + '-' + CAST((@YearOfDate + 1) AS CHAR(4))
				 ELSE					
					  SET @FinYear = CAST((@YearOfDate-1) AS CHAR(4)) + '-' + CAST((@YearOfDate) AS CHAR(4))

				 --SET @FinYear = CAST(@YearOfDate AS CHAR(4)) + '-' + CAST((@YearOfDate + 1) AS CHAR(4))
    
				SELECT @Period=[Period] FROM T0055_Hrms_Initiate_KPASetting WHERE Emp_Id = @Emp_Id AND KPA_StartDate=@Effective_Date
				
				--if not exists(select 1 from Wcl_EmployeeGoalMaster where EMP_Code=@ALPHA_EMP_CODE AND SelfGoals=@KPA_Content and Weightage=@KPA_Weightage and Period=@Period) ---added on(23-04-2021)
				--	begin
				--		SELECT @wclSRNo = Isnull(max(SRNo),0) + 1 	FROM Wcl_EmployeeGoalMaster WHERE EMP_Code=@ALPHA_EMP_CODE AND Period=@Period and fin_year=@FinYear
				--		INSERT INTO Wcl_EmployeeGoalMaster(EMP_Code,SRNo,SelfGoals,Weightage,Fin_Year,Effective_Date,[Period],Goal_Description)
				--		VALUES(@ALPHA_EMP_CODE,@wclSRNo,@KPA_Content,@KPA_Weightage,@FinYear,@Effective_Date,@Period,@Remarks)
				--	end
			END
						---added on 18/08/2017 end
			--Added By Mukti(start)09112016					
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER where Emp_ID=@Emp_Id
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER where Cmp_Id=@Cmp_Id
				
				SET @OldValue = 'New Value' + '#' +  'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'Effective Date :' + CONVERT(nvarchar(35),isnull(@Effective_Date,''))
									    	+ '#' +  'Employee  :' + ISNULL(@Emp_name,'') 
										    + '#' +  'KPA Content :' + ISNULL(@KPA_Content,'') 
										    + '#' +  'KPA Target :' + ISNULL(@KPA_Target,'')										
										    + '#' +  'Weightage :' +  CAST(ISNULL(@KPA_Weightage,'')AS VARCHAR(18)) + '#'
			--Added By Mukti(end)09112016
					 End
				End		
			Else if @uploadtype = 2 --added on 30 Jun 2015
				begin					
				--Added By Mukti(start)09112016	
				set @OldValue =	'old Value' + '#' +  'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'Effective Date :' + CONVERT(nvarchar(35),isnull(@OldEffective_Date,''))
									    	+ '#' +  'Employee  :' + ISNULL(@Emp_name,'') 
										    + '#' +  'KPA Content :' + ISNULL(@OldKPA_Content,'') 
										    + '#' +  'KPA Target :' + ISNULL(@OldKPA_Target,'')										
										    + '#' +  'Weightage :' +  CAST(ISNULL(@OldKPA_Weightage,'')AS VARCHAR(18))
										    + '#' +  'Designation :' + ISNULL(@Olddesig_id,'')	
										    + '#' +  'Department :' + ISNULL(@Olddept_id,'')
				--Added By Mukti(end)09112016		
							
					select @Emp_KPA_Id = Isnull(max(KPA_Id),0) + 1 	From T0051_KPA_Master 
					Insert into T0051_KPA_Master
					(KPA_id,Cmp_Id,Desig_Id,KPA_Content,KPA_Target,KPA_Weightage,Dept_Id,Effective_Date,KPA_Type_ID,KPA_Performace_Measure,Completion_Date,Attach_Docs)
					Values(@Emp_KPA_Id,@Cmp_Id,@desig_id,@KPA_Content,@KPA_Target,@KPA_Weightage,@Dept_Id,@Effective_Date,@KPA_Type_ID,@Performance_Measure,@Completion_Date,@Attach_Docs) 
				end
		End		
	Else if @tran_type = 'U'
 		begin
			if @uploadtype = 1  --employee wise
				begin
				--Added By Mukti(start)09112016					
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER where Emp_ID=@Emp_Id
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER where Cmp_Id=@Cmp_Id
				
				select @OldKPA_Content=KPA_Content, @OldKPA_Target=KPA_Target,@OldKPA_Weightage=KPA_Weightage,@OldEffective_Date=Effective_Date
				from T0060_Appraisal_EmployeeKPA
				where Emp_KPA_Id = @Emp_KPA_Id and Emp_Id=@Emp_Id
				--Added By Mukti(end)09112016				
				
					UPDATE    T0060_Appraisal_EmployeeKPA
					SET         
						KPA_Content=@KPA_Content,
						KPA_Target=@KPA_Target,
						KPA_Weightage=@KPA_Weightage,
						Effective_Date = @Effective_Date, --sep 16 2016
						[status] = @status, --04/08/2017
						KPA_Type_ID=@KPA_Type_ID,
						KPA_Performace_Measure = @Performance_Measure,
						Completion_Date=@Completion_Date,
						Attach_Docs=@Attach_Docs,
						Remarks=@Remarks,
						Is_Active=@Is_Active
					WHERE Emp_KPA_Id = @Emp_KPA_Id and Emp_Id=@Emp_Id and Approval_Level=@Approval_Level
					
					---added on 18/08/2017 start
					IF EXISTS(SELECT 1 FROM T0055_Hrms_Initiate_KPASetting WHERE Emp_Id = @Emp_Id AND KPA_StartDate=@Effective_Date)
						BEGIN
							UPDATE T0055_Hrms_Initiate_KPASetting
							SET  Initiate_Status = @status
							WHERE Emp_Id = @Emp_Id AND KPA_StartDate=@Effective_Date 
						END
					---added on 18/08/2017 end
			--Added By Mukti(start)09112016	
				set @OldValue =	'old Value' + '#' +  'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'Effective Date :' + CONVERT(nvarchar(35),isnull(@OldEffective_Date,''))
									    	+ '#' +  'Employee  :' + ISNULL(@Emp_name,'') 
										    + '#' +  'KPA Content :' + ISNULL(@OldKPA_Content,'') 
										    + '#' +  'KPA Target :' + ISNULL(@OldKPA_Target,'')										
										    + '#' +  'Weightage :' +  CAST(ISNULL(@OldKPA_Weightage,'')AS VARCHAR(18))
							   +'New Value' + '#' +  'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'Effective Date :' + CONVERT(nvarchar(35),isnull(@Effective_Date,''))
									    	+ '#' +  'Employee  :' + ISNULL(@Emp_name,'') 
										    + '#' +  'KPA Content :' + ISNULL(@KPA_Content,'') 
										    + '#' +  'KPA Target :' + ISNULL(@KPA_Target,'')										
										    + '#' +  'Weightage :' +  CAST(ISNULL(@KPA_Weightage,'')AS VARCHAR(18)) + '#'
			--Added By Mukti(end)09112016
				End
			Else if @uploadtype = 2 
				begin
				--Added By Mukti(start)09112016					
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER where Emp_ID=@Emp_Id
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER where Cmp_Id=@Cmp_Id
				
				select @OldKPA_Content=KPA_Content, @OldKPA_Target=KPA_Target,@OldKPA_Weightage=KPA_Weightage,
					   @OldEffective_Date=Effective_Date,@Olddesig_id=Desig_Id,@Olddept_id=Dept_Id
				from T0051_KPA_Master
				where KPA_id = @Emp_KPA_Id 
				--Added By Mukti(end)09112016		
				
					UPDATE    T0051_KPA_Master
					Set  
					     KPA_Content = @KPA_Content
					    ,KPA_Target  = @KPA_Target
					    ,KPA_Weightage = @KPA_Weightage
					    ,Desig_Id = @desig_id--added on 26 Nov 2015 sneha
					    ,Dept_Id = @Dept_Id--added on 11 feb 2016 sneha
					    ,Effective_Date = @Effective_Date --added on 16 sep 2016 
					    ,KPA_Type_ID=@KPA_Type_ID
						,KPA_Performace_Measure = @Performance_Measure
						,Completion_Date = @Completion_Date
						,Attach_Docs = @Attach_Docs
					Where KPA_id = @Emp_KPA_Id 
					
			--Added By Mukti(start)09112016	
				set @OldValue =	'old Value' + '#' +  'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'Effective Date :' + CONVERT(nvarchar(35),isnull(@OldEffective_Date,''))
									    	+ '#' +  'Employee  :' + ISNULL(@Emp_name,'') 
										    + '#' +  'KPA Content :' + ISNULL(@OldKPA_Content,'') 
										    + '#' +  'KPA Target :' + ISNULL(@OldKPA_Target,'')										
										    + '#' +  'Weightage :' +  CAST(ISNULL(@OldKPA_Weightage,'')AS VARCHAR(18))
										    + '#' +  'Designation :' + ISNULL(@Olddesig_id,'')	
										    + '#' +  'Department :' + ISNULL(@Olddept_id,'')	
							   +'New Value' + '#' +  'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'Effective Date :' + CONVERT(nvarchar(35),isnull(@Effective_Date,''))
									    	+ '#' +  'Employee  :' + ISNULL(@Emp_name,'') 
										    + '#' +  'KPA Content :' + ISNULL(@KPA_Content,'') 
										    + '#' +  'KPA Target :' + ISNULL(@KPA_Target,'')										
										    + '#' +  'Weightage :' +  CAST(ISNULL(@KPA_Weightage,'')AS VARCHAR(18)) 
										    + '#' +  'Designation :' + ISNULL(@desig_id,'')	
										    + '#' +  'Department :' + ISNULL(@dept_id,'')
			--Added By Mukti(end)09112016
				End
		end
	Else If @tran_type = 'D'
		begin
			if @uploadtype = 1
				begin
				--Added By Mukti(start)09112016					
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER where Emp_ID=@Emp_Id
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER where Cmp_Id=@Cmp_Id
				
				select @OldKPA_Content=KPA_Content, @OldKPA_Target=KPA_Target,@OldKPA_Weightage=KPA_Weightage,@OldEffective_Date=Effective_Date
				from T0060_Appraisal_EmployeeKPA
				where Emp_KPA_Id = @Emp_KPA_Id and Emp_Id=@Emp_Id
				--Added By Mukti(end)09112016		
				
				--added (23-04-2021)
				SELECT @Period=[Period] FROM T0055_Hrms_Initiate_KPASetting WHERE Emp_Id = @Emp_Id AND KPA_StartDate=@OldEffective_Date
				SELECT @ALPHA_EMP_CODE=ALPHA_EMP_CODE FROM T0080_EMP_MASTER WHERE EMP_ID=@Emp_Id
				Delete FROM Wcl_EmployeeGoalMaster WHERE EMP_Code=@ALPHA_EMP_CODE AND Period=@Period
				Delete From T0060_Appraisal_EmployeeKPA Where Emp_Id=@Emp_Id 
				
				--Added By Mukti(start)09112016	
				set @OldValue =	'old Value' + '#' +  'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'Effective Date :' + CONVERT(nvarchar(35),isnull(@OldEffective_Date,''))
									    	+ '#' +  'Employee  :' + ISNULL(@Emp_name,'') 
										    + '#' +  'KPA Content :' + ISNULL(@OldKPA_Content,'') 
										    + '#' +  'KPA Target :' + ISNULL(@OldKPA_Target,'')										
										    + '#' +  'Weightage :' +  CAST(ISNULL(@OldKPA_Weightage,'')AS VARCHAR(18))
				--Added By Mukti(end)09112016		
				end
			Else if @uploadtype = 2 
				begin
				--Added By Mukti(start)09112016					
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER where Emp_ID=@Emp_Id
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER where Cmp_Id=@Cmp_Id
				
				SELECT @OldKPA_Content=KPA_Content, @OldKPA_Target=KPA_Target,@OldKPA_Weightage=KPA_Weightage,
					   @OldEffective_Date=Effective_Date,@Olddesig_id=Desig_Id,@Olddept_id=Dept_Id
				from T0051_KPA_Master
				where KPA_id = @Emp_KPA_Id 
				--Added By Mukti(end)09112016	
				
				DELETE FROM T0051_KPA_Master WHERE KPA_id = @Emp_KPA_Id 
					
				--Added By Mukti(start)09112016	
				set @OldValue =	'old Value' + '#' +  'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#' +  'Effective Date :' + CONVERT(nvarchar(35),isnull(@OldEffective_Date,''))
									    	+ '#' +  'Employee  :' + ISNULL(@Emp_name,'') 
										    + '#' +  'KPA Content :' + ISNULL(@OldKPA_Content,'') 
										    + '#' +  'KPA Target :' + ISNULL(@OldKPA_Target,'')										
										    + '#' +  'Weightage :' +  CAST(ISNULL(@OldKPA_Weightage,'')AS VARCHAR(18))
										    + '#' +  'Designation :' + ISNULL(@Olddesig_id,'')	
										    + '#' +  'Department :' + ISNULL(@Olddept_id,'')	
				--Added By Mukti(end)09112016	
				End
		end
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Employee KPA',@OldValue,@Emp_KPA_Id,@User_Id,@IP_Address
RETURN


--------------------


