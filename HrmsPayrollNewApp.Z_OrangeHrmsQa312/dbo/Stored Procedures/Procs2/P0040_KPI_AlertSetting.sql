


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_KPI_AlertSetting]
	 @KPI_AlertId			numeric(18,0) OUTPUT
	,@Cmp_Id				numeric(18,0)
	,@KPI_AlertDay			numeric(18,0)
	,@KPI_Month				numeric(18,0)
	,@KPI_AlertNodays		numeric(18,0)
	,@KPI_Active			int=1
	,@KPI_Type				int
	,@KPI_Preference		bit = null
	,@Emp_TrainingSuggest	bit = null
	,@Allow_EditObjective	bit = null --added on 16 Mar 2015
	,@Allow_EmpEditObj		bit = null --added on 16 Mar 2015
	,@KPI_AlertType			int = null --added on 16 Mar 2015
	,@Allow_Emp_IRating		bit = null --added on 18 Mar 2015
	,@Allow_Emp_FRating     bit = null --added on 18 Mar 2015
	,@tran_type				varchar(1) 
    ,@User_Id				numeric(18,0) = 0
	,@IP_Address			varchar(30)= '' 

AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	 If Upper(@tran_type) ='I'
		Begin
			select @KPI_AlertId = isnull(max(KPI_AlertId),0) + 1 from T0040_KPI_AlertSetting WITH (NOLOCK)
			Insert Into T0040_KPI_AlertSetting
			(
				 KPI_AlertId
				,Cmp_Id
				,KPI_AlertDay
				,KPI_Month
				,KPI_AlertNodays
				,KPI_Active
				,KPI_Type
				,KPI_Preference
				,Emp_TrainingSuggest --13 mar 2015
				,Allow_EditObjective --16 mar 2015 
				,Allow_EmpEditObj	 --16 mar 2015
				,KPI_AlertType		 --16 mar 2015
				,Allow_Emp_IRating	 --18 Mar 2015 
				,Allow_Emp_FRating   --18 Mar 2015 
			)
			Values
			(
				 @KPI_AlertId
				,@Cmp_Id
				,@KPI_AlertDay
				,@KPI_Month
				,@KPI_AlertNodays
				,@KPI_Active
				,@KPI_Type
				,@KPI_Preference
				,@Emp_TrainingSuggest --13 mar 2015
				,@Allow_EditObjective --16 mar 2015
				,@Allow_EmpEditObj    --16 mar 2015
				,@KPI_AlertType       --16 mar 2015  
				,@Allow_Emp_IRating	  --18 Mar 2015
				,@Allow_Emp_FRating   --18 Mar 2015 
			)
		End
	Else If  Upper(@tran_type) ='U' 
		Begin
			UPDATE    T0040_KPI_AlertSetting
			Set		  KPI_AlertDay		=	@KPI_AlertDay
					 ,KPI_Month			=	@KPI_Month
				     ,KPI_AlertNodays	=	@KPI_AlertNodays
				     ,KPI_Active		=	@KPI_Active
				     ,KPI_Preference	=   @KPI_Preference
				     ,Emp_TrainingSuggest = @Emp_TrainingSuggest --13 mar 2015
				     ,Allow_EditObjective = @Allow_EditObjective --16 mar 2015
				     ,Allow_EmpEditObj    = @Allow_EmpEditObj    --16 mar 2015
				     ,KPI_AlertType		  = @KPI_AlertType		 --16 mar 2015  
				     ,Allow_Emp_IRating	  = @Allow_Emp_IRating   --18 Mar 2015 
					 ,Allow_Emp_FRating   =	@Allow_Emp_FRating   --18 Mar 2015 
			Where	 KPI_AlertId=@KPI_AlertId and cmp_Id=@Cmp_ID
		End
	Else If  Upper(@tran_type) ='D'
		Begin
			DELETE FROM T0040_KPI_AlertSetting WHERE KPI_AlertId = @KPI_AlertId and  cmp_Id=@Cmp_ID and KPI_Type=@KPI_Type
		End 
END


