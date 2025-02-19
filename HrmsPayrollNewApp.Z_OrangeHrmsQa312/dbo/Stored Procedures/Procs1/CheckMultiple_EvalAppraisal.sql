



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[CheckMultiple_EvalAppraisal]
	 @cmp_id numeric(18,0)
	,@initiate_date datetime
	,@request_Type int = 0 
AS
BEGIN
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

	-- @request_Type= 0 to know if mutiple evaluation applicable
	-- @request_Type= 1 to know if previous KRA to be displayed
	-- @request_Type= 2 to bring the tabs to be displayed
	-- @request_Type= 3 to bring the approvers for interim
	-- @request_Type= 4 to take the KPA of prev year to next year
		
	
	DECLARE @multiple_eval as INT
	DECLARE @response as INT
	DECLARE @Display_PreviousKPA as INT
	DECLARE @Display_PreviousKPAYear as INT
	
	set @response =0
  
  
	SELECT @multiple_eval=isnull(Multiple_Evaluation,0)
	FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
			(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
			 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
			 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@initiate_date
			 )B on B.effective_date= A.effective_date 
	WHERE a.Cmp_ID=@cmp_id --AND ISNULL(A.KPA_Default,1) = 0
	
	
	
	--IF @request_Type = 0
	--BEGIN
		IF @multiple_eval = 1
			BEGIN
				SET @response=1
			END
	--END
	
	
	
	IF @request_Type = 1
		BEGIN
			IF @multiple_eval =1
				BEGIN
					SELECT @Display_PreviousKPA=isnull(A.Display_PreviousKPA,0)
					FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
						(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
						 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
						 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@initiate_date
						 )B on B.effective_date= A.effective_date 
					WHERE a.Cmp_ID=@cmp_id 
					
					IF @Display_PreviousKPA =1
						SET @response=1
					ELSE
						SET @response=0
				END				
			ELSE	
				BEGIN
					SET @response=0
				END
		END
	
	IF @request_Type = 4
		BEGIN
			--IF @multiple_eval =1
				--BEGIN				
					SELECT @Display_PreviousKPAYear=isnull(A.Display_PreviousKPAYear,0)
					FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
						(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
						 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
						 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@initiate_date
						 )B on B.effective_date= A.effective_date 
					WHERE a.Cmp_ID=@cmp_id 
					
					IF @Display_PreviousKPAYear =1
						SET @response=1
					ELSE
						SET @response=0
			--	END				
			--ELSE	
			--	BEGIN
			--		SET @response=0
			--	END
		END
	
SELECT @response

		
	
IF @request_Type =2
	BEGIN
		IF @multiple_eval = 1
			BEGIN			
				DECLARE @Interim_DisplayTab VARCHAR(50)
				SELECT @Interim_DisplayTab=isnull(A.Interim_DisplayTab,'0#1#2')
				FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
						(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
						 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
						 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@initiate_date
						 )B on B.effective_date= A.effective_date 
				WHERE a.Cmp_ID=@cmp_id 						
				
				SELECT @Interim_DisplayTab as Interim_DisplayTab				
				--IF @Interim_DisplayTab <>''
				--	BEGIN
				--		select Data from dbo.Split(@Interim_DisplayTab,'#') where Data<>'' ORDER by Data asc
				--	END
			END	
		ELSE
			BEGIN
				SELECT '' as Interim_DisplayTab
			END
			--added on 11/12/2017 start
				DECLARE @Final_DisplayTab VARCHAR(30)
				SELECT @Final_DisplayTab = isnull(A.Final_DisplayTab,'0#1#2#3#4#5#6#7')
				FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK)
				INNER JOIN (
								SELECT isnull(max(effective_date),C.From_Date)effective_date
								FROM T0050_AppraisalLimit_Setting WITH (NOLOCK)
								INNER JOIN T0010_COMPANY_MASTER C WITH (NOLOCK) ON c.Cmp_Id = T0050_AppraisalLimit_Setting.Cmp_ID
								AND ISNULL(Effective_Date,C.From_Date) <=  @initiate_date
								WHERE C.Cmp_Id = @cmp_id
								GROUP BY C.From_Date
							)B on B.effective_date= A.effective_date 
				WHERE a.Cmp_ID=@cmp_id 
							
				SELECT @Final_DisplayTab as Final_DisplayTab
			--added on 11/12/2017 end		
	END
IF @request_Type =3	
	BEGIN
		IF @multiple_eval = 1
			BEGIN
				DECLARE @Interim_EvaluationBy VARCHAR(30)
				SELECT @Interim_EvaluationBy=isnull(A.Interim_EvaluationBy,'')
				FROM T0050_AppraisalLimit_Setting A WITH (NOLOCK) INNER JOIN
						(SELECT isnull(max(effective_date),(select From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id)) Effective_Date 
						 from T0050_AppraisalLimit_Setting WITH (NOLOCK) where Cmp_ID=@cmp_id
						 and isnull(Effective_Date,(SELECT From_Date from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id=@cmp_id))<=@initiate_date
						 )B on B.effective_date= A.effective_date 
				WHERE a.Cmp_ID=@cmp_id 
				
				SELECT @Interim_EvaluationBy AS Interim_EvaluationBy
			END
	END
	
END

