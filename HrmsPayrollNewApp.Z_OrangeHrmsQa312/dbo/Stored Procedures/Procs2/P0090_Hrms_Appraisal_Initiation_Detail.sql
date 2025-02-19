



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_Hrms_Appraisal_Initiation_Detail]

 @Appr_Detail_Id	Numeric(18, 0) output	
,@Appr_Int_Id		Numeric(18, 0)
,@Emp_Id			Numeric(18, 0)
,@Is_Emp_Submit		Int	
,@Is_Sup_submit		Int
,@Is_team_submit	Int
,@Is_Accept			Int	
,@Emp_Submit_Date	DateTime	
,@Sup_Submit_Date	DateTime	
,@team_Submit_Date	DateTime	
,@start_date	datetime	
,@End_date	datetime	
,@Trans_Type        Char(1)
		
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
 
 if @Emp_Submit_Date = ''  
  SET @Emp_Submit_Date  = NULL 
  
  if @Sup_Submit_Date = ''  
  SET @Sup_Submit_Date  = NULL 
  
 
	If	@Trans_Type='I'
	
	BEGIN		
	
	Select @Appr_Detail_Id = isnull(max(Appr_Detail_Id),0) +1   From T0090_Hrms_Appraisal_Initiation_Detail WITH (NOLOCK)
	
	
	INSERT INTO T0090_Hrms_Appraisal_Initiation_Detail
			 (		Appr_Detail_Id,	
					Appr_Int_Id	,	
					Emp_Id,	
					Is_Emp_Submit,	
					Is_Sup_submit,
					Is_team_submit,	
					Is_Accept,	
					Emp_Submit_Date,	
					Sup_Submit_Date,
					team_Submit_Date,
					start_date,	
					End_date	
			 )	
					
	VALUES   (      @Appr_Detail_Id,	
					@Appr_Int_Id,
					@Emp_Id,
					@Is_Emp_Submit,
					@Is_Sup_submit,
					@Is_team_submit,
					@Is_Accept,		
					@Emp_Submit_Date,	
					@Sup_Submit_Date,
					@team_Submit_Date,
					@start_date,	
					@End_date  )

	END
	
	
	Else If @Trans_Type='U'
	
	BEGIN
	
	UPDATE T0090_Hrms_Appraisal_Initiation_Detail
	SET 		
		Appr_Int_Id	=	@Appr_Int_Id,
		Emp_Id = @Emp_Id,
		Is_Emp_Submit =	@Is_Emp_Submit,
		Is_Sup_submit =	@Is_Sup_submit,
		Is_Accept =	@Is_Accept,		
		Emp_Submit_Date = @Emp_Submit_Date,	
		Sup_Submit_Date = @Sup_Submit_Date	
		where Appr_Detail_Id = @Appr_Detail_Id	
		
	END
	
	Else If @Trans_Type ='D'
				BEGIN
					Delete  From T0090_Hrms_Appraisal_Initiation_Detail where Appr_Int_Id = @Appr_Int_Id	
					--If Not Exists(Select Appr_Detail_Id from T0090_Hrms_Appraisal_Initiation_Detail Where Appr_Int_Id = @Appr_Int_Id)
						
							Delete From T0090_Hrms_Appraisal_Initiation Where Appr_Int_Id = @Appr_Int_Id
						
				END
	RETURN




