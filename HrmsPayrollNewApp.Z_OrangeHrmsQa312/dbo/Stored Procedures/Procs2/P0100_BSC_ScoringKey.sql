


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0100_BSC_ScoringKey]
	   @BSC_ScoringKey_Id		numeric(18,0)
      ,@Cmp_Id					numeric(18,0)
      ,@BSC_Setting_Detail_Id	numeric(18,0)
      ,@Key_Name				varchar(50)
      ,@Key_Value				nvarchar(100)
      ,@Emp_Id					numeric(18,0)
      ,@finyear					int
      ,@KPI_id					numeric(18,0)
      ,@BSC_Objective			nvarchar(max)	
      ,@Tran_Type				varchar(1)
      ,@User_Id					numeric(18,0)
      ,@IP_Address				varchar(30)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


BEGIN
	
	declare @OldValue as varchar(max)
	declare @OldKey_Name as nvarchar(50)
	declare @OldKey_Value as varchar(100)
	declare @oldDate as varchar(50)
	
	set @OldValue =''
	set @OldKey_Name = ''
	set @OldKey_Value = ''
	set @oldDate =''
	
	IF @Tran_Type = 'I'
		BEGIN
			if @BSC_Setting_Detail_Id =0
				BEGIN
					select @BSC_Setting_Detail_Id= max(BSC_Setting_Detail_Id) 
					from T0095_BalanceScoreCard_Setting_Details WITH (NOLOCK) inner Join 
					     T0090_BalanceScoreCard_Setting S WITH (NOLOCK) on S.BSC_SettingId = T0095_BalanceScoreCard_Setting_Details.BSC_SettingId
					where T0095_BalanceScoreCard_Setting_Details.Cmp_Id = @cmp_id and T0095_BalanceScoreCard_Setting_Details.emp_id=@emp_id and FinYear = @finyear and KPI_Id=@KPI_Id
						and T0095_BalanceScoreCard_Setting_Details.BSC_Objective = @BSC_Objective
				END
				
			IF EXISTS(select 1 from T0100_BSC_ScoringKey WITH (NOLOCK) where BSC_Setting_Detail_Id=@BSC_Setting_Detail_Id and Key_Name= @Key_Name)
				BEGIN				   
					SELECT @BSC_ScoringKey_Id = BSC_ScoringKey_Id from T0100_BSC_ScoringKey WITH (NOLOCK) where BSC_Setting_Detail_Id=@BSC_Setting_Detail_Id and Key_Name= @Key_Name
					UPDATE T0100_BSC_ScoringKey
					SET Key_Value =@Key_Value
					WHERE  BSC_ScoringKey_Id = @BSC_ScoringKey_Id 
				END
			Else
				BEGIN
					SELECT @BSC_ScoringKey_Id = isnull(max(BSC_ScoringKey_Id),0)+1 from T0100_BSC_ScoringKey WITH (NOLOCK)
					INSERT INTO T0100_BSC_ScoringKey
						(
							BSC_ScoringKey_Id
						   ,Cmp_Id
						   ,BSC_Setting_Detail_Id
						   ,Key_Name
						   ,Key_Value
						)VALUES
						(
							@BSC_ScoringKey_Id
						   ,@Cmp_Id
						   ,@BSC_Setting_Detail_Id
						   ,@Key_Name
						   ,@Key_Value
						)
				END
			SET @OldValue = 'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Key Name :' + cast(@Key_Name as VARCHAR) + '#' + 'Key Value :' +ISNULL(@Key_Value,'') + '#' 
										 + 'Date :' +  cast(GETDATE() as varchar)	
		END
	Else IF @Tran_Type = 'U'
		BEGIN
			select @OldKey_Name =cast(Key_Name as varchar),@OldKey_Value = cast(Key_Value as varchar)				  
			From T0100_BSC_ScoringKey WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and BSC_ScoringKey_Id = @BSC_ScoringKey_Id
			
			UPDATE T0100_BSC_ScoringKey
			SET Key_Name = @Key_Name
				,Key_Value =@Key_Value
			WHERE  BSC_ScoringKey_Id = BSC_ScoringKey_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Key Name :' + cast(@OldKey_Name as VARCHAR) + '#' + 'Key Value :' +ISNULL(@OldKey_Value,'') + '#' 
										 + 'Date :' +  cast(GETDATE() as varchar)	+
							'New Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Key Name :' + cast(@Key_Name as VARCHAR) + '#' + 'Key Value :' +ISNULL(@Key_Value,'') + '#' 
										 + 'Date :' +  cast(GETDATE() as varchar)	
		END
	ELSE IF @Tran_Type = 'D'
		BEGIN
			select @OldKey_Name =cast(Key_Name as varchar),@OldKey_Value = cast(Key_Value as varchar)				 			  
			From dbo. T0100_BSC_ScoringKey WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and BSC_ScoringKey_Id = @BSC_ScoringKey_Id
			
			DELETE FROM T0100_BSC_ScoringKey where BSC_ScoringKey_Id = @BSC_ScoringKey_Id
			
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp_Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Key Name :' + cast(@OldKey_Name as VARCHAR) + '#' + 'Key Value :' +ISNULL(@OldKey_Value,'') + '#' 
										 + 'Date :' +  cast(GETDATE() as varchar)
		END
	 exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Balance Score Card Key',@OldValue,@BSC_ScoringKey_Id,@User_Id,@IP_Address
END


