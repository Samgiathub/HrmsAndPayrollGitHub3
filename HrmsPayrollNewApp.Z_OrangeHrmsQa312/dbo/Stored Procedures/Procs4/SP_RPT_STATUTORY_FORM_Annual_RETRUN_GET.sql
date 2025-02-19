

-- =============================================
-- Author:		<Falak,OrnageTechnolab>
-- ALTER date: <29-SEP-2010>
-- Description:	<Report >
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_STATUTORY_FORM_Annual_RETRUN_GET]
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
	,@Constraint 	varchar(MAX)
	,@SEGMENT_ID		NUMERIC = 0     --added jimit 24122015
	,@Vertical_Id		NUMERIC = 0		--added jimit 24122015
	,@SubVertical_Id	NUMERIC = 0		--added jimit 24122015
	,@SubBranch_ID		NUMERIC = 0		--added jimit 24122015
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
	  
	  
	CREATE TABLE #Emp_Cons	  -- Ankit 10092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_ID 

			
	 --Declare #Emp_Cons Table    
	 --(    
	 -- Emp_ID numeric    
	 --)    
	     
	 --if @Constraint <> ''    
	 -- begin    
	 --  Insert Into #Emp_Cons    
	 --  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')     
	 -- end    
	 --else    
	 -- begin    
	       
	       
	 --  Insert Into #Emp_Cons    
	    
	 --  select I.Emp_Id from T0095_Increment I inner join     
		-- ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment    
		-- where Increment_Effective_date <= @To_Date    
		-- and Cmp_ID = @Cmp_ID    
		-- group by emp_ID  ) Qry on    
		-- I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date     
	           
	 --  Where Cmp_ID = @Cmp_ID     
	 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))    
	 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)    
	 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)    
	 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))    
	 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))    
	 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))    
	 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)     
	 --  and I.Emp_ID in     
		--( select Emp_Id from    
		--(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry    
		--where cmp_ID = @Cmp_ID   and      
		--(( @From_Date  >= join_Date  and  @From_Date <= left_date )     
		--or ( @To_Date  >= join_Date  and @To_Date <= left_date )    
		--or Left_date is null and @To_Date >= Join_Date)    
		--or @To_Date >= left_date  and  @From_Date <= left_date )     
	       
	 -- end  
    
    
    
    Declare @Annual_Report table
    ( 
		cmp_id numeric(18,0),
		cnt_skilled_D numeric(18,0),
		cnt_skilled_C numeric(18,0),
		cnt_unskilled_D numeric(18,0),
		cnt_unskilled_C numeric(18,0),
		cnt_semiskilled_D numeric(18,0),
		cnt_semiskilled_C numeric(18,0),
		cnt_Direct_M numeric(18,0),
		cnt_Direct_F numeric(18,0),
		cnt_Direct_T numeric(18,0),
		cnt_Contract_M numeric(18,0),
		cnt_Contract_F numeric(18,0),
		cnt_Contract_T numeric(18,0),
		tot_working_day numeric(18,0),
		tot_present_day numeric(18,0),
		tot_wages_paid numeric(18,0),
		tot_wages_paid_M numeric(18,0),
		tot_wages_paid_F numeric(18,0),
		tot_bonus	numeric(18,2),
		bonus_per	numeric(18,2),
		cnt_emp_bonus numeric(18,0),
		
		year_skilled_D numeric(18,0),
		year_skilled_C numeric(18,0),
		year_unskilled_D numeric(18,0),
		year_unskilled_C numeric(18,0),
		year_semiskilled_D numeric(18,0),
		year_semiskilled_C numeric(18,0),
		year_Direct_M numeric(18,0),
		year_Direct_F numeric(18,0),
		year_Direct_T numeric(18,0),
		year_Contract_M numeric(18,0),
		year_Contract_F numeric(18,0),
		year_Contract_T numeric(18,0)
    )
    
    
    Insert @Annual_Report (cmp_id ,cnt_skilled_D ,cnt_skilled_C  ,cnt_unskilled_D,cnt_unskilled_C ,cnt_semiskilled_D,cnt_semiskilled_C,cnt_Direct_M ,cnt_Direct_F ,cnt_Direct_T ,cnt_Contract_M ,
		  cnt_Contract_F ,cnt_Contract_T ,tot_working_day,tot_present_day  ,tot_wages_paid ,tot_wages_paid_M ,tot_wages_paid_F )
			values (@Cmp_ID ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	
	declare @Max_Month as numeric(18,0)
	set @Max_Month = (select MAX(Month) as max_month from (
	select MAX(cnt) as max_cnt from (
	select MONTH(Month_End_Date) as month, YEAR(Month_End_Date) as year, COUNT(emp_id) as cnt 
	from T0200_MONTHLY_SALARY WITH (NOLOCK)
	where Month_End_Date between @From_Date and @To_Date and Cmp_ID=@Cmp_ID
	group by Month_End_Date) qr )qr1 inner join
	(select MONTH(Month_End_Date) as month, YEAR(Month_End_Date) as year, COUNT(emp_id) as cnt 
	from T0200_MONTHLY_SALARY WITH (NOLOCK)
	where Month_End_Date between @From_Date and @To_Date and Cmp_ID=@Cmp_ID
	group by Month_End_Date) qr2 on qr1.max_cnt = qr2.cnt)
	
	
	Update @Annual_Report 
		set tot_present_day = isnull(qry.PD,0),
			tot_wages_paid = isnull(qry.Namt,0)
			from @Annual_Report T,
			(select  SUM (MS.Present_Days ) as PD , SUM (MS.Net_Amount ) as NAMT
			from T0200_MONTHLY_SALARY MS WITH (NOLOCK) inner join T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = MS.Emp_ID
				 INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			where MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and MS.Cmp_ID = @Cmp_ID ) as qry
			where T.Cmp_ID = @Cmp_ID  
	
	Update @Annual_Report 
		set tot_wages_paid_M  = isnull(qry.Namt,0)
			from @Annual_Report T,
			(select  SUM (MS.Net_Amount ) as NAMT
			from T0200_MONTHLY_SALARY MS WITH (NOLOCK) inner join T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = MS.Emp_ID
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			where MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and E.Gender = 'M' and MS.Cmp_ID = @Cmp_ID  ) as qry
			where T.Cmp_ID = @Cmp_ID  
	
	Update @Annual_Report 
		set tot_wages_paid_F  = isnull(qry.Namt,0)
			from @Annual_Report T,
			(select  SUM (MS.Net_Amount ) as NAMT
			from T0200_MONTHLY_SALARY MS WITH (NOLOCK) inner join T0080_EMP_MASTER E WITH (NOLOCK) on E.Emp_ID = MS.Emp_ID
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			where MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and E.Gender = 'F' and MS.Cmp_ID = @Cmp_ID ) as qry
			where T.Cmp_ID = @Cmp_ID
	
	
	Declare @Cmp_Weekoff as varchar(20)
	Declare @Tot_Working_Days numeric(18,0)
	
	select @Cmp_Weekoff = Default_Holiday  from T0010_COMPANY_MASTER WITH (NOLOCK) where Cmp_Id = @Cmp_ID 
	
		
	Update @Annual_Report 
		set tot_working_day = isnull(qry.cnt_WD,0)
		from @Annual_Report as T,
		(SELECT Count(Date) as Cnt_WD
		FROM ( Select dateadd(dd,number,@From_Date )  as Date
			from master.dbo.spt_values 
			where master.dbo.spt_values.type='p' AND dateadd(dd,number,@From_Date)<=(@To_Date )
		   ) AS T  WHERE Datename(weekday, T.Date) NOT IN (isnull(@Cmp_Weekoff,'Sunday')) ) qry
		   where T.cmp_id = @Cmp_ID 
	
	
	Update @Annual_Report 
		set cnt_Direct_M = isnull(qry.Male,0) ,
			cnt_Direct_F = isnull(qry.Female,0) ,
			cnt_Direct_T = isnull(qry.Tot ,0)
		from @Annual_Report T,
		(select   count(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) as Male,COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) as Female,
			Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id			
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.[Type_ID] 
			inner join T0200_MONTHLY_SALARY S WITH (NOLOCK) on S.Cmp_ID=E.Cmp_ID AND S.Emp_ID=E.Emp_ID
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and T.Type_Name like 'Per%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = 12 
					and E.Emp_Left <> 'Y') as qry
		where T.cmp_id = @Cmp_ID
		
		Update @Annual_Report 
		set year_Direct_M = isnull(qry.Male,0) ,
			year_Direct_F = isnull(qry.Female,0) ,
			year_Direct_T = isnull(qry.Tot ,0)
		from @Annual_Report T,
		(select   count(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) as Male,COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) as Female,
			Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id			
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.[Type_ID] 
			inner join T0200_MONTHLY_SALARY S WITH (NOLOCK) on S.Cmp_ID=E.Cmp_ID AND S.Emp_ID=E.Emp_ID
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and T.Type_Name like 'Per%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = @Max_Month
			) as qry
		where T.cmp_id = @Cmp_ID 
	
	
	Update @Annual_Report 
		set cnt_Contract_M  = isnull(qry.Male,0) ,
			cnt_Contract_F  = isnull(qry.Female,0) ,
			cnt_Contract_T  = isnull(qry.Tot,0) 
		from @Annual_Report T,
		(select   count(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) as Male,COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) as Female,
			Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID 
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID			
			WHERE E.Cmp_ID = @Cmp_ID  and T.Type_Name like 'Contr%' and E.Emp_Left <> 'Y') as qry
		where T.cmp_id = @Cmp_ID
		
	Update @Annual_Report 
		set year_Contract_M  = isnull(qry.Male,0) ,
			year_Contract_F  = isnull(qry.Female,0) ,
			year_Contract_T  = isnull(qry.Tot,0) 
		from @Annual_Report T,
		(select   count(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) as Male,COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) as Female,
			Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID 
			inner join T0200_MONTHLY_SALARY S WITH (NOLOCK) on S.Cmp_ID=E.Cmp_ID AND S.Emp_ID=E.Emp_ID
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID			
			WHERE E.Cmp_ID = @Cmp_ID  and T.Type_Name like 'Contr%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = @Max_Month) as qry
		where T.cmp_id = @Cmp_ID
	

	 
	Update @Annual_Report 
		set cnt_unskilled_D   = isnull(qry.Tot ,0)
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID  			
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'UnSki%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = 12
				and E.Emp_Left <> 'Y' and T.Type_Name like 'Per%') as qry
		where T.cmp_id = @Cmp_ID 
		
		Update @Annual_Report 
		set year_unskilled_D   = isnull(qry.Tot ,0)
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID  			
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'UnSki%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = @Max_Month
				and T.Type_Name like 'Per%') as qry
		where T.cmp_id = @Cmp_ID 
	
	
	Update @Annual_Report 
		set cnt_unskilled_C   = isnull(qry.Tot ,0)
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID
			--inner join T0040_Skill_MASTER SM on SM.Skill_ID = S.Skill_ID 			
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID 
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'UnSki%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = 12
			and E.Emp_Left <> 'Y' and T.Type_Name like 'Contr%' ) as qry
		where T.cmp_id = @Cmp_ID
		
	Update @Annual_Report 
		set year_unskilled_C   = isnull(qry.Tot ,0)
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID
			--inner join T0040_Skill_MASTER SM on SM.Skill_ID = S.Skill_ID 			
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID 
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'UnSki%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = @Max_Month
			and T.Type_Name like 'Contr%' ) as qry
		where T.cmp_id = @Cmp_ID
	
	
	Update @Annual_Report 
		set cnt_semiskilled_D  = isnull(qry.Tot,0)
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			--inner join T0040_Skill_MASTER SM on SM.Skill_ID = S.Skill_ID
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID			
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID 			
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'Semi%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = 12
			and E.Emp_Left <> 'Y' and T.Type_Name like 'Per%' ) as qry
		where T.cmp_id = @Cmp_ID
		
	Update @Annual_Report 
		set year_semiskilled_D  = isnull(qry.Tot,0)
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			--inner join T0040_Skill_MASTER SM on SM.Skill_ID = S.Skill_ID
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID			
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID 			
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'Semi%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = @Max_Month
			 and T.Type_Name like 'Per%' ) as qry
		where T.cmp_id = @Cmp_ID
		
	
	Update @Annual_Report 
		set cnt_semiskilled_C  = isnull(qry.Tot ,0) 			
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			--inner join T0040_Skill_MASTER SM on SM.Skill_ID = S.Skill_ID 			
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID 
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'Semi%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = 12
				and E.emp_left <> 'Y' and T.Type_Name like 'Contr%') as qry
		where T.cmp_id = @Cmp_ID
		
	Update @Annual_Report 
		set year_semiskilled_C  = isnull(qry.Tot ,0) 			
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			--inner join T0040_Skill_MASTER SM on SM.Skill_ID = S.Skill_ID 			
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID 
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'Semi%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = @Max_Month
				and T.Type_Name like 'Contr%') as qry
		where T.cmp_id = @Cmp_ID
	
	
	Update @Annual_Report 
		set cnt_skilled_D   = isnull(qry.Tot ,0)
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			--inner join T0040_Skill_MASTER SM on SM.Skill_ID = S.Skill_ID
			--inner join T0040_TYPE_MASTER T 	on T.Type_ID = E.Type_ID 
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			--inner join T0040_Skill_MASTER SM on SM.Skill_ID = S.Skill_ID 			
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID 		
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'Ski%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = 12
				and E.Emp_Left <> 'Y' and T.Type_Name like 'Per%') as qry
		where T.cmp_id = @Cmp_ID
		
	Update @Annual_Report 
		set year_skilled_D   = isnull(qry.Tot ,0)
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) on T.Type_ID = E.Type_ID 		
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'Ski%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = @Max_Month
				and T.Type_Name like 'Per%') as qry
		where T.cmp_id = @Cmp_ID
	
	Update @Annual_Report 
		set cnt_skilled_C   = isnull(qry.Tot ,0)
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			--inner join T0040_Skill_MASTER SM on SM.Skill_ID = S.Skill_ID
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID
			inner join T0040_TYPE_MASTER T WITH (NOLOCK) 	on T.Type_ID = E.Type_ID 		
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'Ski%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = 12
				and e.Emp_Left <> 'Y' and T.Type_Name like 'Contr%') as qry
		where T.cmp_id = @Cmp_ID
		
	Update @Annual_Report 
		set year_skilled_C   = isnull(qry.Tot ,0)
		from @Annual_Report T,
		(select Count(E.Emp_Id) as Tot from T0080_Emp_Master As E WITH (NOLOCK) INNER JOIN T0010_Company_Master As c WITH (NOLOCK) ON C.Cmp_Id = E.Cmp_Id
			--inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			--inner join T0040_Skill_MASTER SM on SM.Skill_ID = S.Skill_ID
			inner join T0040_SkillType_Master SM WITH (NOLOCK) on SM.SkillType_ID = E.SkillType_ID
			inner join T0040_TYPE_MASTER T WITH (NOLOCK)	on T.Type_ID = E.Type_ID 		
			inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Cmp_ID=E.Cmp_ID AND MS.Emp_ID=E.Emp_ID --Added by Nimesh 07-Jul-2015
			INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID
			WHERE E.Cmp_ID = @Cmp_ID  and SM.Skill_Name like 'Ski%' AND Year(Month_St_Date)= YEAR(@From_Date) AND MONTH(Month_St_Date) = @Max_Month
				and T.Type_Name like 'Contr%') as qry
		where T.cmp_id = @Cmp_ID	
		
	DECLARE @TOTAL_DEDUCTION_Allow NUMERIC(18,2);
	DECLARE @TOTAL_DEDUCTION_Salay NUMERIC(18,2);
	DECLARE @TOTAL_DEDUCTION NUMERIC(18,2);
	
	Select	@TOTAL_DEDUCTION_Allow = (SUM(MAD.M_AD_Amount))
	FROM	T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.CMP_ID=AD.CMP_ID AND MAD.AD_ID=AD.AD_ID
			--INNER JOIN T0200_MONTHLY_SALARY MS ON MAD.Cmp_ID=MS.Cmp_ID AND MAD.Emp_ID=MS.Emp_ID AND MS.Sal_Tran_ID=MAD.Sal_Tran_ID
	WHERE	M_AD_FLAG='D' AND AD_DEF_ID IN (2,3) and MAD.To_date between @From_Date and @To_Date
			and MAD.cmp_id = @Cmp_ID
			
	select @TOTAL_DEDUCTION_Salay = (sum(PT_Amount) + sum(LWF_Amount))
	from T0200_MONTHLY_SALARY MS WITH (NOLOCK)
	where MS.Cmp_ID = @Cmp_ID and MS.Month_End_Date between @From_Date and @To_Date
	
	set @TOTAL_DEDUCTION = @TOTAL_DEDUCTION_Allow + @TOTAL_DEDUCTION_Salay
			
	update	@Annual_Report
	set		tot_bonus = B_Amount,
			bonus_per = B_Per,
			cnt_emp_bonus = B_Emp_id
	from	@Annual_Report T,
			(	select  sum(B.Bonus_Amount) as B_Amount,count(B.Emp_ID) as B_Emp_id,max(B.Bonus_Percentage) as B_Per
				from	T0180_BONUS as B WITH (NOLOCK)
				WHERE	B.Cmp_ID = @Cmp_ID and Bonus_Amount > 0 and B.To_Date between @From_Date and @To_Date
			)as qry
	where	T.cmp_id = @Cmp_ID
	
	/*Added by Nimesh 07-Jul-2015
	For Contract Branch
	*/			
		Create Table #ContractBranch(
			Branch_ID Numeric(18,0) NOT NULL,
			BRANCH_CODE varchar(50) NOT NULL,
			BRANCH_NAME varchar(100) NOT NULL,
			Branch_Address varchar(500),
			Branch_City varchar(100),
			Total_Days_Labour Numeric(18,2),
			Total_ManDays_Labour Numeric(18,2),
			Total_Direct_Labour Numeric(18,2),
			Total_ManDirect_Labour Numeric(18,2),
			Duration_Of_Contract Numeric(18,0),
			Avg_Labour_Worked Numeric(18,2),
			Det_Working_Hours Numeric(18,2),
			Det_Overtime_Hours Numeric(18,2),
			Det_Weekly_Holiday Numeric(18,2),
			Det_Spread_Over Numeric(18,2),
			Det_Weekly_Holiday_IsPaid bit,
			Half_Year_Total_Male Numeric(18,2),
			Half_Year_Total_Female Numeric(18,2),
			Wages_Paid Numeric(18,2),
			Wages_Ded Numeric(18,2),
			Prov_Canteen bit,
			Prov_RestRoom bit,
			Prov_Water bit,
			Prov_Creches bit,
			Prov_FirstAid bit	
		)
		Insert	Into #ContractBranch (Branch_ID,BRANCH_CODE,BRANCH_NAME,Branch_Address,Branch_City)
		SELECT	Branch_ID,BRANCH_CODE,BRANCH_NAME,Branch_Address,Branch_City  
		FROM	T0030_BRANCH_MASTER WITH (NOLOCK)
		WHERE	Is_Contractor_Branch= 1 AND Cmp_ID=@Cmp_ID
		
		--DECLARE @Contract_Branch_ID Numeric(18,2);
		--DECLARE curContract Cursor FOR
		--SELECT Branch_ID FROM #ContractBranch
		--OPEN curContract
		--FETCH NEXT FROM curContract INTO @Contract_Branch_ID
		--WHILE @@FETCH_STATUS = 0
		--BEGIN
			
			
		--	FETCH NEXT FROM curContract INTO @Contract_Branch_ID
		--END
		
		--CLOSE curContract;
		--DEALLOCATE curContract;
	/*
	END
	*/

		
	Select A.*,C.Cmp_Name ,C.Cmp_Address ,C.Cmp_City ,C.Cmp_PinCode,C.From_Date,@From_Date as From_Date_1,year(@To_Date) as To_Date 
			,C.Nature_of_Business,C.Designation_Manager_Form_16,C.CIT_Address,C.CIT_City,C.CIT_Pin	--Ankit 24012014
			,CDD.Director_Name,CDD.Director_Address, @TOTAL_DEDUCTION AS TOTAL_DEDUCTION , c.cmp_State_Name,C.Registration_No,C.License_No,C.DATE_OF_establishment --Company State Name Added By Ramiz on 01/03/2017
	From @Annual_Report A inner join T0010_COMPANY_MASTER C WITH (NOLOCK) on A.cmp_id = C.Cmp_Id 
		 LEFT OUTER JOIN T0010_COMPANY_DIRECTOR_DETAIL CDD WITH (NOLOCK) ON C.Cmp_Id=CDD.Cmp_Id 
	Select * FROM #ContractBranch
	
	
	/*
	Select * From T0010_COMPANY_DIRECTOR_DETAIL CD inner join T0010_COMPANY_MASTER C on CD.cmp_id = C.Cmp_Id
	Where CD.Cmp_Id = @Cmp_ID
	*/
	 
	/*
	select  S.Skill_ID , Count(E.Emp_Id) as Tot from T0080_Emp_Master As E INNER JOIN T0010_Company_Master As c ON C.Cmp_Id = E.Cmp_Id
			inner join T0090_Emp_Skill_Detail S on E.Emp_ID = S.Emp_ID 
			--inner join T0040_TYPE_MASTER T on T.Type_ID = E.Type_ID 			
			WHERE E.Cmp_ID = @Cmp_Id --and T.Type_Name = 'Permanent' and 
			group by S.Skill_ID 
	
	select  count(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) as Male,COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) as Female,
			 Count(E.Emp_Id) as Total from T0080_Emp_Master As E INNER JOIN T0010_Company_Master As c ON C.Cmp_Id = E.Cmp_Id
			--inner join 
			
			(Select E.Emp_ID,
			
			INNER join T0040_TYPE_MASTER T on T.Type_ID = E.Type_ID
			
			WHERE E.Cmp_ID = @Cmp_Id --and T.Type_Name = 'Permanent'
			And E.Emp_ID in (select Emp_ID From #Emp_Cons)
			group by T.Type_ID ,E.Gender  --
	*/	
RETURN




