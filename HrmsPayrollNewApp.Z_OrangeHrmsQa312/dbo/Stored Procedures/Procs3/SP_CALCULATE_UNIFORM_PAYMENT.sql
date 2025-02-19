CREATE PROCEDURE [dbo].[SP_CALCULATE_UNIFORM_PAYMENT]
	@CMP_ID			NUMERIC ,
	@EMP_ID			NUMERIC,
	@From_Date		Datetime,
	@To_Date		DATETIME,
	@SALARY_TRAN_ID	NUMERIC ,
	@Is_FNF			int = 0,
	@Uniform_Apr_Id		int = 0,
	@Pending_Amount numeric(18,2)=0
AS
	    SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
	
	Declare @Uni_Apr_Id Numeric(18,0)
	Declare @Issue_Date datetime
	Declare @Uni_Amount Numeric(18,2)
	Declare @Uni_deduct_Amount Numeric(18,2)
	Declare @Uni_Refund_Amount Numeric(18,2)
	Declare @Return_Amount Numeric(18,2)
	Declare @Month_St_Date Datetime
	Declare @Month_End_Date Datetime
	Declare @Uni_Flag int
	Declare @Payment_Amount Numeric(18,2)
	Declare @Pending_Uni_Amt Numeric(18,2)
	Declare @Branch_ID_Temp Numeric(18,0)
	Declare @Sal_St_Date Datetime 
	Declare @Sal_end_Date   Datetime 
	Declare @Uni_Pay_ID Numeric(18,0)
	Declare @Deduct_Pending_Amount Numeric(18,2)
	Declare @Refund_Pending_Amount Numeric(18,2)
	DECLARE @Deduction_Start_Date datetime
	DECLARE @Refund_Start_Date datetime

	Begin
		if @Is_FNF=0
			BEGIN
		
			
				Declare CurUnifor Cursor For
				Select Uni_Apr_Id,Issue_Date,Uni_Amount,Uni_deduct_Amount,Uni_Refund_Amount,(Case When Refund_Pending_Amount > 0 and Deduct_Pending_Amount = 0 then 1 ELSE 0 END),Deduct_Pending_Amount,Refund_Pending_Amount, CAST(Deduction_Start_Date AS varchar(11)), Refund_Start_Date
				From T0100_Uniform_Emp_Issue WITH (NOLOCK)
				Where Cmp_ID = @Cmp_ID and Emp_ID = @EMP_ID
				and (Deduct_Pending_Amount > 0 or (Refund_Pending_Amount > 0 and Deduct_Pending_Amount = 0))
				and Cast(cast(Issue_Date as varchar(11)) as datetime) <= Cast(cast(@To_Date as varchar(11)) as datetime)
				
				Open  CurUnifor
				Fetch next from CurUnifor into @Uni_Apr_Id,@Issue_Date,@Uni_Amount,@Uni_deduct_Amount,@Uni_Refund_Amount,@Uni_Flag,@Deduct_Pending_Amount,@Refund_Pending_Amount, @Deduction_Start_Date, @Refund_Start_Date 
					While @@fetch_status = 0
						BEGIN
							
							set @Month_St_Date = @From_Date 
							set @Month_End_Date = @To_Date 
							
							Select @Branch_ID_Temp = Branch_ID From T0095_Increment I WITH (NOLOCK) inner join     
							(select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) 
							where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID group by emp_ID) Qry on    
							I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID
							
							Select @Sal_St_Date = Sal_st_Date 
							from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID_Temp    
							and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID_Temp and Cmp_ID = @Cmp_ID)    
							
							if isnull(@Sal_St_Date,'') = ''    
								begin    
									set @Month_St_Date  = @Month_St_Date     
									set @Month_End_Date = @Month_End_Date    
								end     
							else if day(@Sal_St_Date) =1 
								begin    
									set @Month_St_Date  = @Month_St_Date     
									set @Month_End_Date = @Month_End_Date    
								end     
							else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
								begin    
									set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@From_Date) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
									set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 

									Set @Month_St_Date = @Sal_St_Date
									Set @Month_End_Date = @Sal_End_Date    
								end
							
							SELECT	@Return_Amount = isnull(sum(Payment_Amount),0) from T0210_Uniform_Monthly_Payment WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Uni_Apr_Id = @Uni_Apr_Id and Payment_Date <=  @To_Date and Uni_Flag = @Uni_Flag
							Set @Pending_Uni_Amt  = @Uni_Amount - @Return_Amount 
							
							IF @Uni_Flag = 0 AND  @Month_End_Date < @Deduction_Start_Date
								GOTO G
							ELSE IF @Uni_Flag = 1 AND @Month_End_Date < @Refund_Start_Date
								GOTO G
							
							if @Pending_Uni_Amt > 0
								Begin
									if @Uni_Flag = 0
										Begin
											if @Uni_deduct_Amount < @Deduct_Pending_Amount  
												--Set @Payment_Amount = @Uni_Refund_Amount
												set @Payment_Amount = @Uni_deduct_Amount
											Else 
												set @Payment_Amount = @Deduct_Pending_Amount											
										End
									Else
										Begin
											--if @Uni_deduct_Amount < @Refund_Pending_Amount    
												--Set @Payment_Amount = @Uni_deduct_Amount
											if @Uni_Refund_Amount < @Refund_Pending_Amount 
												set @Payment_Amount = @Uni_Refund_Amount
											Else 
												set @Payment_Amount = @Refund_Pending_Amount											
										End
									
									Select @Uni_Pay_ID = Isnull(MAX(Uni_Pay_ID),0) + 1  From T0210_Uniform_Monthly_Payment WITH (NOLOCK)
									if @SALARY_TRAN_ID > 0
										Begin
											Insert into T0210_Uniform_Monthly_Payment
											(Uni_Pay_ID,Uni_Apr_Id,Emp_ID,Cmp_ID,Sal_Tran_ID,Payment_Amount,Payment_Date,Uni_Flag)
											Values(@Uni_Pay_ID,@Uni_Apr_Id,@EMP_ID,@CMP_ID,@SALARY_TRAN_ID,@Payment_Amount,@To_Date,@Uni_Flag)
										End
								End	
			G:
							Fetch next from CurUnifor into @Uni_Apr_Id,@Issue_Date,@Uni_Amount,@Uni_deduct_Amount,@Uni_Refund_Amount,@Uni_Flag,@Deduct_Pending_Amount,@Refund_Pending_Amount, @Deduction_Start_Date, @Refund_Start_Date
						End
				CLOSE CurUnifor
				DEALLOCATE CurUnifor
			END
		ELSE if @Is_FNF=1	--Mukti(12052017)
			BEGIN
				set @Month_St_Date = @From_Date 
				set @Month_End_Date = @To_Date 
				
				Select @Branch_ID_Temp = Branch_ID From T0095_Increment I WITH (NOLOCK) inner join     
				(select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) 
				where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
				I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id Where I.Emp_ID = @Emp_ID
				
				Select @Sal_St_Date = Sal_st_Date 
				from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID_Temp    
				and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID_Temp and Cmp_ID = @Cmp_ID)    
				
				if isnull(@Sal_St_Date,'') = ''    
					begin    
						set @Month_St_Date  = @Month_St_Date     
						set @Month_End_Date = @Month_End_Date    
					end     
				else if day(@Sal_St_Date) =1 
					begin    
						set @Month_St_Date  = @Month_St_Date     
						set @Month_End_Date = @Month_End_Date    
					end     
				else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
					begin    
						set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,@From_Date) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
						set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 

						Set @Month_St_Date = @Sal_St_Date
						Set @Month_End_Date = @Sal_End_Date    
					end
				
				--SELECT	@Return_Amount = isnull(sum(Payment_Amount),0) from T0210_Uniform_Monthly_Payment where Cmp_ID = @Cmp_ID and Uni_Apr_Id = @Uni_Apr_Id and Payment_Date <=  @To_Date and Uni_Flag = @Uni_Flag
				--Set @Pending_Uni_Amt  = @Uni_Amount - @Return_Amount 
				
				if @Pending_Amount > 0
					Begin
						--if @Uni_Flag = 0
						--	Begin
						--		if @Uni_deduct_Amount < @Deduct_Pending_Amount  
						--			Set @Payment_Amount = @Uni_Refund_Amount
						--		Else 
						--			set @Payment_Amount = @Deduct_Pending_Amount
						--	End
						--Else
						--	Begin
						--		if @Uni_deduct_Amount < @Refund_Pending_Amount    
						--			Set @Payment_Amount = @Uni_deduct_Amount
						--		Else 
						--			set @Payment_Amount = @Refund_Pending_Amount
						--	End
						
						Select @Uni_Pay_ID = Isnull(MAX(Uni_Pay_ID),0) + 1  From T0210_Uniform_Monthly_Payment WITH (NOLOCK)
						print @To_Date
						if @SALARY_TRAN_ID > 0
							Begin
								Insert into T0210_Uniform_Monthly_Payment
								(Uni_Pay_ID,Uni_Apr_Id,Emp_ID,Cmp_ID,Sal_Tran_ID,Payment_Amount,Payment_Date,Uni_Flag)
								Values(@Uni_Pay_ID,@Uniform_Apr_Id,@EMP_ID,@CMP_ID,@SALARY_TRAN_ID,@Pending_Amount,@To_Date,0)
							End
				END
			END	
	End  



