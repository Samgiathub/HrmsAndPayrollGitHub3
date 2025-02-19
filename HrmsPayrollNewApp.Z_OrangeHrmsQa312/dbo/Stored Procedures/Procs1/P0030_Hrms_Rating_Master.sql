

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0030_Hrms_Rating_Master]
	@Rate_Id as Numeric(18) OUTPUT,
	@Rate_Value As Numeric(18,2),
	@Rate_Text As nVarchar(50),   --Changed by Deepali -04Jun22
	@Cmp_ID As Numeric(18),
	@Trans_Type As Char(1) ,
	@description_value as nvarchar(100)  --Changed by Deepali -04Jun22
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
	If @Trans_Type='I'
	Begin
	  
	  if exists(Select Cmp_ID from dbo.T0030_Hrms_Rating_Master WITH (NOLOCK) where Rate_Text=@Rate_Text AND Cmp_Id=@Cmp_Id)
	  Begin	  
	  Set @Rate_Id = -1
	  Return 	  
	  End
	Else If exists(Select Cmp_ID from dbo.T0030_Hrms_Rating_Master WITH (NOLOCK) where Rate_Value=@Rate_Value AND Cmp_ID=@Cmp_ID)	
	Begin	
	  Set @Rate_Id = -2
	  Return 	
	End		  	  
	  
	  select @Rate_Id = isnull(max(Rate_Id),0)+1  from dbo.T0030_Hrms_Rating_Master	 WITH (NOLOCK)
	  
	  Insert INTO dbo.T0030_Hrms_Rating_Master
	  (
			Rate_Id, 
			Rate_Value, 
			Rate_Text ,
			Cmp_ID ,
			description_value			
	  )
	  Values	  
	  (
	  	    @Rate_Id, 
			@Rate_Value, 
			@Rate_Text ,
			@Cmp_ID ,
			@description_value
	  )	  
	End 
	
	Else If @Trans_Type='U'	
	Begin	
	
	if exists(Select Cmp_ID from dbo.T0030_Hrms_Rating_Master WITH (NOLOCK) where Rate_Text=@Rate_Text and Rate_Id <> @Rate_ID and Cmp_ID = @Cmp_Id) 
	  Begin	  
	  Set @Rate_Id = -1	  
	  Return 	  
	  End	  
	Else If exists(Select Cmp_ID from dbo.T0030_Hrms_Rating_Master WITH (NOLOCK) where Rate_Value=@Rate_Value and Rate_Id <> @Rate_ID and Cmp_ID = @Cmp_Id )	
	Begin	
	  Set @Rate_Id = -2	  
	  Return 	
	End
	
	Update dbo.T0030_Hrms_Rating_Master 
	  SET			
			Rate_Value = @Rate_Value, 
			Rate_Text = @Rate_Text ,
			Cmp_ID = @Cmp_ID 	,
			description_value=@description_value	
			Where Rate_ID=@Rate_ID
	End 
	
	Else If @Trans_Type='D'
	Begin
		If Exists(Select 1 From T0055_HRMS_Skill_Rate_Detail WITH (NOLOCK) where Skill_R_Rate_Min=@Rate_Id) 	
			Begin
				RAISERROR('Reference Exit',16,2)
				Return
			End
		Else
			Begin
				Delete From dbo.T0030_Hrms_Rating_Master where Rate_Id=@Rate_Id	
			End
	End 
RETURN

