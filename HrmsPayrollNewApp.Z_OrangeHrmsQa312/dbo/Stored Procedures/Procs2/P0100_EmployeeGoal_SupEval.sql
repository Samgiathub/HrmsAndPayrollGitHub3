
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_EmployeeGoal_SupEval]
	   @SupEval_Id							numeric(18,0)				
      ,@Cmp_Id								numeric(18,0)
      ,@Emp_Id								numeric(18,0)
      ,@Emp_GoalSetting_Review_Id			numeric(18,0)	
      ,@SupEval_Comments					varchar(300)
      ,@YearEnd_FinalRating					varchar(12)
      ,@YearEnd_NormalRating				varchar(12)
      ,@finyear								int
      ,@Review_Type							int
      ,@Sup_PromoRecommend					bit		= 0 --added on 22/03/2017
      ,@Final_PromoRecommend				bit		= 0	--added on 22/03/2017
      ,@Tran_Type							varchar(1)
      ,@User_Id								numeric(18,0)
      ,@IP_Address							varchar(30)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

	declare @OldValue as nvarchar(max)
	declare @OldSupEval_Comments as varchar(300)
	declare @OldYearEnd_FinalRating as varchar(12)
	declare @OldYearEnd_NormalRating as varchar(12)
	
	set @OldValue =''
	set @OldSupEval_Comments = ''
	set @OldYearEnd_FinalRating = ''
	set @OldYearEnd_NormalRating =''
	
	IF @Tran_Type = 'I'
		BEGIN
			IF 	@Emp_GoalSetting_Review_Id =0
				BEGIN 
					select @Emp_GoalSetting_Review_Id= isnull(max(Emp_GoalSetting_Review_Id),0) from T0095_EmployeeGoalSetting_Evaluation WITH (NOLOCK) where Cmp_Id = @cmp_id and emp_id=@emp_id and FinYear = @finyear and Review_Type=@Review_Type					
					if @Emp_GoalSetting_Review_Id =0
						BEGIN
							set @SupEval_Id = 0
							select @SupEval_Id
							RETURN
						END
				END
			SELECT @SupEval_Id = isnull(max(SupEval_Id),0)+1 from T0100_EmployeeGoal_SupEval WITH (NOLOCK)
			INSERT INTO T0100_EmployeeGoal_SupEval
			(
				   SupEval_Id
				  ,Cmp_Id
				  ,Emp_Id
				  ,Emp_GoalSetting_Review_Id
				  ,SupEval_Comments
				  ,YearEnd_FinalRating
				  ,YearEnd_NormalRating
				  ,Sup_PromoRecommend
				  ,Final_PromoRecommend
			)
			VALUES
			(
				   @SupEval_Id
				  ,@Cmp_Id
				  ,@Emp_Id
				  ,@Emp_GoalSetting_Review_Id
				  ,@SupEval_Comments
				  ,@YearEnd_FinalRating
				  ,@YearEnd_NormalRating
				  ,@Sup_PromoRecommend
				  ,@Final_PromoRecommend
			)
			SET @OldValue = 'New Value' + '#'+ 'Emp Id :' + cast(@Emp_Id as varchar) + '#' + 'Financial year :' + cast(@FinYear as varchar) + '#' + 'SupEval Comments :' + cast(@SupEval_Comments as VARCHAR) + '#' + 'YearEnd FinalRating :' +ISNULL(@YearEnd_FinalRating,'') + '#' 
												 + 'YearEnd NormalRating :' + isnull(@YearEnd_NormalRating,'') +  '#' + 'Date :' +  cast(GETDATE() as varchar)	
		END
	Else IF @Tran_Type = 'U'
		BEGIN
			SELECT @OldSupEval_Comments=SupEval_Comments,@OldYearEnd_FinalRating=YearEnd_FinalRating,@OldYearEnd_NormalRating= YearEnd_NormalRating
			FROM T0100_EmployeeGoal_SupEval WITH (NOLOCK)
			Where Cmp_ID = @Cmp_ID and SupEval_Id = @SupEval_Id
			
			UPDATE T0100_EmployeeGoal_SupEval
			SET SupEval_Comments = @SupEval_Comments
			    ,YearEnd_FinalRating = @YearEnd_FinalRating	
			    ,YearEnd_NormalRating = @YearEnd_NormalRating
			    ,Sup_PromoRecommend = @Sup_PromoRecommend
			    ,Final_PromoRecommend = @Final_PromoRecommend
			WHERE   SupEval_Id = @SupEval_Id
		END
	Else IF @Tran_Type = 'D'
		BEGIN
			DELETE FROM T0100_EmployeeGoal_SupEval WHERE   SupEval_Id = @SupEval_Id 
		END
END


