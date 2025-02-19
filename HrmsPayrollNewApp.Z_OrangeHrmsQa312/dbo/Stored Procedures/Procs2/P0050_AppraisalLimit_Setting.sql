

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_AppraisalLimit_Setting]
	 @Limit_Id						numeric(18,0) OUTPUT
	,@Cmp_ID						numeric(18,0)
	,@ScoreLimit_KPA				numeric(18,2)
	,@ScoreLimit_PA					numeric(18,2)
	,@ScoreLimit_PoA				numeric(18,2)
	,@RecommendLimit_Skill			numeric(18,0)
	,@RecommendLimit_GM				numeric(18,0)
	,@JoiningDate_Limit				numeric(18,0)
	,@KPA_Limit						numeric(18,0) = null
	,@KpaMaster_Yes					int
	,@KPA_Default					bit = 1 -- 04/02/2015
	,@KPA_Score						bit = 1 -- 23 Feb 2015
	,@KPA_AllowEmp					bit = 0 -- 23 feb 2015
	,@SA_SubCriteria				bit = 0 -- 23 feb 2015
	,@OA_ViewByManager				bit = 1 -- 27 Jun 2015
	,@KPA_AllowEmpScore_Display		bit = 0 -- 7 Oct 2015
	,@KPA_AllowRMScore_Display		bit = 0 -- 7 Oct 2015
	,@KPA_Percentage				bit = 0 -- 12 feb 2016 sneha
	,@KPA_PerScore					numeric(5,0)-- 12 feb 2016 sneha
	,@KPA_AllowAddKPA				bit = 0 -- 13 feb 2016 sneha
	,@Emp_AssessApprove_days		int	= null	-- 3 Mar 2016 sneha
	,@Emp_PA_Approve_RM_days		int = null	-- 3 Mar 2016 sneha
	,@PA_HOD_Days					int = null	-- 3 Mar 2016 sneha
	,@PA_GH_Days					int = null	-- 3 Mar 2016 sneha
	,@Effective_Date				datetime = null	--19 Sep 2016
	,@tran_type						varchar(1)	
	,@User_Id						numeric(18,0) = 0
	,@IP_Address					varchar(30)= ''
	,@Multiple_Evalution			int = 0--Added by Mukti(15112016)set 0 for Yearly Evaluation and 1 for Multiple Evaluation of Appraisal
	,@Interim_EvaluationBy			varchar(50)=null-- 21 Nov 2016 sneha
	,@Interim_DisplayTab			varchar(100)=null-- 21 Nov 2016 sneha
	,@Display_PreviousKPA			bit = 0 --23 Nov 2016 sneha
	,@Display_PreviousKPAYear		bit = 0 --26 Nov 2016 sneha
	,@Final_DisplayTab				varchar(100) = null-- 11 Dec 2017 sneha
	,@Send_Dept_Wise				numeric(18,0) = 0--Mukti(31012018)
	,@SAWithQueAnswer				numeric(18,0) = 0--Mukti(31012018)
	,@usingFormula					numeric(18,0) = 0--Mukti(31012018)
	,@ShowKPAMeasure				numeric(18,0) = 0 -- Added by nilesh patel on 12-03-2018
	,@TotalKPAWeightage				numeric(18,0) = 0
	,@MinKPA						numeric(18,0) = 0
	,@MaxKPA						numeric(18,0) = 0
	,@show_Completion_Date			int =  0
	,@show_Attach_Document			int =  0
	,@show_Justification			int =  0
	,@MinKPAWeightage				float=0
	,@MaxKPAWeightage				float=0
	,@Score_Using_STDFormula		int =0 -- Added by Deepali 14-July2022
	,@Score_Using_PerFormula        int =0 ---  Added by Deepali 20042023
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
	--If Upper(@tran_type) ='I' Or Upper(@tran_type) ='U'
	--	Begin
	--		If @Type = 0
	--			BEGIN
	--				Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Select type',0,'type not selected',GetDate(),'Appraisal')						
	--				Return
	--			END	
	--	End
	If Upper(@tran_type) ='I'
		Begin
			select @Limit_Id = isnull(max(Limit_Id),0) + 1 from T0050_AppraisalLimit_Setting WITH (NOLOCK)	
			Insert into T0050_AppraisalLimit_Setting
			(
				 Limit_Id						
				,Cmp_ID						
				,ScoreLimit_KPA
				,ScoreLimit_PA
				,ScoreLimit_PoA
				,RecommendLimit_Skill
				,RecommendLimit_GM
				,JoiningDate_Limit
				,KPA_Limit
				,KpaMaster_Yes
				,KPA_Default		-- 04/02/2015
				,KPA_Score			-- 23 feb 2015
				,KPA_AllowEmp		-- 23 feb 2015
				,SA_SubCriteria		-- 23 feb 2015
				,OA_ViewByManager	-- 27 Jun 2015
				,KPA_AllowEmpScore_Display -- 7 Oct 2015
				,KPA_AllowRMScore_Display -- 7 Oct 2015
				,KPA_Percentage -- 12 feb 2016 sneha
				,KPA_PerScore	-- 12 feb 2016 sneha
				,KPA_AllowAddKPA -- 13 feb 2016 sneha
				,Emp_AssessApprove_days	 -- 3 Mar 2016 sneha	
				,Emp_PA_Approve_RM_days	 -- 3 Mar 2016 sneha
				,PA_HOD_Days			 -- 3 Mar 2016 sneha		
				,PA_GH_Days				 -- 3 Mar 2016 sneha
				,Effective_Date			 -- 19 Sep 2016	
				,Multiple_Evaluation		 --	Added By Mukti(15112016)
				,Interim_EvaluationBy	 -- 21 Nov 2016 sneha
				,Interim_DisplayTab		 -- 21 Nov 2016 sneha
				,Display_PreviousKPA	 -- 23 Nov 2016 sneha
				,Display_PreviousKPAYear -- 26 Nov 2016 sneha
				,Final_DisplayTab		 -- 11 Dec 2017 sneha
				,Send_Dept_Wise
				,Self_Assessment_With_Answer
				,Score_Using_Formula
				,Show_KPA_Measure
				,Total_KPA_Weightage
				,MinKPA
				,MaxKPA
				,show_Completion_Date	
				,show_Attach_Document		
				,show_Justification
				,MinKPAWeightage
				,MaxKPAWeightage
				,Score_Using_STDFormula  --Added by Deepali 20042023
				,Score_Using_PerFormula  --Added by Deepali 20042023
			)
			Values
			(
				 @Limit_Id
				,@Cmp_ID
				,@ScoreLimit_KPA
				,@ScoreLimit_PA
				,@ScoreLimit_PoA
				,@RecommendLimit_Skill
				,@RecommendLimit_GM
				,@JoiningDate_Limit
				,@KPA_Limit
				,@KpaMaster_Yes  
				,@KPA_Default		-- 04/02/2015
				,@KPA_Score			-- 23 feb 2015
				,@KPA_AllowEmp		-- 23 feb 2015
				,@SA_SubCriteria	-- 23 feb 2015
				,@OA_ViewByManager  -- 27 jun 2015
				,@KPA_AllowEmpScore_Display -- 7 Oct 2015
				,@KPA_AllowRMScore_Display -- 7 Oct 2015
				,@KPA_Percentage -- 12 feb 2016 sneha
				,@KPA_PerScore	-- 12 feb 2016 sneha
				,@KPA_AllowAddKPA -- 13 feb 2016 sneha
				,@Emp_AssessApprove_days	 -- 3 Mar 2016 sneha	
				,@Emp_PA_Approve_RM_days	 -- 3 Mar 2016 sneha
				,@PA_HOD_Days				 -- 3 Mar 2016 sneha		
				,@PA_GH_Days				 -- 3 Mar 2016 sneha
				,@Effective_Date			-- 19 Sep 2016
				,@Multiple_Evalution		--	Added By Mukti(15112016)
				,@Interim_EvaluationBy		-- 21 Nov 2016 sneha
				,@Interim_DisplayTab		-- 21 Nov 2016 sneha
				,@Display_PreviousKPA		-- 23 Nov 2016 sneha
				,@Display_PreviousKPAYear	-- 26 Nov 2016 sneha
				,@Final_DisplayTab			-- 11 Dec 2017 sneha
				,@Send_Dept_Wise
				,@SAWithQueAnswer
				,@usingFormula
				,@ShowKPAMeasure
				,@TotalKPAWeightage
				,@MinKPA
				,@MaxKPA
				,@show_Completion_Date	
				,@show_Attach_Document		
				,@show_Justification
				,@MinKPAWeightage
				,@MaxKPAWeightage
				,@Score_Using_STDFormula      --Added by Deepali 20042023
				,@Score_Using_PerFormula      --Added by Deepali 20042023
			)

			if @KPA_Limit > 0
				UPDATE T0050_AppraisalLimit_Setting SET MaxKPA=@KPA_Limit WHERE Limit_Id =	@Limit_Id
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
			Update	T0050_AppraisalLimit_Setting
			Set		ScoreLimit_KPA			=	@ScoreLimit_KPA,
					ScoreLimit_PA			=	@ScoreLimit_PA,
					ScoreLimit_PoA			=	@ScoreLimit_PoA,
					RecommendLimit_Skill	=	@RecommendLimit_Skill,
					RecommendLimit_GM		=	@RecommendLimit_GM,
					JoiningDate_Limit		=   @JoiningDate_Limit,
					KPA_Limit				=	@KPA_Limit,
					KpaMaster_Yes			=	@KpaMaster_Yes,
					KPA_Default				=	@KPA_Default    -- 04/02/2015  
				   ,KPA_Score				=	@KPA_Score		-- 23 feb 2015
				   ,KPA_AllowEmp			=	@KPA_AllowEmp	-- 23 feb 2015
				   ,SA_SubCriteria			=	@SA_SubCriteria	-- 23 feb 2015 
				   ,OA_ViewByManager		=   @OA_ViewByManager -- 27 Jun 2015
				   ,KPA_AllowEmpScore_Display=  @KPA_AllowEmpScore_Display -- 7 Oct 2015
				   ,KPA_AllowRMScore_Display =  @KPA_AllowRMScore_Display -- 7 Oct 2015 
				   ,KPA_Percentage			=	@KPA_Percentage-- 12 feb 2016 sneha
				   ,KPA_PerScore			=	@KPA_PerScore -- 12 feb 2016 sneha
				   ,KPA_AllowAddKPA			=	@KPA_AllowAddKPA -- 13 feb 2016 sneha
				   ,Emp_AssessApprove_days	=	@Emp_AssessApprove_days	 -- 3 Mar 2016 sneha	
				   ,Emp_PA_Approve_RM_days	=	@Emp_PA_Approve_RM_days -- 3 Mar 2016 sneha
				   ,PA_HOD_Days				=	@PA_HOD_Days -- 3 Mar 2016 sneha		
				   ,PA_GH_Days				=   @PA_GH_Days	 -- 3 Mar 2016 sneha
				   ,Effective_Date			=	@Effective_Date --19 Sep 2016	
				   ,Multiple_Evaluation		=   @Multiple_Evalution	--	Added By Mukti(15112016)
				   ,Interim_EvaluationBy	=	@Interim_EvaluationBy	-- 21 Nov 2016 sneha
				   ,Interim_DisplayTab		=   @Interim_DisplayTab		-- 21 Nov 2016 sneha
				   ,Display_PreviousKPA		=	@Display_PreviousKPA	-- 23 Nov 2016 sneha
				   ,Display_PreviousKPAYear	=   @Display_PreviousKPAYear-- 26 Nov 2016 sneha
				   ,Final_DisplayTab		=   @Final_DisplayTab       -- 11 Dec 2017 sneha
				   ,Send_Dept_Wise			=   @Send_Dept_Wise
				   ,Self_Assessment_With_Answer			=   @SAWithQueAnswer
				   ,Score_Using_Formula			=	@usingFormula
				   ,Show_KPA_Measure		=	@ShowKPAMeasure
				   ,Total_KPA_Weightage      =   @TotalKPAWeightage
				   ,MinKPA = @MinKPA
				   ,MaxKPA = @MaxKPA
				   ,show_Completion_Date	= @show_Completion_Date
				   ,show_Attach_Document = @show_Attach_Document		
				   ,show_Justification = @show_Justification
				   ,MinKPAWeightage	= @MinKPAWeightage
				   ,MaxKPAWeightage = @MaxKPAWeightage
				   ,Score_Using_STDFormula= @Score_Using_STDFormula
				   ,Score_Using_PerFormula = @Score_Using_PerFormula
			Where	Limit_Id                =	@Limit_Id

			if @KPA_Limit > 0
				UPDATE T0050_AppraisalLimit_Setting SET MaxKPA=@KPA_Limit WHERE Limit_Id =	@Limit_Id
		End
	Else If  Upper(@tran_type) ='D'
		Begin
			DELETE FROM T0050_AppraisalLimit_Setting WHERE Limit_Id = @Limit_Id
		End
END
------------------


