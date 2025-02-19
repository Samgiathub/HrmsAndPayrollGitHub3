



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_IT_TAX_ALLOWANCE_EXEMPT_GET]
	@Emp_ID				numeric ,
	@Cmp_ID				numeric ,
	@Increment_id		numeric,
	@From_Date			datetime ,
	@To_date			datetime,
	@Month_Count		numeric ,
	@Allow_Exempt		numeric output
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Declare @Cont_HRA_Exemp		tinyint 
		Declare @Cont_Conv_Exemp	tinyint 
		Declare @Cont_Edu_Exemp		tinyint 
		Declare @Cont_Medical_Exemp		tinyint 
		
		set @Cont_HRA_Exemp		=7
		set @Cont_Conv_Exemp	=9
		set @Cont_Edu_Exemp		= 8
		set @Cont_Medical_Exemp	= 11

	
		DECLARE @EMP_CHILDRAN		NUMERIC
		DECLARE @HRA_AMOUNT			NUMERIC 
		DECLARE @CURRENT_HRA_AMOUNT NUMERIC 
		Declare @Actual_Month		numeric 
		Declare @MA_Exempted_Amount numeric 
		Declare @IT_MAX_LIMIT		numeric
		Declare @Total_Conv_Amount  numeric 
		Declare @Settlement_Amount  numeric 		
		DECLARE @Conv_Exemption		numeric 
		Declare @IT_D_Amount		numeric
		Declare @HRA_Exemption		numeric
		Declare @Edu_Exemption		numeric
		
		set @Edu_Exemption= 0
		set @Total_Conv_Amount =0
		set @Conv_Exemption =0
		set @MA_Exempted_Amount =0

        
		
			select @Actual_Month = Count(emp_Id) from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID and Month_St_Date  >=@From_Date and Month_St_Date <=@To_date
			
		if exists(select Emp_ID from T0100_Emp_earn_Deduction eed WITH (NOLOCK) inner join
					T0050_AD_MAster am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and AD_IT_DEF_ID = @Cont_Edu_Exemp where Emp_Id = @Emp_Id and Increment_id = @Increment_id )
			Begin
			
				select @EMP_CHILDRAN = ISNULL(EMP_CHILDRAN,0) From T0095_Increment WITH (NOLOCK) where Emp_ID= @Emp_ID and Increment_ID =@Increment_id
				SET @Edu_Exemption = 100 * (@EMP_CHILDRAN * (@Actual_Month + @Month_Count)  ) 
				
			End

		If exists(select Emp_ID from T0100_Emp_earn_Deduction eed WITH (NOLOCK) inner join
					T0050_AD_MAster am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and AD_IT_DEF_ID = @Cont_Conv_Exemp where Emp_Id = @Emp_Id and Increment_id = @Increment_id )
			Begin
			    
				select @Total_Conv_Amount = isnull(sum(M_AD_Amount),0) from T0210_monthLy_AD_Detail mad WITH (NOLOCK) inner join T0050_AD_MASTER am WITH (NOLOCK) on mad.AD_ID = am.AD_ID 
					Where emp_ID = @Emp_ID and For_date >= @From_Date and For_Date <= @To_Date and AD_IT_DEF_ID =@Cont_Conv_Exemp
			   
				If @From_Date < '01-Apr-2015' --Changed by Hardik 09/06/2015 as rule changed from 01-apr-2015
					Set @Conv_Exemption = 800 * (@Actual_Month + @Month_Count)
				Else
					Set @Conv_Exemption = 1600 * (@Actual_Month + @Month_Count)
					
				if @Conv_Exemption > @Total_Conv_Amount  and @Total_Conv_Amount > 0
						set @Conv_Exemption = @Total_Conv_Amount 
													
			End
	
		Select @HRA_Amount = isnull(sum(M_AD_Amount),0)  from T0210_Monthly_AD_Detail mad WITH (NOLOCK) inner join
					T0050_AD_MAster am WITH (NOLOCK) on mad.AD_ID= am.AD_ID and AD_IT_DEF_ID = @Cont_HRA_Exemp
		Where Emp_ID =@Emp_ID and For_Date >=@From_Date and for_Date <=@To_Date
			
								  		
		select @Current_HRA_Amount = isnull(E_AD_Amount,0) from T0100_Emp_earn_Deduction eed WITH (NOLOCK) inner join
					T0050_AD_MAster am WITH (NOLOCK) on eed.AD_ID= am.AD_ID and AD_IT_DEF_ID = @Cont_HRA_Exemp
		Where Emp_Id = @Emp_Id and Increment_id = @Increment_id 
				
		Exec dbo.SP_IT_TAX_HOUSING_EXEMPTION @Emp_ID,@From_Date,@To_Date,@Increment_ID,@HRA_Amount output,0,@HRA_Exemption output ,0,0,0,0,@Month_Count
						
		set @Allow_Exempt = @Allow_Exempt + isnull(@IT_D_Amount,0)
		set @Allow_Exempt = @Edu_Exemption + @HRA_Exemption + @Conv_Exemption + @MA_Exempted_Amount
	 	  
		Update #Tax_Report Set Amount_Col_Final = @MA_Exempted_Amount 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Medical_Exemp


		
		Update #Tax_Report Set Amount_Col_Final =  @Conv_Exemption
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Conv_Exemp
		
		--Select * from #Tax_Report where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Conv_Exemp

		Update #Tax_Report Set Amount_Col_Final = @Edu_Exemption 
		where Emp_ID =@Emp_ID and Default_Def_ID = @Cont_Edu_Exemp
		
	

  RETURN
  



