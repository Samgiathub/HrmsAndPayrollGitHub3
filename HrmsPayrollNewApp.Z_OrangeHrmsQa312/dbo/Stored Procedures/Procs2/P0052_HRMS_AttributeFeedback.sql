-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0052_HRMS_AttributeFeedback]
			 @EmpAtt_ID			numeric(18) output  
			,@Cmp_ID			numeric(18)   
			,@InitiateId		numeric(18)		=null 
			,@Emp_Id			numeric(18)		=null
			,@PA_ID				numeric(18)		=null
			,@Att_Type			varchar(5)      =null
			,@Att_Score			numeric(18)		=null
			,@Att_Achievement   numeric(18,2)	=null
			,@Att_Critical		nvarchar(1000)	=null --Changed by Deepali 02Jun22
			,@PF_Score			numeric(18,2)	=null
			,@PF_Final			numeric(18,2)	=null
			,@Threshold_value   numeric(18,2)	=null --Mukti(05022018)
			,@tran_type			varchar(1) 
			,@User_Id			numeric(18,0)	= 0
			,@IP_Address		varchar(30)		= '' 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @OldValue as nvarchar(max)
Declare @Emp_name as Varchar(250)
Declare @Cmp_name as Varchar(250)
Declare @Att_Type_Name as Varchar(25)
Declare @OldAtt_Type as Varchar(25)
Declare @OldAtt_Type_Name as Varchar(25)
Declare @OldAtt_Score as Varchar(25)
Declare @OldAtt_Achievement as Varchar(25)
Declare @OldAtt_Critical as nVarchar(1000)
set @OldValue = ''

if @Att_Achievement		= 0
	set	@Att_Achievement=null
if @Att_Critical		= ''
	set	@Att_Critical	=null
if @PF_Score			= 0
	set	@PF_Score		=null
if @PF_Final			= 0
	set	@PF_Final		=null
		
If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
	Begin
		If @Att_Score = null
			BEGIN
				if @Att_Type='PA'
					Begin
						update 	T0050_HRMS_InitiateAppraisal set
								PF_Score = @PF_Score,
								PF_Final = @PF_Final
						Where InitiateId = @InitiateId and Cmp_ID=@Cmp_ID	
					End
				else if @Att_Type = 'PoA'
					Begin
						update 	T0050_HRMS_InitiateAppraisal set
								PO_Score = @PF_Score,
								PO_Final = @PF_Final
						Where InitiateId = @InitiateId and Cmp_ID=@Cmp_ID
					End
			--Added By Mukti(start)10112016
				select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
				select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id		
				select @OldAtt_Type=Att_Type from T0052_HRMS_AttributeFeedback WITH (NOLOCK) where EmpAtt_ID = @EmpAtt_ID and Initiation_Id = @InitiateId
				if @Att_Type='PA'
					set @Att_Type_Name='Performance Attribute'
				else if @Att_Type='PoA'
					set @Att_Type_Name='Potential Attribute'
					
				if @OldAtt_Type='PA'
					set @OldAtt_Type_Name='Performance Attribute'
				else if @OldAtt_Type='PoA'
					set @OldAtt_Type_Name='Potential Attribute'
					
				set @OldValue = 'old Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
											+ '#'+ 'Type :' +ISNULL(@OldAtt_Type_Name,'') 
											+ '#'+ 'Score :' +CONVERT(nvarchar(10),ISNULL(@OldAtt_Score,0)) 
											+ '#'+ 'Achievement :' +CONVERT(nvarchar(10),ISNULL(@OldAtt_Achievement,0)) 
											+ '#'+ 'Critical :' +ISNULL(@OldAtt_Critical,'') 
							+'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
											+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
											+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0))
											+ '#'+ 'Type :' +ISNULL(@Att_Type_Name,'') 
											+ '#'+ 'Score :' +CONVERT(nvarchar(10),ISNULL(@Att_Score,0)) 
											+ '#'+ 'Achievement :' +CONVERT(nvarchar(10),ISNULL(@Att_Achievement,0)) 
											+ '#'+ 'Critical :' +ISNULL(@Att_Critical,'') 
			--Added By Mukti(end)10112016	
				--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Score is not Properly Inserted',0,'Enter Score',GetDate(),'Appraisal')										
				Return
			END
	End	
If Upper(@tran_type) ='I'
	Begin
	--Added By Mukti(start)10112016
		select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
		select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id		
		if @Att_Type='PA'
			set @Att_Type_Name='Performance Attribute'
		else if @Att_Type='PoA'
			set @Att_Type_Name='Potential Attribute'
			
		set @OldValue = 'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
									+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
									+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0))
									+ '#'+ 'Type :' +ISNULL(@Att_Type_Name,'') 
									+ '#'+ 'Score :' +CONVERT(nvarchar(10),ISNULL(@Att_Score,0)) 
									+ '#'+ 'Achievement :' +CONVERT(nvarchar(10),ISNULL(@Att_Achievement,0)) 
									+ '#'+ 'Critical :' +ISNULL(@Att_Critical,'') 
		
	--Added By Mukti(end)10112016	
	
		select @EmpAtt_ID = isnull(max(EmpAtt_ID),0) + 1 from T0052_HRMS_AttributeFeedback WITH (NOLOCK)
		Insert into T0052_HRMS_AttributeFeedback
		(
				EmpAtt_ID
			   ,Cmp_ID
			   ,Initiation_Id
			   ,Emp_Id
			   ,PA_ID
			   ,Att_Type
			   ,Att_Score
			   ,Att_Achievement
			   ,Att_Critical
			   ,Threshold_value
		)
		values
		(
			    @EmpAtt_ID
			   ,@Cmp_ID
			   ,@InitiateId
			   ,@Emp_Id
			   ,@PA_ID
			   ,@Att_Type
			   ,@Att_Score
			   ,@Att_Achievement
			   ,@Att_Critical
			   ,@Threshold_value
		)
	End
