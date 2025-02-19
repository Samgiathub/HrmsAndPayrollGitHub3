



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Set_Salary_Register_Amount_NIIT_Lable]
 @Cmp_ID		numeric
,@From_Date		datetime
,@To_Date		datetime 
,@Branch_ID		numeric   
,@Cat_ID		numeric  
,@Grd_ID		numeric 
,@Type_ID		numeric  
,@Dept_ID		numeric  
,@Desig_ID		numeric 
,@Emp_ID		numeric 
,@Constraint	varchar(5000) 
,@Sal_Type    numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Payement varchar(50) 
	Declare @Transaction_ID Numeric
	
	set @Payement = ''
	set @Transaction_ID=0
	
	 if isnull(@Payement,'') = ''
		set  @Payement = ''
	Declare @Row_id as numeric
	Declare @Label_Name as varchar(100)
	Declare @Total_Allowance as numeric(22,2) 
	Declare @Is_Search as varchar(30)
	Declare @Basic_salary as numeric(22,2)
	Declare @Total_Allow as numeric (22,2)
	declare @Value_String as varchar(250)
	Declare @Amount as numeric (22,2)

	Declare @OTher_Allow as numeric(22,2)
	Declare @CO_Amount as numeric(22,2)
	Declare @Total_Deduction as numeric(22,2)
	Declare @Other_Dedu as numeric(22,2)
	Declare @Loan as numeric(22,2)
	Declare @Advance as numeric(22,2)
	Declare @Net_Salary as numeric(22,2)
	Declare @Revenue_amt numeric(10)
	Declare @Lwf_amt numeric(10)
	Declare @PT as numeric(22,2)
	Declare @LWF as numeric(22,2)
	Declare @Revenue as numeric(22,2)
	Declare @Allow_Name as varchar(100)
	Declare @P_Days as numeric(22,2)
	Declare @A_Days as numeric(22,2)
	Declare @Act_Gross_salary as numeric(18,2)
	DEclare @month as numeric(18,0)
	Declare @Year as numeric(18,0)
	DEclare @TDS numeric(18,2)
	Declare @Settl numeric(22,2)
	
	IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Temp_report_Label')		
			BEGIN
				DROP TABLE #Temp_report_Label
			END
		IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Temp_Salary_Muster_Report')		
			BEGIN
				DROP TABLE #Temp_Salary_Muster_Report
			END
	
	
	CREATE table #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) not null,
	Income_Tax_ID numeric(18, 0) null,
	Is_Active	varchar(1) null
	
	)
	
	--ALTER index idx_1 on #Temp_report_Label (Row_ID)
	Create CLUSTERED INDEX ind_temp ON #Temp_report_Label(Row_ID)
	Create NONCLUSTERED INDEX ind_temp6 ON #Temp_report_Label(Label_Name)

		
	CREATE table #Temp_Salary_Muster_Report		
	(
		Emp_ID numeric(18, 0) Not Null,
		Cmp_ID numeric(18, 0) Not Null,
		Transaction_ID numeric(18, 0) Not Null,
		Month numeric(18, 0) Not Null,
		Year numeric(18, 0) Not Null,
		Label_Name varchar(200) Not Null,
		Amount numeric(18, 2) null,
		Value_String varchar(250) Not Null,
		INCOME_TAX_ID numeric(18, 0)  Default 0,
		Row_id numeric(18, 0) Null,
		M_AD_Flage char(1)
	)
	Create CLUSTERED INDEX ind_temp1	ON #Temp_Salary_Muster_Report(Row_id)
	Create NONCLUSTERED INDEX ind_temp2 ON #Temp_Salary_Muster_Report(Emp_ID)
	Create NONCLUSTERED INDEX ind_temp3 ON #Temp_Salary_Muster_Report(Cmp_ID)
	Create NONCLUSTERED INDEX ind_temp4 ON #Temp_Salary_Muster_Report(Label_Name)
	Create NONCLUSTERED INDEX ind_temp5 ON #Temp_Salary_Muster_Report(Value_String)
		
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null

		  Declare @Sal_St_Date   Datetime    
		  Declare @Sal_end_Date   Datetime  
		  
			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
				End    
		       
		 if isnull(@Sal_St_Date,'') = ''    
			begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			end     
		 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
			begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date    
			end     
		 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
			begin    
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_end_Date   
			End
		
		
	set @month = month(@To_Date)
	set @Year = Year(@To_Date)
	  
	EXEC Set_Salary_Register_Lable @Cmp_ID ,@month , @Year
	
	
	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else 
		begin
			Insert Into @Emp_Cons

			select I.Emp_Id from dbo.T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
		end
	
	
	DECLARE CUR_EMP CURSOR FOR
	SELECT sg.EMP_ID  FROM dbo.T0200_MONTHLY_SALARY SG WITH (NOLOCK) INNER JOIN
	T0080_EMP_MASTER E WITH (NOLOCK) ON sg.EMP_ID =e.EMP_ID 
	INNER JOIN /*	EMP_OTHER_DETAIL eod ON e.EMP_ID = eod.EMP_ID Inner join*/ @Emp_Cons ec on E.Emp_ID = Ec.Emp_ID 
	Inner join ( select dbo.T0095_Increment.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Branch_ID,Cat_ID,Payment_Mode from t0095_Increment WITH (NOLOCK) inner join 
									( select max(Increment_effective_Date) as For_Date , Emp_ID from t0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry
									on t0095_Increment.Emp_ID = Qry.Emp_ID and
									t0095_Increment.Increment_Effective_date   = Qry.For_date	
							where Cmp_ID = @Cmp_ID ) I_Q on 
					e.Emp_ID = I_Q.Emp_ID
	WHERE  sg.Cmp_ID = @Cmp_ID 
	AND Month(sg.Month_End_Date) = @MONTH AND Year(sg.Month_End_Date) = @YEAR And isnull(sg.is_FNF,0)=0
		--AND Payment_Mode LIKE isnull(@PAYEMENT,Payment_Mode)
	OPEN  CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID
	WHILE @@FETCH_STATUS = 0
		BEGIN
						
						SET @Allow_Name = ''
						SET @Row_id  = 0
						SET @Label_Name  = ''
						SET @Total_Allowance = 0
						SET @Is_Search = ''
						SET @Basic_salary = 0
						SET @Total_Allow = 0
						SET @Value_String = ''
						SET @Amount = 0 
						SET @OTher_Allow =0
						set @CO_Amount = 0
						SET @Total_Deduction =0
						SET @Other_Dedu =0
						SET @Loan =0
						SET @Advance =0
						SET @Net_Salary =0
						SET @PT =0
						SET @LWF =0
						SET @Revenue = 0
						set @P_Days = 0
						Set @A_Days=0
						set @Revenue_amt =0
						set @Lwf_amt  =0
						set @Act_Gross_salary = 0
						set @TDS=0
						set @Settl=0
						
						 
						
					--select @P_Days = Present_Days + Holiday_Days , @Basic_Salary = Salary_Amount from Salary_Generation where Emp_ID = @Emp_ID and Month = @Month and Year = @Year
					select @P_Days = isnull(Present_Days,0) ,@A_Days = isnull(Absent_Days,0),@TDS=isnull(M_IT_TAX,0), @Basic_Salary = Salary_Amount, @Act_Gross_salary = Actually_Gross_salary,@Settl = Settelement_Amount,@OTher_Allow = ISNULL(Other_Allow_Amount,0) 
					from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_date) = @Month and Year(Month_End_date) = @Year
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'P Days', @P_Days,'',2,'N')
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'A Days', @A_Days,'',3,'N')
					
				/*	INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Gross', @Act_Gross_salary,'',4)*/

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'Basic', @Basic_Salary,'',5,'I')
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Settl', @Settl,'',6,'I')
					
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Other', @OTher_Allow,'',7,'I')


					Declare Cur_Label cursor for 
					SELECT Label_Name ,Row_ID FROM dbo.#TEMP_REPORT_LABEL where Row_ID > 7
					open Cur_label
					fetch next from Cur_label into @Label_Name ,@Row_ID
					while @@fetch_Status = 0
						begin
							INSERT INTO dbo.#Temp_Salary_Muster_Report
							(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
							VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, @Label_Name, 0,'',@Row_ID,'')
							fetch next from Cur_label into @Label_Name,@Row_ID
						end
					close Cur_Label
					deallocate Cur_Label

					declare @AD_FLAG AS CHAR(1)
					set @Label_Name  = ''
					
						declare Cur_Allow   cursor for
						select Ad_Sort_Name ,M_Ad_Amount,t0050_ad_master.ad_FLAG from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID left outer join #Temp_Salary_Muster_Report
							on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I'
						and MAD.Emp_ID  = @Emp_ID
					open cur_allow
					fetch next from cur_allow  into @Allow_Name ,@Amount,@AD_FLAG
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name 

 							UPDATE    dbo.#Temp_Salary_Muster_Report
 							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
 												  Amount = @Amount, Value_String = '',M_aD_FLAGE=@AD_FLAG
 							where   Label_Name = @Allow_Name and Row_id = @row_Id                  
 									and Emp_ID = @Emp_ID  
							fetch next from cur_allow  into @Allow_Name,@Amount,@AD_FLAG
						end
					close cur_Allow
					deallocate Cur_Allow
					
					

						select @Total_Allowance = Allow_Amount   
							--@CO_Amount = isnull(Extra_Days_Amount,0)
						from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_date) = @Month and Year(Month_End_date) = @Year
					 	

						/*select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Oth A'		

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Other_Allow, Value_String = ''
						where   Label_Name = 'Oth A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/

						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'CO A'		

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @CO_Amount, Value_String = '',m_ad_FLAGE='I'
						where   Label_Name = 'CO A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gross'

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0), Value_String = '',M_AD_Flage='I'
						WHERE     (Label_Name = 'Gross') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID
								  
								  

						/*select @Amount = M_Ad_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id =@Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =2
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'PF Salary'	*/	
					
						
						/*UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'PF Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								*/
						set @Amount =0

						/*select @Amount = M_AD_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id = @Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =3 and M_Ad_Amount >0
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'ESIC Salary'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'ESIC Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/
								
					declare Cur_Dedu   cursor for
						select Ad_Sort_Name ,M_Ad_Amount,t0050_ad_master.ad_FLAG from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID 
							--left outer join #Temp_Salary_Muster_Report
							--on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and Month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=0
						and MAD.Emp_ID  = @Emp_ID
					open Cur_Dedu
					fetch next from cur_DEDU  into @Allow_Name ,@Amount,@ad_flag
					while @@fetch_status = 0
						begin
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
							
							UPDATE    dbo.#Temp_Salary_Muster_Report
							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount, 
												  Value_String = '',m_Ad_Flage=@ad_flag
							WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID)
									and Emp_ID = @Emp_ID
							fetch next from Cur_Dedu into @Allow_Name,@Amount,@ad_flag
						end
					close Cur_Dedu
					deallocate Cur_Dedu

						select @Total_Deduction = Total_Dedu_Amount ,@PT = PT_Amount ,@Loan =  ( Loan_Amount + Loan_Intrest_Amount ) 
								,@Advance =  Advance_Amount ,@Net_Salary = Net_Amount ,@Revenue_Amt =Revenue_amount,@LWF_Amt =LWF_Amount,@Other_Dedu=Other_Dedu_Amount
						from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_date) = @Month and Year(Month_End_date) = @Year
						--Select @Other_Dedu  = 0
						
					--	set @Loan = @Loan + @Advance

		--				select @Row_ID = Row_ID from Temp_report_label where Label_Name like 'Other Dedu'

		--				INSERT INTO Temp_Salary_Muster_Report


		--						   (Emp_ID, Company_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
		--				VALUES     (@Emp_ID, @Company_ID, @Transaction_ID, @Month, @Year, 'Other Dedu', @Other_Dedu,'',@Row_ID)
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'PT'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @PT, 
											  Value_String = '',m_ad_flage='D'
						WHERE     (Label_Name = 'PT') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Loan'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan, 
											  Value_String = '',m_ad_flage='D'
						WHERE     (Label_Name = 'Loan') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
								
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Advnc'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Advance, 
											  Value_String = '',m_ad_flage='D'
						WHERE     (Label_Name = 'Advnc') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						
						--if @Revenue_Amt >0 --Commented BY Falak 0n 30-MAR-2011
							--begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Revenue'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Revenue_Amt, 
													  Value_String = '',m_ad_flage='D'
								WHERE     (Label_Name = 'Revenue') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
							--end
						
						   	
						--if @LWF_amt > 0 --Commented BY Falak 0n 30-MAR-2011
							--BEGIN
								--select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'LWF'
								
								--UPDATE    dbo.#Temp_Salary_Muster_Report
								--SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @lwf_Amt, 
								--					  Value_String = '',m_ad_flage='D'
								--WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
								--		and Emp_ID = @Emp_ID
							--end	
						--Else
							--Begin
									select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'LWF'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @lwf_Amt, 
													  Value_String = '',m_ad_flage='D'
								WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
							
							--End						
						
						  		
					
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'TDS'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TDS, 
											  Value_String = '',m_ad_flage='D'
						WHERE     (Label_Name = 'TDS') AND (Row_id = @Row_ID) and Emp_ID = @Emp_ID
								
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Oth De'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Other_Dedu, 
											  Value_String = '',m_ad_flage='D'
						WHERE     (Label_Name = 'Oth De') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Dedu'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Total_Deduction, Value_String = '',m_ad_flage='D'
						WHERE     (Label_Name = 'Dedu') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID	
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary, 
											  Value_String = '',m_ad_flage='N'
						WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID
		END
	Close Cur_Emp
	Deallocate Cur_emp	
	
	Select Distinct Label_name,Row_ID,M_AD_Flage  from dbo.#Temp_Salary_Muster_Report  
	   --where dbo.#Temp_Salary_Muster_Report.Amount > 0
	   where M_AD_Flage <> '' --ADDED BY Falak 0n 30-MAR-2011
	 order by Row_ID
	  
	--DROP TABLE #Temp_report_Label
	--DROP TABLE #Temp_Salary_Muster_Report		
	
	RETURN




