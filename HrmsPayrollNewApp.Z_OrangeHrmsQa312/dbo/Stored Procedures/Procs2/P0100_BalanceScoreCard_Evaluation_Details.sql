



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0100_BalanceScoreCard_Evaluation_Details]
	   @Emp_BSC_Review_Detail_Id	numeric(18,0)  
      ,@Cmp_Id						numeric(18,0)
      ,@Emp_Id						numeric(18,0)
      ,@Emp_BSC_Review_Id			numeric(18,0)
      ,@BSC_Setting_Detail_Id		numeric(18,0)
      ,@Actual						nvarchar(100)
      ,@Score						varchar(50)
      ,@WeightedScore				numeric(18,2)
      ,@finyear						int
      ,@Review_Type					int
      ,@Tran_Type					varchar(1)
      ,@User_Id						numeric(18,0)
      ,@IP_Address					varchar(30)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	
	
	declare @OldValue as nvarchar(max)
	declare @OldActual as nvarchar(100)
	declare @OldScore as varchar(50)
	declare @OldWeightedScore as varchar(18)
	declare @oldDate as varchar(50)
	
	set @OldValue =''
	set @OldActual = ''
	set @OldScore =''
	set @OldWeightedScore =''	
	set @oldDate =''
	
	IF @Tran_Type = 'I'
		BEGIN
			IF 	@Emp_BSC_Review_Id =0
				BEGIN 
					SELECT @Emp_BSC_Review_Id= isnull(max(Emp_BSC_Review_Id),0) from T0095_BalanceScoreCard_Evaluation WITH (NOLOCK) where Cmp_Id = @cmp_id and emp_id=@emp_id  and Review_Type=@Review_Type					
					IF @Emp_BSC_Review_Id =0
						BEGIN
							set @Emp_BSC_Review_Detail_Id = 0
							select @Emp_BSC_Review_Detail_Id
							RETURN
						END
				END
			SELECT @Emp_BSC_Review_Detail_Id = isnull(max(Emp_BSC_Review_Detail_Id),0)+1 from T0100_BalanceScoreCard_Evaluation_Details WITH (NOLOCK)
			
			INSERT INTO T0100_BalanceScoreCard_Evaluation_Details
			(
				   Emp_BSC_Review_Detail_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,Emp_BSC_Review_Id
				  ,BSC_Setting_Detail_Id
				  ,Actual
				  ,Score
				  ,WeightedScore
			)
			VALUES
			(
				   @Emp_BSC_Review_Detail_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@Emp_BSC_Review_Id
				  ,@BSC_Setting_Detail_Id
				  ,@Actual
				  ,@Score
				  ,@WeightedScore
			)
			SET @OldValue = 'New Value' + '#'+ 'Emp Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Actual :' + cast(@Actual as VARCHAR) + '#' 
												 + 'Superior Score :' + isnull(@Score,'') + '#'   + 'Weighted Score :' + cast(@WeightedScore as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
		END	
	Else IF @Tran_Type = 'U'
		BEGIN
			SELECT @OldActual = cast(Actual as varchar) ,
				   @OldScore =isnull(Score,''),@OldWeightedScore = isnull(cast([WeightedScore] as VARCHAR),'')				  
			FROM dbo.T0100_BalanceScoreCard_Evaluation_Details WITH (NOLOCK)
			WHERE Cmp_ID = @Cmp_ID and Emp_BSC_Review_Detail_Id = @Emp_BSC_Review_Detail_Id
			
			UPDATE T0100_BalanceScoreCard_Evaluation_Details
			SET  Actual = @Actual
			    ,[Score] = @Score
			    ,WeightedScore = @WeightedScore
			WHERE Emp_BSC_Review_Detail_Id = @Emp_BSC_Review_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Actual :' + cast(@OldActual as VARCHAR) + '#' 
											 + 'Superior Score :' + isnull(@OldScore,'') + '#' + 'Weighted Score :' + cast(@OldWeightedScore as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
					       + 'New Value' + '#'+ 'Emp Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Actual :' + cast(@Actual as VARCHAR) + '#'  
											  + 'Superior Score :' + isnull(@Score,'') + '#'  + '#' + 'Weighted Score :' + cast(@WeightedScore as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)		
		END
	Else IF @Tran_Type = 'D'
		BEGIN
			SELECT @OldActual = cast(Actual as varchar),
				   @OldScore =isnull(Score,''),@OldWeightedScore = isnull(cast([WeightedScore] as VARCHAR),'')				  
			FROM dbo.T0100_BalanceScoreCard_Evaluation_Details WITH (NOLOCK)
			WHERE Cmp_ID = @Cmp_ID and Emp_BSC_Review_Detail_Id = @Emp_BSC_Review_Detail_Id
			
			SET @OldValue = 'Old Value' + '#'+ 'Emp Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'Actual :' + cast(@OldActual as VARCHAR) + '#'  
											 + 'Superior Score :' + isnull(@OldScore,'') + '#' + 'Weighted Score :' + cast(@OldWeightedScore as varchar) + '#' + 'Date :' +  cast(GETDATE() as varchar)	
											 
			DELETE FROM T0100_BalanceScoreCard_Evaluation_Details WHERE Emp_BSC_Review_Detail_Id = @Emp_BSC_Review_Detail_Id
		END
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Balance Score Review Details',@OldValue,@Emp_BSC_Review_Detail_Id,@User_Id,@IP_Address
END


