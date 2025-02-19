


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0095_BalanceScoreCard_Setting_Details]
	   @BSC_Setting_Detail_Id	numeric(18,0)
      ,@Cmp_Id					numeric(18,0)
      ,@BSC_SettingId			numeric(18,0)
      ,@Emp_Id					numeric(18,0)
      ,@KPI_Id					numeric(18,0)
      ,@BSC_Objective			nvarchar(max)		
      ,@BSC_Measure				nvarchar(200)
      ,@BSC_Target				nvarchar(100)
      ,@BSC_Formula				nvarchar(100)
      ,@BSC_Weight				numeric(18,2)
      ,@finyear					int
      -----
      --,@BSC_ScoringKey_Id		numeric(18,0)
      --,@Key_Name				varchar(50)
      --,@Key_Value				nvarchar(100)
      -----
      ,@Tran_Type				varchar(1)
      ,@User_Id					numeric(18,0)
      ,@IP_Address				varchar(30)
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @OldValue as varchar(max)
	declare @OldBSC_Objective as nvarchar(max)
	declare @OldBSC_Measure as nvarchar(200)
	declare @OldBSC_Target as varchar(100)
	declare @OldBSC_Formula as varchar(100)
	declare @OldBSC_Weight as varchar(18)
	declare @oldDate as varchar(50)
	
	set @OldValue =''
	set @OldBSC_Objective = ''
	set @OldBSC_Measure = ''
	set @OldBSC_Target =''
	set @OldBSC_Formula = ''
	set @OldBSC_Weight =''
	set @oldDate =''

	SET NOCOUNT ON;
	declare @totweight as numeric(18,2)
	set @totweight =0	
	
	IF @Tran_Type = 'I'
		BEGIN
			if 	@BSC_SettingId =0
				BEGIN 
					select @BSC_SettingId= max(BSC_SettingId) from T0090_BalanceScoreCard_Setting WITH (NOLOCK) where Cmp_Id = @cmp_id and emp_id=@emp_id and FinYear = @finyear
					
				END
			--calculate total					
			select @totweight = isnull(sum(isnull(BSC_Weight,0)),0) from T0095_BalanceScoreCard_Setting_Details WITH (NOLOCK) inner join T0090_BalanceScoreCard_Setting WITH (NOLOCK)
			on  T0090_BalanceScoreCard_Setting.BSC_SettingId=T0095_BalanceScoreCard_Setting_Details.BSC_SettingId
			WHERE  T0095_BalanceScoreCard_Setting_Details.emp_id=@emp_id and FinYear = @finyear
					and  T0090_BalanceScoreCard_Setting.BSC_SettingId=@BSC_SettingId
			
			if @totweight >= 100
				BEGIN	
					SET @BSC_SettingId = 0 
					Select @BSC_SettingId
					RETURN
				END
				
			SELECT @BSC_Setting_Detail_Id = isnull(max(BSC_Setting_Detail_Id),0)+1 from T0095_BalanceScoreCard_Setting_Details WITH (NOLOCK)
			INSERT INTO T0095_BalanceScoreCard_Setting_Details
			(
			   BSC_Setting_Detail_Id
			  ,Cmp_Id
			  ,BSC_SettingId
			  ,Emp_Id
			  ,KPI_Id
			  ,BSC_Objective
			  ,BSC_Measure
			  ,BSC_Target
			  ,BSC_Formula
			  ,BSC_Weight
			)VALUES
			(
			   @BSC_Setting_Detail_Id
			  ,@Cmp_Id
			  ,@BSC_SettingId
			  ,@Emp_Id
			  ,@KPI_Id
			  ,@BSC_Objective
			  ,@BSC_Measure
			  ,@BSC_Target
			  ,@BSC_Formula
			  ,@BSC_Weight
			)
				
			SET @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Objective :' + cast(@BSC_Objective as VARCHAR) + '#' + 'Measure :' +ISNULL(@BSC_Measure,'') + '#' 
										+ 'Target :' + isnull(@BSC_Target,'') + '#' + 'Formula :' + isnull(@BSC_Formula,'') + '#' + 'Weight :' + cast(@BSC_Weight as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
		END
	Else IF @Tran_Type = 'U'
		BEGIN
			
			select @OldBSC_Objective =cast(BSC_Objective as varchar),@OldBSC_Measure = cast(BSC_Measure as varchar),
				   @OldBSC_Target =isnull(BSC_Target,''),@BSC_Formula =isnull(BSC_Formula,''),@OldBSC_Weight = isnull(cast(BSC_Weight as VARCHAR),'')				  
			From dbo.T0095_BalanceScoreCard_Setting_Details WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and BSC_Setting_Detail_Id = @BSC_Setting_Detail_Id
		
			UPDATE T0095_BalanceScoreCard_Setting_Details
			SET    BSC_Objective = @BSC_Objective
				  ,BSC_Measure	= @BSC_Measure
				  ,BSC_Target	= @BSC_Target
				  ,BSC_Formula	= @BSC_Formula
				  ,BSC_Weight	= @BSC_Weight
			WHERE BSC_Setting_Detail_Id = @BSC_Setting_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Objective :' + cast(@OldBSC_Objective as VARCHAR) + '#' + 'Measure :' +ISNULL(@OldBSC_Measure,'') + '#' 
										+ 'Target :' + isnull(@OldBSC_Target,'') + '#' + 'Formula :' + isnull(@OldBSC_Formula,'') + '#' + 'Weight :' + cast(@OldBSC_Weight as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	+
							'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Objective :' + cast(@BSC_Objective as VARCHAR) + '#' + 'Measure :' +ISNULL(@BSC_Measure,'') + '#' 
										+ 'Target :' + isnull(@BSC_Target,'') + '#' + 'Formula :' + isnull(@BSC_Formula,'') + '#' + 'Weight :' + cast(@BSC_Weight as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
										
		END
	Else IF @Tran_Type = 'D'
		BEGIN
		
			select @OldBSC_Objective =cast(BSC_Objective as varchar),@OldBSC_Measure = cast(BSC_Measure as varchar),
				   @OldBSC_Target =isnull(BSC_Target,''),@OldBSC_Formula =isnull(BSC_Formula,''),@OldBSC_Weight = isnull(cast(BSC_Weight as VARCHAR),'')				  
			From dbo.T0095_BalanceScoreCard_Setting_Details WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and BSC_Setting_Detail_Id = @BSC_Setting_Detail_Id
		
			DELETE from T0100_BSC_ScoringKey where BSC_Setting_Detail_Id = @BSC_Setting_Detail_Id
			Delete from T0095_BalanceScoreCard_Setting_Details where BSC_Setting_Detail_Id = @BSC_Setting_Detail_Id
			
			SET @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Objective :' + cast(@OldBSC_Objective as VARCHAR) + '#' + 'Measure :' +ISNULL(@OldBSC_Measure,'') + '#' 
										+ 'Target :' + isnull(@OldBSC_Target,'') + '#' + 'Formula :' + isnull(@OldBSC_Formula,'') + '#' + 'Weight :' + cast(@OldBSC_Weight as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
		END
	 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Balance Score Card Details',@OldValue,@BSC_Setting_Detail_Id,@User_Id,@IP_Address
END


