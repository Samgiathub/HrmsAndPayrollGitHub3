---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0052_SurveyTemplate]
	   @SurveyQuestion_Id		numeric(18,0) Output
	  ,@Cmp_Id					numeric(18,0)
	  ,@Survey_Id				numeric(18,0)
	  ,@Survey_Question			nvarchar(500)
	  ,@Survey_Type				Nvarchar(50)
	  ,@Sorting_No				int
	  ,@Question_Option			Nvarchar(800)
	  ,@tran_type		 varchar(1) 
	  ,@User_Id		 numeric(18,0) = 0
	  ,@IP_Address	 varchar(30)= '' 
	  ,@SubQuestion		tinyint
	  ,@Is_Mandatory	tinyint=1
	  ,@Answer NVARCHAR(500)
	  ,@Marks float
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

--declare @MaxSortID as int
	
	if @Question_Option <> ''
		Begin
			IF Right(@Question_Option,1) = '#'
			  Begin
				Set @Question_Option = LEFT(@Question_Option, LEN(@Question_Option) - 1)
			  End
		End

	If Upper(@tran_type) ='I'
		BEGIN
			--If Exists(select 1 From T0052_SurveyTemplate  Where cmp_ID = @cmp_id  and Sorting_No =@Sorting_No and Survey_Id=@Survey_Id)
			--	Begin
			--		set @SurveyQuestion_Id = 0
			--		RAISERROR ('This sorting number is allocated', 16, 2)
			--		Return 
			--	end
			If Exists(select 1 From T0052_SurveyTemplate WITH (NOLOCK) Where cmp_ID = @cmp_id and Survey_Question =@Survey_Question and Survey_Id=@Survey_Id)
				Begin
						set @SurveyQuestion_Id = 0
					RAISERROR ('This question already exists', 16, 2)
					Return 
				end
			select @SurveyQuestion_Id = isnull(max(SurveyQuestion_Id),0) + 1 from T0052_SurveyTemplate WITH (NOLOCK)
			Insert Into T0052_SurveyTemplate
			(
				SurveyQuestion_Id
			   ,Cmp_Id
			   ,Survey_Id
			   ,Survey_Question
			   ,Survey_Type
			   ,Sorting_No
			   ,Question_Option
			   ,SubQuestion
			   ,Is_Mandatory
			   ,Answer
			   ,Marks
			)
			Values
			(
				 @SurveyQuestion_Id
				,@Cmp_Id
				,@Survey_Id
				,@Survey_Question
				,@Survey_Type
				,@Sorting_No
				,@Question_Option
				,@SubQuestion
				,@Is_Mandatory
				,@Answer
				,@Marks
			)	
			
			--SELECT @MaxSortID = MAX(SurveyQuestion_Id) + 1 FROM T0052_SURVEYTEMPLATE			
			UPDATE	T
			SET		Sorting_No = Row_ID  + @Sorting_No
			FROM	T0052_SURVEYTEMPLATE T
					INNER JOIN (SELECT	ROW_NUMBER() OVER(ORDER BY Sorting_No) AS ROW_ID, SurveyQuestion_Id
								FROM	T0052_SURVEYTEMPLATE WITH (NOLOCK)
								WHERE	Survey_Id=@Survey_Id AND Sorting_No >= @Sorting_No AND SurveyQuestion_Id <> @SurveyQuestion_Id) 
			T1 ON T.SurveyQuestion_Id=T1.SurveyQuestion_Id

			exec P0040_SurveyQuestBank 0,@Cmp_ID,@Survey_Question,@Survey_Type,@Question_Option,@Answer,@Marks,@tran_type		
		END
	Else If  Upper(@tran_type) ='U' 
		Begin
			If Exists(select 1 From T0052_SurveyTemplate WITH (NOLOCK)  Where cmp_ID = @cmp_id and @SurveyQuestion_Id<>@SurveyQuestion_Id and Sorting_No =@Sorting_No and Survey_Id=@Survey_Id)
					Begin
						set @SurveyQuestion_Id = 0
						RAISERROR ('This sorting number is allocated', 16, 2)
						Return 
					end
				If Exists(select 1 From T0052_SurveyTemplate WITH (NOLOCK)  Where cmp_ID = @cmp_id and @SurveyQuestion_Id<>@SurveyQuestion_Id and Survey_Question =@Survey_Question and Survey_Id=@Survey_Id)
					Begin
							set @SurveyQuestion_Id = 0
						RAISERROR ('This question already exists', 16, 2)
						Return 
					end
			
				UPDATE    T0052_SurveyTemplate
				SET        Survey_Question		=	@Survey_Question
						  ,Survey_Type			=	@Survey_Type
						  ,Sorting_No			=	@Sorting_No
						  ,Question_Option		=	@Question_Option
						  ,SubQuestion			=	@SubQuestion	
						  ,Is_Mandatory         =   @Is_Mandatory	
						  ,Answer				=	@Answer
						  ,Marks				=	@Marks
				WHERE SurveyQuestion_Id = @SurveyQuestion_Id and cmp_Id=@Cmp_ID
									
				--SELECT @MaxSortID = MAX(SurveyQuestion_Id) + 1 FROM T0052_SURVEYTEMPLATE
				SELECT @Sorting_No,@SurveyQuestion_Id
				SELECT	ROW_NUMBER() OVER(ORDER BY Sorting_No) AS ROW_ID, SurveyQuestion_Id
									FROM	T0052_SURVEYTEMPLATE WITH (NOLOCK)
									WHERE	Survey_Id=@Survey_Id AND Sorting_No >= @Sorting_No AND SurveyQuestion_Id <> @SurveyQuestion_Id
									
				UPDATE	T
				SET		Sorting_No = Row_ID  + @Sorting_No
				FROM	T0052_SURVEYTEMPLATE T
						INNER JOIN (SELECT	ROW_NUMBER() OVER(ORDER BY Sorting_No) AS ROW_ID, SurveyQuestion_Id
									FROM	T0052_SURVEYTEMPLATE WITH (NOLOCK)
									WHERE	Survey_Id=@Survey_Id AND Sorting_No >= @Sorting_No AND SurveyQuestion_Id <> @SurveyQuestion_Id) 
				T1 ON T.SurveyQuestion_Id=T1.SurveyQuestion_Id
			End	
	Else If  Upper(@tran_type) ='D'
		Begin
			Delete from  T0052_SurveyTemplate where SurveyQuestion_Id = @SurveyQuestion_Id
		End
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Survey','',@SurveyQuestion_Id,@User_Id,@IP_Address

END