Else If  Upper(@tran_type) ='U' 
	Begin
	--Added By Mukti(start)10112016
		select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
		select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id		
		select @OldAtt_Type=Att_Type from T0052_HRMS_AttributeFeedback WITH (NOLOCK) where EmpAtt_ID = @EmpAtt_ID and Initiation_Id = @InitiateId
		if @Att_Type='PA'
			set @Att_Type_Name='Performance Attribute'
		else if @Att_Type='PoA'
			set @Att_Type_Name='Potential Attribute'
			
		if @OldAtt_Type='PA'
			set @OldAtt_Type_Name='Performance Attribute'
		else if @OldAtt_Type='PoA'
			set @OldAtt_Type_Name='Potential Attribute'
			
		set @OldValue = 'old Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
									+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
									+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
									+ '#'+ 'Type :' +ISNULL(@OldAtt_Type_Name,'') 
									+ '#'+ 'Score :' +CONVERT(nvarchar(10),ISNULL(@OldAtt_Score,0)) 
									+ '#'+ 'Achievement :' +CONVERT(nvarchar(10),ISNULL(@OldAtt_Achievement,0)) 
									+ '#'+ 'Critical :' +ISNULL(@OldAtt_Critical,'') 
					+'New Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
									+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
									+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0))
									+ '#'+ 'Type :' +ISNULL(@Att_Type_Name,'') 
									+ '#'+ 'Score :' +CONVERT(nvarchar(10),ISNULL(@Att_Score,0)) 
									+ '#'+ 'Achievement :' +CONVERT(nvarchar(10),ISNULL(@Att_Achievement,0)) 
									+ '#'+ 'Critical :' +ISNULL(@Att_Critical,'') 
		
	--Added By Mukti(end)10112016	
	
		  Update T0052_HRMS_AttributeFeedback
		  Set    Att_Type				= @Att_Type
				,Att_Achievement		=@Att_Achievement
				,Att_Critical			=@Att_Critical
				,Threshold_value       =@Threshold_value
		  Where  EmpAtt_ID = @EmpAtt_ID and Initiation_Id = @InitiateId
	End
Else If  Upper(@tran_type) ='D'
	Begin
	--Added By Mukti(start)10112016
		select @Cmp_name=Cmp_Name from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@Cmp_Id
		select @Emp_name=Alpha_Emp_Code +'-'+ Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_Id		
		select @OldAtt_Type=Att_Type from T0052_HRMS_AttributeFeedback WITH (NOLOCK) where EmpAtt_ID = @EmpAtt_ID and Initiation_Id = @InitiateId
		if @Att_Type='PA'
			set @Att_Type_Name='Performance Attribute'
		else if @Att_Type='PoA'
			set @Att_Type_Name='Potential Attribute'
			
		if @OldAtt_Type='PA'
			set @OldAtt_Type_Name='Performance Attribute'
		else if @OldAtt_Type='PoA'
			set @OldAtt_Type_Name='Potential Attribute'
			
		set @OldValue = 'old Value' + '#'+ 'Company Name :' + ISNULL(@Cmp_name,'') 
									+ '#'+ 'Initiate Id :' +CONVERT(nvarchar(10),ISNULL(@InitiateId,0)) 
									+ '#'+ 'Employee :' +ISNULL(@Emp_name,'') 
									+ '#'+ 'Type :' +ISNULL(@OldAtt_Type_Name,'') 
									+ '#'+ 'Score :' +CONVERT(nvarchar(10),ISNULL(@OldAtt_Score,0)) 
									+ '#'+ 'Achievement :' +CONVERT(nvarchar(10),ISNULL(@OldAtt_Achievement,0)) 
									+ '#'+ 'Critical :' +ISNULL(@OldAtt_Critical,'') 
	--Added By Mukti(end)10112016							
		DELETE FROM T0052_HRMS_AttributeFeedback WHERE EmpAtt_ID = EmpAtt_ID
	End
if @Att_Type='PA'
	Begin
		update 	T0050_HRMS_InitiateAppraisal set
				PF_Score = @PF_Score,
				PF_Final = @PF_Final
		Where InitiateId = @InitiateId and Cmp_ID=@Cmp_ID	
	End
else if @Att_Type = 'PoA'
	Begin
		update 	T0050_HRMS_InitiateAppraisal set
				PO_Score = @PF_Score,
				PO_Final = @PF_Final
		Where InitiateId = @InitiateId and Cmp_ID=@Cmp_ID
	End
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Appraisal Attribute Feedback',@OldValue,@EmpAtt_ID,@User_Id,@IP_Address	
END
