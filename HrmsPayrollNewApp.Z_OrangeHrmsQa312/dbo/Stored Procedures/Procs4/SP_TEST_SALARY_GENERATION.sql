




CREATE PROCEDURE [dbo].[SP_TEST_SALARY_GENERATION]
	@Cmp_ID 	numeric ,
	@from_Date	Datetime,
	@To_Date	Datetime ,
	@emp_Id		Numeric ,
	@Is_Delete	int ,
	@Fix_Days	numeric(5,1)
AS
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

		Declare @for_Date Datetime 
		Declare @PDay numeric(5,1)
		Declare @Month_St_Date datetime 
		Declare @Month_end_Date datetime 
		Declare @Sal_Tran_ID	numeric 
--		set @Emp_ID  =341
--		set @cmp_ID = 7
--		set @From_Date ='01-jan-2001'
--		set @To_Date ='31-dec-2008'
		set @for_Date =@from_Date
		
		if @Is_Delete =0 
			begin
					while @for_Date <=@To_Date
						begin
							select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@For_DAte),Year(@For_DaTE))
							select  @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@For_DAte),Year(@For_DaTE))
							set @PDay = datediff(d,@Month_St_Date,@Month_end_Date) +1
							--set @PDay  =20
							if @Fix_Days > 0 
								set @PDay = @Fix_Days 	
								
							Exec P0200_MONTHLY_SALARY_GENERATE_MANUAL  0 ,@Emp_ID,@Cmp_ID,@Month_St_Date,@Month_St_Date,@Month_end_Date,@PDay,0,0,0,0,0,0,1,0,0,'N'
						set @for_Date = dateadd(m,1,@For_Date)
					end
			end
		Else --------Delete  ----------
			Begin
				while @for_Date >=@From_Date
						begin
							select  @Month_St_Date = dbo.GET_MONTH_ST_DATE(month(@For_DAte),Year(@For_DaTE))
							select  @Month_end_Date = dbo.GET_MONTH_END_DATE(month(@For_DAte),Year(@For_DaTE))

							select @Sal_Tran_ID = Sal_Tran_ID From T0200_Monthly_Salary WITH (NOLOCK) Where Emp_ID =@Emp_ID and Month_St_Date >=@From_Date and Month_ST_Date <=@To_Date
							Exec dbo.P0200_MONTHLY_SALARY_DELETE @Sal_Tran_ID,@Emp_ID,@Cmp_ID,@From_Date,@To_date,''		
							set @for_Date = dateadd(m,-1,@For_Date)
					end	
							
			end 

	RETURN




