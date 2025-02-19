



--Mitesh 04/08/2011 ALTER for chnages of view on home page employee attendance
CREATE PROCEDURE [dbo].[SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET_DISPLAY]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(5000)
	,@Report_For	varchar(50) = 'EMP RECORD'


AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON 
	
	Declare @First_In_Last_Out_For_Att_Regularization tinyint 
		
	Select @First_In_Last_Out_For_Att_Regularization= isnull(First_In_Last_Out_For_Att_Regularization,0) from T0040_GENERAL_SETTING WITH (NOLOCK) 
	where Cmp_ID = @Cmp_ID and Branch_ID = @Branch_ID and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id) 
	
	if @First_In_Last_Out_For_Att_Regularization = 0
		Begin
			exec SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET_MULTIPLE_ENTRY @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,@Report_For
		End
	Else
		Begin
			exec SP_RPT_EMP_IN_OUT_MUSTER_HOME_GET @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,@Report_For
		End
	
	Select @First_In_Last_Out_For_Att_Regularization as Reg_Flag


