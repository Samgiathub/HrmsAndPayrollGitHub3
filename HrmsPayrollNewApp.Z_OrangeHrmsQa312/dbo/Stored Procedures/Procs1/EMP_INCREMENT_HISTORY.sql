
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[EMP_INCREMENT_HISTORY]      
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 --,@Branch_ID  numeric   
 --,@Cat_ID  numeric 
 --,@Grd_ID  numeric 
 --,@Type_ID  numeric  
 --,@Dept_ID  numeric  
 --,@Desig_ID  numeric 
 ,@Branch_ID  varchar(max)
 ,@Cat_ID     varchar(max) 
 ,@Grd_ID     varchar(max) 
 ,@Type_ID    varchar(max)  
 ,@Dept_ID    varchar(max)  
 ,@Desig_ID   varchar(max) 
 ,@Emp_ID  numeric 
 ,@Constraint varchar(MAX) = '' 
 ,@Emp_Search int=0     
 ,@Order_By   varchar(30) = 'Code' --Added by Jimit 28/09/2015 (To sort by Code/Name/Enroll No)
 ,@Reason_Name Varchar(100) = '' --Added by nilesh patel on 23012016
 ,@Show_Hidden_Allowance  bit = 1   --Added by Jaina 11-05-2017            
 
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON    
       
 /*    
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
 
 If @Desig_ID = 0      
  set @Desig_ID = null */      
      
 if @Emp_ID = 0      
  set @Emp_ID = null      
        
 if @Reason_Name = '' or @Reason_Name = '--Select--'
	Set @Reason_Name = NULL
        
  
	CREATE TABLE #Emp_Cons	-- Ankit 10092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )
	-- Comment by nilesh patel          
	-- EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint --,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
    -- Added by nilesh patel 
    exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'','','','',0,0,0,'0',0,0 
       
 --Declare #Emp_Cons Table      
 --(      
 --  Emp_ID numeric ,     
 -- Branch_ID numeric    
 --)      
       
 --if @Constraint <> ''      
 -- begin      
 --  Insert Into #Emp_Cons      
 --  select  cast(data  as numeric),cast(data  as numeric) from dbo.Split (@Constraint,'#')       
 -- end      
 --else      
 -- begin      
        
  
	--	   Insert Into #Emp_Cons      
		      
	--	   select I.Emp_Id,I.Branch_ID from T0095_Increment I inner join       
	--		 ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment       --Changed by Hardik 10/09/2014 for Same Date Increment 
	--		 where Increment_Effective_date <= @To_Date      
	--		 and Cmp_ID = @Cmp_ID      
	--		 group by emp_ID  ) Qry on      
	--		 I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id      
	--	   Where Cmp_ID = @Cmp_ID       
	--	   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--	   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--	   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))      
	--	   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)       
	--	   and I.Emp_ID in       
	--		( select Emp_Id from      
	--		(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry      
	--		where cmp_ID = @Cmp_ID   and        
	--		(( @From_Date  >= join_Date  and  @From_Date <= left_date )       
	--		or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
	--		or Left_date is null and @To_Date >= Join_Date)      
	--		or @To_Date >= left_date  and  @From_Date <= left_date )   
	
		         
 -- end    
  
  CREATE table #Inc_History
  (
	cmp_id numeric(18),
	inc_id numeric(18),
	Emp_id numeric(18),
	Emp_Code nvarchar(50),
	Emp_Full_Name nvarchar(100),
	Basic_Salary numeric(18,2),
	Gross_Salary numeric(18,2),
	CTC numeric(18,2),
	Revised_date datetime,
	B_Growth_Per numeric(18,3),
	G_Growth_Per numeric(18,3),
	C_Growth_Per numeric(18,3),
	Inc_after_days numeric(18)
	,Desig_dis_No    numeric(18,0)	DEFAULT 0		 --added jimit 28/09/2015
	,Enroll_No       VARCHAR(50)	DEFAULT ''		 --added jimit 28/09/2015
	,Designation     VARCHAR(50) DEFAULT ''			 --added jimit 28/09/2015
	,Reason          VARCHAR(500) DEFAULT ''	     --added Nilesh Patel on 22012016
	
  )
  
	declare @C_Emp_id numeric(18)
	declare @Revised_date datetime
	declare @B_Growth_Per numeric(18,3)
	declare @G_Growth_Per numeric(18,3)
	declare @C_Growth_Per numeric(18,3)
	
	declare @Count numeric(18)
	declare @P_C_Emp_id numeric(18)
	declare @P_Revised_date datetime
	declare @P_B_Growth_Per numeric(18,3)
	declare @P_G_Growth_Per numeric(18,3)
	declare @P_C_Growth_Per numeric(18,3)
	Declare @inc_id numeric --added by hardik 03/03/2016
	
	
	set @Count = 0
	set @P_C_Emp_id = 0
	set @P_B_Growth_Per = 0
	set @P_G_Growth_Per = 0
	set @P_C_Growth_Per = 0
	Set @inc_id = 0
  
  insert into #Inc_History
  select inc.cmp_id,inc.increment_id,inc.emp_id,em.alpha_emp_code,em.emp_full_name,inc.basic_Salary , inc.gross_salary,inc.ctc,inc.increment_effective_date,0,0,0,0 
  ,dnm.Desig_Dis_No,Em.Enroll_No,Dnm.Desig_Name,inc.Reason_Name  --added jimit 28/09/2015
  from t0095_increment inc WITH (NOLOCK)
  inner join t0080_emp_master em WITH (NOLOCK) on inc.emp_id = em.emp_id
  inner join #Emp_Cons ec on  ec.emp_id = inc.emp_id inner JOIN
  --added jimit 28/9/2015-------------
		(SELECT	I.Emp_id,Branch_ID,Grd_ID,Dept_ID,Desig_Id,TYPE_ID,I.Cmp_ID
						FROM	T0095_INCREMENT I WITH (NOLOCK)
						WHERE	I.INCREMENT_ID = (
													SELECT	TOP 1 INCREMENT_ID
													FROM	T0095_INCREMENT I1 WITH (NOLOCK)
													WHERE	I1.EMP_ID=I.EMP_ID AND I1.CMP_ID=I.CMP_ID
													ORDER BY	INCREMENT_EFFECTIVE_DATE DESC, INCREMENT_ID DESC
												)
					  ) AS B ON B.EMP_ID = em.EMP_ID AND B.CMP_ID=em.CMP_ID 
	left outer join T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on B.Desig_Id = dnm.Desig_ID 
		--ended
  order by inc.emp_id,inc.increment_effective_date
    
  declare curInc cursor for    
	select emp_id,Basic_Salary,Gross_Salary,CTC,Revised_date,inc_id from #Inc_History   order by emp_id,Revised_date
  open curInc
	fetch next from curInc into @C_Emp_id,@B_Growth_Per,@G_Growth_Per,@C_Growth_Per,@Revised_date,@inc_id
	while @@fetch_status = 0
		begin 
			
			if @Count = 0 or @P_C_Emp_id <> @C_Emp_id
				begin
					set @P_C_Emp_id = @C_Emp_id
					set @P_B_Growth_Per = @B_Growth_Per
					set @P_G_Growth_Per = @G_Growth_Per
					set @P_C_Growth_Per = @C_Growth_Per
					set @P_Revised_date = @Revised_date
				end
			else
				begin
					
					declare @diff as numeric(18,2)
					declare @B_perc as numeric(18,3)
					set @diff = 0
					
					--basic
					
					set @diff = @B_Growth_Per - @P_B_Growth_Per
					
					if @P_B_Growth_Per > 0
						begin
							set @B_perc = (@diff/@P_B_Growth_Per) * 100
						end
					else
						begin
							set @B_perc = 0
						end
					
					update #Inc_History set B_Growth_Per = @B_perc where emp_id = @C_Emp_id and Revised_date = @Revised_date and inc_id = @inc_id
					
					-- gross 
					set @diff = 0
					
					set @diff = @G_Growth_Per - @P_G_Growth_Per
					
					if @P_G_Growth_Per > 0
						begin
							set @B_perc = (@diff/@P_G_Growth_Per) * 100
						end
					else
						begin
							set @B_perc = 0
						end
					
					update #Inc_History set G_Growth_Per = @B_perc where emp_id = @C_Emp_id and Revised_date = @Revised_date and inc_id = @inc_id
					
					-- CTC
					
					set @diff = 0
					
					set @diff = @C_Growth_Per - @P_C_Growth_Per
					
					if @P_C_Growth_Per > 0
						begin
							set @B_perc = (@diff/@P_C_Growth_Per) * 100
						end
					else
						begin
							set @B_perc = 0
						end
					
					update #Inc_History set C_Growth_Per = @B_perc where emp_id = @C_Emp_id and Revised_date = @Revised_date and inc_id = @inc_id
					
					
					declare @days numeric(18)
					set @days = 0
					
					set @days  = abs(datediff(dd,@P_Revised_date,@Revised_date))  + 1
					
					update #Inc_History set Inc_after_days = @days where emp_id = @C_Emp_id and Revised_date = @Revised_date and inc_id = @inc_id
										
					set @P_C_Emp_id = @C_Emp_id
					set @P_B_Growth_Per = @B_Growth_Per
					set @P_G_Growth_Per = @G_Growth_Per
					set @P_C_Growth_Per = @C_Growth_Per
					set @P_Revised_date = @Revised_date
					
				end
			
			set @Count = @Count + 1		
			fetch next from curInc into @C_Emp_id,@B_Growth_Per,@G_Growth_Per,@C_Growth_Per,@Revised_date,@inc_id
		end  
	close curInc
	deallocate curInc	
  
  
	Update #Inc_History  set Emp_Code = '="' + Emp_Code + '"'  -- Added By Gadriwala 03052014
;With CTE AS(
 
        select ROW_NUMBER() OVER(PARTITION BY IH.cmp_id,IH.inc_id,IH.Emp_id ORDER BY IH.emp_id,Revised_date) As RowID,
          IH.cmp_id,IH.inc_id,IH.Emp_id,IH.Emp_Code,IH.Emp_Full_Name,IH.Basic_Salary,IH.Gross_Salary,
          IH.CTC,IH.Revised_date,IH.B_Growth_Per,IH.G_Growth_Per,IH.C_Growth_Per,IH.Inc_after_days
			,am.AD_NAME, eed.E_AD_MODE,Case When Isnull(eed.Is_Calculate_Zero,0)=0 Then dbo.F_Show_Decimal(eed.E_AD_Amount,eed.cmp_id) Else dbo.F_Show_Decimal(-1,eed.cmp_id) End  AS E_AD_AMOUNT,
			I.Branch_ID,Ih.Desig_dis_No,Ih.Enroll_No,Ih.Designation,IH.Reason
		from #Inc_History  IH
			inner join T0100_EMP_EARN_DEDUCTION eed WITH (NOLOCK) on IH.inc_id = eed.increment_id	
			inner join T0050_AD_MASTER am WITH (NOLOCK) on eed.AD_ID = am.AD_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Increment_ID = IH.inc_id
		where isnull(IH.Reason,'') = ISNULL(@Reason_Name,isnull(IH.Reason,'')) 
		AND (CASE WHEN @Show_Hidden_Allowance = 0  and  am.Hide_In_Reports = 1 AND am.AD_NOT_EFFECT_SALARY = 1 THEN 0 else 1 END )=1  --Change By Jaina 11-05-2017
  )

SELECT case when RowID =1 then Emp_Code else '' end as Emp_Code,
		case when RowID =1 then Emp_Full_Name else '' end as Emp_Full_Name,
		isnull(cast(case when RowID =1 then Basic_Salary  end as varchar(30)),'') as Basic_Salary,
		isnull(cast(case when RowID =1 then Gross_Salary  end as varchar(30)),'') as Gross_Salary,
		isnull(cast(case when RowID =1 then CTC  end as varchar(30)),'') as CTC,
	    isnull(cast(case when RowID =1 then convert(varchar,Revised_date,103)  end as varchar(30)),'') as Revised_date,
		isnull(cast(case when RowID =1 then B_Growth_Per  end as varchar(30)),'') as B_Growth_Per,
		isnull(cast(case when RowID =1 then G_Growth_Per  end as varchar(30)),'') as G_Growth_Per,
		isnull(cast(case when RowID =1 then C_Growth_Per  end as varchar(30)),'') as C_Growth_Per,
		isnull(cast(case when RowID =1 then Inc_after_days  end as varchar(30)),'') as Inc_after_days,
		isnull(cast(case when RowID =1 then Reason  end as varchar(30)),'') as Reason,
	    isnull(AD_NAME,'') AD_NAME,
	    isnull(E_AD_MODE,'') E_AD_MODE,
	    isnull(cast(E_AD_AMOUNT as varchar(30)),'') E_AD_AMOUNT,Branch_ID
	    --,Desig_dis_No,Designation
 --FROM CTE ORDER BY emp_id 
		FROM CTE ORDER BY CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(CTE.Enroll_No AS VARCHAR), 21)  
							WHEN @Order_By='Name' THEN CTE.Emp_Full_Name
							When @Order_By = 'Designation' then (CASE WHEN CTE.Desig_dis_No  = 0 THEN CTE.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(CTE.Desig_dis_No AS VARCHAR), 21)   END)   
							--ELSE RIGHT(REPLICATE(N' ', 500) + CAST(CTE.Emp_Code AS VARCHAR), 500) 
						End,Case When IsNumeric(Replace(Replace(CTE.Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(CTE.Emp_Code,'="',''),'"',''), 20)
								 When IsNumeric(Replace(Replace(CTE.Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(CTE.Emp_Code,'="',''),'"','') + Replicate('',21), 20)
								 Else Replace(Replace(CTE.Emp_Code,'="',''),'"','') End
						--RIGHT(REPLICATE(N' ', 500) + CTE.Emp_Code, 500)
  
 RETURN      
      
      
    

