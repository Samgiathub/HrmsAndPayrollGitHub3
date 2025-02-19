
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create PROCEDURE [dbo].[P0100_GRATUITY_CALCULATION_New_Temp]  
 @Gr_Id   numeric output,  
 @Cmp_ID   numeric ,  
 @Emp_ID   numeric,  
 @For_Date  Datetime,  
 @Gr_Paid_Date Datetime,  
 @Gr_Calc_Type varchar(10),  
 @Tran_Type  char(1),  
 @Gr_FNF   int = 0 ,
 @Gr_Year numeric
 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
   
 Declare @Last_Gr_Date Datetime  
 Declare @varLast_Gr_Date varchar(30)  
 Declare @Gr_Min_Year  int 
 Declare @Gr_Cal_Month int  
 Declare @Branch_Id numeric  
 Declare @Gr_Calc_Amount numeric (18,2) 
 Declare @Gr_Days numeric(5,1)  
 Declare @Gr_Percentage numeric(5,2)  
 Declare @Gr_Amount numeric  
 Declare @To_Date Datetime  
 Declare @Basic_Salary numeric(10,2)  
 Declare @Is_Gr_Yearly_Paid   int  
 Declare @Gen_ID numeric
 Declare @gr_out_of_days numeric(5,1)
 Declare @Is_Eligible tinyint --Hardik 13/08/2018 for Ashiana
 Declare @Gr_Min_P_Days numeric(5,1) -- Added By Deepali -13Dec21

 Set @Is_Eligible =0	 
 
 set @Gr_Calc_Amount = 0  
 set @Gr_Amount  = 0  
 set @Is_Gr_Yearly_Paid =0  
 set @gr_out_of_days  = 30
 set @Gr_Min_P_Days=0
 
 -- Added by rohit on 21102015
 Declare @increment_id as numeric(18,0)
 Declare @DA_Amount As numeric(18,2)
 set @DA_Amount =0
  -- Ended by rohit on 21102015
  
  DECLARE @Wages_Type as varchar(10)
  
 if upper(@Tran_type) ='I'  
  begin  
	 --select @Branch_ID =Branch_ID , @Basic_Salary =Basic_Salary ,@increment_id=I.Increment_Id  from T0095_Increment I inner join   
	--	( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  --Changed by Hardik 09/09/2014 for Same Date Increment
	--	where Increment_Effective_date <= @For_Date  
	--	and Cmp_ID = @Cmp_ID and Emp_ID =@Emp_ID   
	--	group by emp_ID  ) Qry on  
	--	I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id --Changed by Hardik 09/09/2014 for Same Date Increment
	--  Where Cmp_ID = @Cmp_ID and i.Emp_ID =@Emp_ID  
	 
	 SELECT	@BASIC_SALARY = BASIC_SALARY,
			@INCREMENT_ID = I.INCREMENT_ID,@WAGES_TYPE = I.WAGES_TYPE
	 FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN   
			( 
				SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID ,I2.EMP_ID 
				FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN 
						(
							SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID	
							FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN 
									T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.EMP_ID=E3.EMP_ID 
							WHERE	I3.INCREMENT_EFFECTIVE_DATE <=  @For_DATE AND 
									I3.CMP_ID = @CMP_ID AND UPPER(I3.INCREMENT_TYPE) NOT IN ('TRANSFER','DEPUTATION')	
							GROUP BY I3.EMP_ID 
						) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND I2.EMP_ID=I3.EMP_ID
				WHERE	UPPER(I2.INCREMENT_TYPE) NOT IN ('TRANSFER','DEPUTATION')  
				GROUP BY I2.EMP_ID  
			) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID 
	  WHERE CMP_ID = @CMP_ID AND I.EMP_ID =@EMP_ID  
	
	 SELECT	@BRANCH_ID = BRANCH_ID
	 FROM	T0095_INCREMENT I WITH (NOLOCK) INNER JOIN   
			( 
				SELECT	MAX(I2.INCREMENT_ID) AS INCREMENT_ID ,I2.EMP_ID 
				FROM	T0095_INCREMENT I2  WITH (NOLOCK) INNER JOIN 
						(
							SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID	
							FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN 
									T0080_EMP_MASTER E3 WITH (NOLOCK) ON I3.EMP_ID=E3.EMP_ID 
							WHERE	I3.INCREMENT_EFFECTIVE_DATE <=  @For_DATE AND 
									I3.CMP_ID = @CMP_ID 
							GROUP BY I3.EMP_ID 
						) I3 ON I2.INCREMENT_EFFECTIVE_DATE=I3.INCREMENT_EFFECTIVE_DATE AND I2.EMP_ID=I3.EMP_ID
				
				GROUP BY I2.EMP_ID  
			) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID 
	  WHERE CMP_ID = @CMP_ID AND I.EMP_ID =@EMP_ID  
	
	-- Added by rohit on 30112015 for Da Amount
	if exists(select 1 from tempdb.dbo.sysobjects where name ='#Temp_other_Allowance' and type='U')
    begin
		drop table #Temp_other_Allowance
    end
    
    Create Table #Temp_other_Allowance
     (
		Emp_ID NUMERIC ,     
		Ad_Id NUMERIC,
		For_Date Datetime,
		E_Ad_percentage Numeric(18,2),
		E_Ad_Amount numeric(18,2),
	)
	
    insert into #Temp_other_Allowance
    exec P_Emp_Revised_Allowance_Get @cmp_id,@For_Date,@Emp_ID 
    
    
     select @DA_Amount = isnull(sum(E_AD_AMOUNT),0) 
     from #Temp_other_Allowance ED 
	  inner join T0050_AD_MASTER AM WITH (NOLOCK) on Ed.AD_ID =Am.ad_id 
	  where Emp_id= @Emp_ID and ad_def_id =11  -- For Add Da Amount For calculate Dearness Allowance for Gratuity

	  set @Basic_Salary = isnull(@Basic_Salary,0) + isnull(@DA_Amount,0)
	
		-- Endded by rohit on 21102015	 
		  
	select @gr_Min_Year = gr_Min_Year,@Gr_Cal_Month=Isnull(Gr_ProRata_Cal,0) ,  
	   @Gr_Days = Gr_Days ,@Gr_Percentage = Gr_Percentage  
	   ,@Is_Gr_Yearly_Paid = isnull(Is_Gr_Yearly_Paid,0)
	   ,@Gr_Min_P_Days=ISNULL(@Gr_Min_P_Days,0)
	from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID =@Branch_ID  
	and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where  Cmp_ID = @Cmp_ID and Branch_ID =@Branch_ID)  
  
  
	set @Gr_Days = isnull(@Gr_Days,0)  
	set @Gr_Percentage = isnull(@Gr_Percentage,0)  
	set @gr_Min_Year = isnull(@gr_Min_Year,0)  
	
	--Hardik 14/08/2012 
	If @Gr_Cal_Month > 0
		Set @gr_out_of_days = @Gr_Cal_Month

	 --Added By Jimit 09082018
	 If @Wages_Type = 'Daily' 
		set @gr_out_of_days = 1
	--Ended	

	--DECLARE @Year_Only int --Hardik 16/01/2018
	DECLARE @Year_Only numeric(18,2) --Hardik 16/01/2018
	Set @Year_Only=0	 
	 
	if @gr_Min_Year =0  
	 return   
	   
	select @Last_Gr_Date = max(To_Date) From T0100_Gratuity g WITH (NOLOCK) Where g.Emp_ID=@Emp_ID  
	   
	if isnull(@Last_Gr_Date,'')=''  
	 begin  
	
	  select @Last_Gr_Date = Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end ,
		@varLast_Gr_Date =cast(day(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end)as varchar(2))  + '/' +  datename(mm,(Case when E.GroupJoiningDate Is null or E.GroupJoiningDate = '01-Jan-1900' then E.Date_Of_Join else E.GroupJoiningDate end )) + '/' + cast(year(dateadd(yy,-1,@For_Date)) as varchar(7))  
	  From T0080_Emp_Master e WITH (NOLOCK) Where emp_ID =@Emp_ID  
	 
	 end   
	else   
	 begin  
	  set @Last_Gr_Date  = dateadd(d,1,@Last_Gr_Date)  
	  set @varLast_Gr_Date = @Last_Gr_Date  
	 end  
	----------------------------Added By Deepali - Present days calculation- 13Dec2021 start
		   
		   if(@Gr_Min_P_Days>0)
		   begin
				Declare @Emp_Present_Days numeric(5,1)
				set @Emp_Present_Days = 0
				Select @Emp_Present_Days=SUM(isnull(Present_Days,0)) from T0200_MONTHLY_SALARY
				 WITH (NOLOCK) WHERE Emp_ID=@Emp_ID  and month_end_Date >=@Last_Gr_Date and Month_End_Date <=@To_Date 
				 if(@Emp_Present_Days<@Gr_Min_P_Days)
				 Return
			 
			 end
			-----------------------Added By Deepali - Present days calculation- 13Dec2021 end-----
	  
	  
	select @Gr_ID = isnull(max(Gr_ID),0) +1 from T0100_Gratuity WITH (NOLOCK)  
	
	 
	if @Is_Gr_Yearly_Paid =1   
		 begin  
			  set @Last_Gr_Date = cast(@varLast_Gr_Date as smalldatetime)  
			  set @To_Date = dateadd(d,-1,dateadd(yy,1,@Last_Gr_Date))  
		 end  
	else  
		 begin
				--print '334455'		
				set @Year_Only = DBO.F_GET_AGE (@Last_Gr_Date,@For_date,'N','N')	
											
				Declare @Month_Only as numeric
				--set @Month_Only = DBO.F_GET_MONTH (@Last_Gr_Date,@For_Date,'Y','N')
				select  @Month_Only = data from dbo.Split(DBO.F_GET_AGE (@Last_Gr_Date,@For_Date,'Y','N'),'.') where id=2
				--If DBO.F_GET_AGE (@Last_Gr_Date,@For_Date,'Y','N') >= 4.8 ---Condition Added by Hardik 16/01/2018 For Ashiana, As Employee has worked 4.7 years then it should not eligible for Gratuity, but if employee works 5.6 then he is eligible for 6 year gratuity
				--	Set @Is_Eligible = 1

				-- Above condition changed by Hardik 01/11/2019 for Ashiana, issue coming if employee works 4.10 so above condition going wrong as it will considered 4.80 so not eligible..
				If (exists(select 1 from dbo.Split(cast( DBO.F_GET_AGE (@Last_Gr_Date,@For_Date,'Y','N') as numeric(18,2)),'.') where id=1 and data >=4) And
					exists(select 1 from dbo.Split(cast( DBO.F_GET_AGE (@Last_Gr_Date,@For_Date,'Y','N') as numeric(18,2)),'.') where id=2 and data >=8))
					OR (exists(select 1 from dbo.Split(cast( DBO.F_GET_AGE (@Last_Gr_Date,@For_Date,'Y','N') as numeric(18,2)),'.') where id=1 and data >=5))
					Set @Is_Eligible=1
				
				IF @Month_Only > = 6
					Set @Year_Only = @Year_Only + 1
				else if @Month_Only < 6
					Set @Year_Only = @Year_Only
					
				--set @To_Date = dateadd(d,-1,dateadd(yy,@gr_Min_Year,@Last_Gr_Date))  
				set @To_Date = dateadd(yy,@Year_Only,@Last_Gr_Date)
				set @For_Date = @To_Date
				end  
	  
   --Added By Jimit 18122018  (case at WCl for death Employees it was not calculating)
	 DECLARE @Emp_Death tinyint
	  SET @Emp_Death = 0
	  SELECT @Emp_Death = Is_Death FROM T0100_LEFT_EMP  WITH (NOLOCK) WHERE Emp_Id=@Emp_ID	
	  --ended
	  print @Is_Eligible
	 If	((@To_Date <= @For_Date and 
		@Is_Eligible = 1 AND ---Condition Added by Hardik 16/01/2018 For Ashiana, As Employee has worked 4.7 years then it should not eligible for Gratuity, but if employee works 5.6 then he is eligible for 6 year gratuity
		not exists(select emp_id From T0100_GRATUITY WITH (NOLOCK) where Emp_ID= @Emp_ID and Cmp_ID = @Cmp_ID and   
		( (@Last_Gr_Date >= From_Date and @Last_Gr_Date <= To_Date) or   
		(@To_Date >= From_Date and  @To_Date <= To_Date) or   
		(From_Date >= @Last_Gr_Date and From_Date <= @To_Date) or  
		(To_Date >= @Last_Gr_Date and To_Date <= @To_Date) )) ) or @Emp_Death = 1)   
	 begin 
	    INSERT INTO T0100_GRATUITY  
			 (Gr_ID, Cmp_ID, Emp_Id, From_Date, To_Date, Paid_Date, Gr_Calc_Amount, Gr_Days, Gr_Percentage, Gr_Amount, Gr_Calc_Type, Gr_FNF)  
		VALUES     (@Gr_ID, @Cmp_ID, @Emp_Id, @Last_Gr_Date, @To_Date, @Gr_Paid_Date, @Gr_Calc_Amount, @Gr_Days, @Gr_Percentage, @Gr_Amount, @Gr_Calc_Type, @Gr_FNF)--  
		print'11111'
	END

	  Declare @Gr_D_ID numeric   
	  Declare @G_Detail table  
	   (  
		Gr_D_ID  numeric identity(1,1) not null,  
		GR_ID  numeric,  
		Emp_ID  numeric,  
		Cmp_ID  numeric ,  
		For_Date   datetime,  
		Gr_D_Calc_Amount Numeric(18,2)
	   )  
	    print'222222'
	
	  if @Gr_Calc_Type ='ProRata'   
			begin  
				select @Gr_D_ID =isnull(max(Gr_D_ID),0)    from T0110_GRATUITY_DETAIL WITH (NOLOCK)  
			  
				INSERT INTO @G_Detail  
					  (GR_ID, Emp_ID,Cmp_ID, For_Date, Gr_D_Calc_Amount)  
				select @GR_ID,@Emp_ID, @Cmp_ID, Month_end_Date, Salary_Amount   
				From T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE month_end_Date >=@Last_Gr_Date and Month_End_Date <=@To_Date and Emp_ID=@Emp_ID  
			  
				 INSERT INTO T0110_GRATUITY_DETAIL  
				 (Gr_D_ID, GR_ID, Cmp_ID, For_Date, Gr_D_Calc_Amount, Gr_D_Amount)  
				 select Gr_D_ID + @Gr_D_ID, @GR_ID, @Cmp_ID, For_Date, Gr_D_Calc_Amount, 0 from @G_Detail  
	  
				 if @Gr_Days > 0   
					begin
						  update T0110_GRATUITY_DETAIL  
						  set Gr_D_Amount = round(((Gr_D_Calc_Amount/12 * @gr_Min_Year) /@gr_out_of_days ) * @Gr_Days ,0)  
						  where Gr_ID =@Gr_ID   
		  
						  update T0100_GRATUITY  
						  set Gr_Calc_Amount = q.Gr_D_Calc_Amount/12 ,  
						   Gr_Amount = round(((q.Gr_D_Calc_Amount/12 * @gr_Min_Year) /@gr_out_of_days ) * @Gr_Days ,0)   
						  From T0100_GRATUITY g inner join (select Gr_Id,sum(Gr_D_Amount) Gr_D_Amount ,  
						  sum(Gr_D_Calc_Amount) Gr_D_Calc_Amount from T0110_GRATUITY_DETAIL WITH (NOLOCK) where Gr_ID =@Gr_ID group by GR_ID)  
						  q on g.Gr_ID = q.Gr_ID  
						 where g.Gr_ID=@gr_ID  
					  
					end   
				else  
					begin
			 
						  update T0110_GRATUITY_DETAIL  
						  set Gr_D_Amount = round( ( Gr_D_Calc_Amount/12 * @gr_Min_Year)  * @Gr_Percentage/100 ,0)  
						  where Gr_ID =@Gr_ID   
							
						  update T0100_GRATUITY  
						  set Gr_Calc_Amount =(q.Gr_D_Calc_Amount/12 * @gr_Min_Year) ,  
						   Gr_Amount = round( (q.Gr_D_Calc_Amount/12 * @gr_Min_Year)  * @Gr_Percentage/100 ,0)   
						  From T0100_GRATUITY g inner join (select Gr_Id,sum(Gr_D_Amount) Gr_D_Amount ,  
						   sum(Gr_D_Calc_Amount) Gr_D_Calc_Amount from T0110_GRATUITY_DETAIL WITH (NOLOCK) where Gr_ID =@Gr_ID group by GR_ID)  
						   q on g.Gr_ID = q.Gr_ID  
						  where g.Gr_ID=@gr_ID  
					  
					end  
		   end   
	  else  
	 print'33333'
	
		   begin  
		  Declare @Temp_Date datetime   
			set @Temp_Date = dateadd(d,-1,dateadd(yy,1,@Last_Gr_Date))  
			 
			while @Temp_Date <=@To_Date  
				  begin
					   select @Gr_D_ID =isnull(max(Gr_D_ID),0)    from T0110_GRATUITY_DETAIL WITH (NOLOCK)   
						 
					   delete from @G_Detail  
						 
					   INSERT INTO @G_Detail  
							  (GR_ID,Emp_ID, Cmp_ID, For_Date, Gr_D_Calc_Amount)  
					   select @GR_ID, @Emp_ID,@Cmp_ID, @Temp_Date, @Basic_Salary   
			  
			  
					   INSERT INTO T0110_GRATUITY_DETAIL  
							  (Gr_D_ID, GR_ID, Cmp_ID, For_Date, Gr_D_Calc_Amount, Gr_D_Amount)  
					   select Gr_D_ID + @Gr_D_ID, @GR_ID, @Cmp_ID, For_Date, Gr_D_Calc_Amount, 0 from @G_Detail  
			  
					   set @Temp_Date = dateadd(yy,1,@Temp_Date)  
				  end  
				 
			
			  if @Gr_Days > 0   
					begin  
						 update T0110_GRATUITY_DETAIL  
						 set Gr_D_Amount = round((Gr_D_Calc_Amount /@gr_out_of_days ) * @Gr_Days ,0)  
						 where Gr_ID =@Gr_ID   
						 update T0100_GRATUITY  
						 set Gr_Calc_Amount = q.Gr_D_Calc_Amount ,  
						  Gr_Amount = round((q.Gr_D_Calc_Amount /@gr_out_of_days ) * @Gr_Days ,0)   
						 From T0100_GRATUITY g inner join (select Gr_Id,sum(Gr_D_Amount) Gr_D_Amount ,  
						  sum(Gr_D_Calc_Amount) Gr_D_Calc_Amount from T0110_GRATUITY_DETAIL WITH (NOLOCK) where Gr_ID =@Gr_ID group by GR_ID)  
						  q on g.Gr_ID = q.Gr_ID  
						 where g.Gr_ID=@gr_ID

						-- select * from T0110_GRATUITY_DETAIL where  Gr_ID =@Gr_ID
						 --select * from T0100_GRATUITY where  Gr_ID =@Gr_ID
						
							 
					end   
			   else  
					begin  
						 update T0110_GRATUITY_DETAIL  
						 set Gr_D_Amount = round( Gr_D_Calc_Amount * @Gr_Percentage/100 ,0)  
						 where Gr_ID =@Gr_ID   
						   
						 update T0100_GRATUITY  
						 set Gr_Calc_Amount =q.Gr_D_Calc_Amount ,  
						  Gr_Amount = round( q.Gr_D_Calc_Amount * @Gr_Percentage/100 ,0)   
						 From T0100_GRATUITY g inner join (select Gr_Id,sum(Gr_D_Amount) Gr_D_Amount ,  
						  sum(Gr_D_Calc_Amount) Gr_D_Calc_Amount from T0110_GRATUITY_DETAIL WITH (NOLOCK) where Gr_ID =@Gr_ID group by GR_ID)  
						  q on g.Gr_ID = q.Gr_ID  
						 where g.Gr_ID=@gr_ID 
					end  
		   end   
	 end  
  --end  
 else  
	  begin  
		   Delete from T0110_GRATUITY_DETAIL WHERE GR_iD =@GR_ID   
		   DELETE FROM T0100_GRATUITY   WHERE GR_ID =@GR_ID  
	  end  
	
 RETURN  
  
  


