
CREATE PROCEDURE [dbo].[Mobile_HRMS_GetShortFall]
	@cmp_Id as numeric(18,0),
	@emp_id as numeric(18,0),
	@Exit_Id AS numeric(18,0),
	@Rpt_level as numeric(18,0),
	@branch_Id as numeric(18,0),
	@Resign_Date as datetime = NULL,
	@Left_Date as Datetime = NULL
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
		Declare @shortfall as numeric(18,0)
		Declare @Emp_Notice_Period AS NUMERIC(18,0)
		set @Emp_Notice_Period = 0
		
	
	If @cmp_Id<> 0
		Begin
			
			SELECT @Emp_Notice_Period = ISNULL(Emp_Notice_Period,0) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @emp_id	----Get Notice period from Employee (1st priority to Employee) ----Ankit 18052015
			
			IF Isnull(@Emp_Notice_Period,0) = 0
				Begin
					If @branch_Id <> 0
						Begin
							Select @shortfall=Is_Shortfall_Gradewise from T0040_GENERAL_SETTING WITH (NOLOCK) Where Cmp_ID=  @cmp_Id and Branch_ID = @branch_Id and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
								If @shortfall = 1
									Begin
										Select @Emp_Notice_Period = Short_Fall_Days from T0040_GRADE_MASTER as g WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where g.Grd_ID = e.Grd_ID and Emp_ID=@emp_id  and e.Cmp_ID=  @cmp_Id 
									End
								Else
									Begin
										Select @Emp_Notice_Period = Short_Fall_Days from T0040_GENERAL_SETTING WITH (NOLOCK) Where Cmp_ID=  @cmp_Id and Branch_ID = @branch_Id and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
									End
						End
					Else
						Begin
							Select @branch_Id=Branch_ID from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @emp_id
							Select @shortfall=Is_Shortfall_Gradewise from T0040_GENERAL_SETTING WITH (NOLOCK) Where Cmp_ID=  @cmp_Id and Branch_ID = @branch_Id and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
								If @shortfall = 1
									Begin
										Select @Emp_Notice_Period = Short_Fall_Days from T0040_GRADE_MASTER as g WITH (NOLOCK) ,T0080_EMP_MASTER as e WITH (NOLOCK) where g.Grd_ID = e.Grd_ID and Emp_ID=@emp_id  and e.Cmp_ID=  @cmp_Id 
									End
								Else
									Begin
										Select @Emp_Notice_Period = Short_Fall_Days from T0040_GENERAL_SETTING WITH (NOLOCK) Where Cmp_ID=  @cmp_Id and Branch_ID = @branch_Id and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  --Modified By Ramiz on 15092014
									End
						End
						
				End
			
			Declare @Short_Days Numeric(18)
			Set @Short_Days = 0
			IF @Resign_Date IS NOT NULL AND @Left_Date IS NOT NULL
				Begin
					if @Resign_Date <= @Left_Date
						Set @Short_Days = ((@Emp_Notice_Period - 1) - datediff(d,@Resign_Date,@Left_Date))

						if @Short_Days < 0
							Set @Short_Days = 0
				End

			Select @Emp_Notice_Period as Notice_Period,@Short_Days as Short_Days
		End
		
exec SP_Mobile_HRMS_Fill_Emp_Exit_Application @Rpt_level=@Rpt_level,@Exit_Id=@Exit_Id	
select Exit_Terms_Condition from T0011_Company_Other_Setting with(nolock) Where Cmp_ID= @cmp_Id
select Res_Id,Reason_Name from T0040_Reason_Master with(nolock) where Type='Exit' and Isactive=1
Select Is_PreQuestion From T0040_GENERAL_SETTING WITH (NOLOCK) Where Cmp_ID = @cmp_Id and Branch_ID = @branch_Id and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @cmp_Id and Branch_ID = @branch_Id)

--Added by ronakk 24082022
declare @isPreQue int =0
Select @isPreQue = Is_PreQuestion From T0040_GENERAL_SETTING WITH (NOLOCK) Where Cmp_ID = @cmp_Id and Branch_ID = @branch_Id and For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @cmp_Id and Branch_ID = @branch_Id)
if  @isPreQue = 1
Begin
exec GET_INTERVIEW_QUESTION_ASSIGNED @CMP_ID=@cmp_Id,@Exit_ID=0,@Emp_ID=@emp_id,@INSERT_QUESTIONS=1
End

--End by ronakk 24082022


END




