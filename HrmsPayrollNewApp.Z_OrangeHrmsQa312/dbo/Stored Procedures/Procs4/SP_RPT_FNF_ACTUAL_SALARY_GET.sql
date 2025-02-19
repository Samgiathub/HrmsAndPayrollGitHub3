
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_FNF_ACTUAL_SALARY_GET]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@PBranch_ID	varchar(MAX) = '0'
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null

	If Isnull(@Emp_Id,0) > 0
		BEGIN
			Declare @Join_Date datetime
			Select @Join_Date =  Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_Id = @Emp_Id
			
			If @Join_Date > @To_Date
				Set @To_Date = @Join_Date	
		END


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
		 if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
		   Begin	
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN 
								( SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
								  FROM	T0095_INCREMENT I3 WITH (NOLOCK)
								  WHERE	I3.Increment_Effective_Date <= @To_Date GROUP BY I3.Emp_ID
								) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
						WHERE	I2.Cmp_ID = @Cmp_Id GROUP BY I2.Emp_ID
					) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID	
					--( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
					--where Increment_Effective_date <= @To_Date
					--and Cmp_ID = @Cmp_ID
					--group by emp_ID  ) Qry on
					--I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
		   end
		  else
		   Begin
		    Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
						FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN 
								( SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
								  FROM	T0095_INCREMENT I3 WITH (NOLOCK)
								  WHERE	I3.Increment_Effective_Date <= @To_Date GROUP BY I3.Emp_ID
								) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
						WHERE	I2.Cmp_ID = @Cmp_Id GROUP BY I2.Emp_ID
					) I2 ON I.Emp_ID=I2.Emp_ID AND I.Increment_ID=I2.INCREMENT_ID	
					--( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
					--where Increment_Effective_date <= @To_Date
					--and Cmp_ID = @Cmp_ID
					--group by emp_ID  ) Qry on
					--I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)
		   end 
		end
	
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
	 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1    
		begin    
		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
		   set @From_Date = @Sal_St_Date
		   Set @To_Date = @Sal_end_Date   
		End 
	
	CREATE table #Actual_Salary 
		(
			Emp_ID					numeric,
			Cmp_ID					numeric,
			AD_ID					numeric,
			E_AD_Amount				numeric(18,2),
			E_AD_Actual_Amount		numeric(18,2),
			For_Date				Datetime,
			E_AD_Flag				char(1),
			AD_Description			varchar(100)
		)	 
		

		insert into #Actual_Salary (Emp_ID,Cmp_ID,AD_ID,E_AD_Amount,E_AD_actual_Amount,For_Date,E_AD_flag,AD_Description)
		
		Select ms.Emp_ID,ms.Cmp_ID,null,I_Q.Basic_Salary,0,date_of_join,'I','Basic Salary'
		From T0200_Monthly_Salary MS WITH (NOLOCK) Inner join 
		T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID inner join 
			T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID INNER JOIN 
			T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID  inner join
			@Emp_Cons EC on MS.Emp_ID = EC.Emp_ID	--Ankit 23112015

		WHERE E.Cmp_ID = @Cmp_Id and isnull(is_FNF,0) =1
			--and Month_St_Date >=@From_Date and Month_St_Date <=@To_Date
			  and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
			  
		-- Added by Gadriwala Muslim 27042015 - Start	  
		Insert into #Actual_Salary(Emp_ID,Cmp_ID,AD_ID,E_AD_Amount,E_AD_Actual_Amount,For_Date,E_AD_Flag,AD_Description)
		select  Ms.Emp_ID,Ms.Cmp_ID,Null,isnull(Ms.FNF_Subsidy_Recover_Amount,0),0,date_of_join,'D','Subsidy Recover Amount' from T0200_MONTHLY_SALARY MS WITH (NOLOCK) Inner join
			T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID Inner join
			T0100_LEFT_EMP LE WITH (NOLOCK) on MS.Emp_ID = LE.Emp_ID inner join
			@Emp_Cons EC on MS.Emp_ID = EC.Emp_ID
			where Ms.Cmp_ID = @Cmp_ID and isnull(is_FNF,0) =1 
			  and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		  
		-- Added by Gadriwala Muslim 27042015 - End
		-- Added by rohit for get letest rate on 16052016
		CREATE TABLE #Tbl_Get_AD
	(
		Emp_ID numeric(18,0),
		Ad_ID numeric(18,0),
		for_date datetime,
		E_Ad_Percentage numeric(18,5),
		E_Ad_Amount numeric(18,2)
		
	)
	
	INSERT INTO #Tbl_Get_AD
		Exec P_Emp_Revised_Allowance_Get @Cmp_ID,@To_Date,@constraint
	
		
		--insert into #Actual_Salary (Emp_ID,Cmp_ID,AD_ID,E_AD_Amount,E_AD_actual_Amount,For_Date,E_AD_flag)
		
		--Select ms.Emp_ID,ms.Cmp_ID,eed.AD_ID,E_AD_Amount,
		--	case when E_AD_percentage >0 then
		--		E_AD_Percentage 
		--	else
		--		E_AD_Amount
		--	end
		--,For_Date,E_AD_Flag  
		--From T0200_Monthly_Salary MS Inner join 
		--T0080_EMP_MASTER E on MS.emp_ID = E.emp_ID inner join 
		--	T0100_LEFT_EMP LE ON E.EMP_ID = LE.EMP_ID INNER JOIN 
		--	T0095_Increment I_Q on Ms.Increment_ID = I_Q.Increment_ID 
		--	inner join T0100_EMP_EARN_dEDUCTION EED ON 
		--	I_Q.INCREMENT_ID = EED.INCREMENT_ID  inner join
		--	@Emp_Cons EC on MS.Emp_ID = EC.Emp_ID	--Ankit 23112015

		--WHERE E.Cmp_ID = @Cmp_Id and isnull(is_FNF,0) =1
		----	and Month_St_Date >=@From_Date and Month_St_Date <=@To_Date
		-- and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		-- and eed.E_AD_AMOUNT > 0	--Ankit 23112015
		
			insert into #Actual_Salary (Emp_ID,Cmp_ID,AD_ID,E_AD_Amount,E_AD_actual_Amount,For_Date,E_AD_flag)
		
		Select ms.Emp_ID,ms.Cmp_ID,eed.AD_ID,E_AD_Amount,
			case when E_AD_percentage >0 then
				E_AD_Percentage 
			else
				E_AD_Amount
			end
		,For_Date,Am.ad_flag  
		From T0200_Monthly_Salary MS WITH (NOLOCK) Inner join 
		T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID inner join 
			T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID INNER JOIN 
			T0095_Increment I_Q WITH (NOLOCK) on Ms.Increment_ID = I_Q.Increment_ID 
			inner join #Tbl_Get_AD EED ON 
			I_Q.emp_id = EED.emp_id  inner join
			@Emp_Cons EC on MS.Emp_ID = EC.Emp_ID	--Ankit 23112015
			inner join t0050_Ad_master Am WITH (NOLOCK) on eed.ad_id = Am.ad_id

		WHERE E.Cmp_ID = @Cmp_Id and isnull(is_FNF,0) =1
		--	and Month_St_Date >=@From_Date and Month_St_Date <=@To_Date
		 and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date)
		 and eed.E_AD_AMOUNT > 0	--Ankit 23112015
		 and Am.Hide_In_Reports = 0   --added by Jaina 22-05-2017
		 -- ended by rohit on 16052016
		 
		Select EED.* ,Emp_Code,Emp_Full_Name,AD_NAME,AD_LEVEL,
		case when isnull(AM.AD_NAME,'') = '' 
		THEN isnull(AM.AD_NOT_EFFECT_SALARY,0) 
		ELSE AM.AD_NOT_EFFECT_SALARY 
		END AS AD_NOT_EFFECT_SALARY
		From T0080_EMP_MASTER E WITH (NOLOCK) 
		inner join T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID  
		inner join #Actual_Salary EED ON E.Emp_ID = EED.Emp_ID left outer JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON EED.AD_ID =AM.AD_ID
		WHERE E.Cmp_ID = @Cmp_Id 
			and EED.E_AD_Amount > 0	--Ankit 23112015
			--and EED.E_AD_Flag = 'I' --Added by Jaina 29-06-2017
			And (Isnull(EEd.AD_Description,0) <>'' or Isnull(AM.AD_PART_OF_CTC,0)=1)  ---Hardik 16/09/2017
		Order by AD_LEVEL
			
		
		
	RETURN


