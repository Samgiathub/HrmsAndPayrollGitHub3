
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_INCREMENT_INFO_ALLOWANCE_GET]    
  @Cmp_ID   numeric    
 ,@From_Date  datetime    
 ,@To_Date   datetime    
 ,@Branch_ID  numeric    
 ,@Cat_ID   numeric     
 ,@Grd_ID   numeric    
 ,@Type_ID   numeric    
 ,@Dept_ID   numeric    
 ,@Desig_ID   numeric    
 ,@Emp_ID   numeric    
 ,@constraint  varchar(MAX)    
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
    
 Declare @PT numeric   
 Declare @Net_Salary numeric(18,2)
 Declare @PT_Branch numeric(18,0)
 Declare @PT_Amount numeric(18,2)
 Declare @PT_Emp_Id numeric(18,0)
 Declare @Effect_Date Datetime
 DEclare @Increment_ID numeric(18,0)
 
 declare @previous_date as datetime 
 set @previous_date = DATEADD(dd,-1,@from_date) 
 
 set @PT=0
 set @Net_Salary=0
 set @PT_Branch =0
 set @PT_Amount =0
    
    
 Declare @Emp_Cons Table    
 (    
  Emp_ID numeric    
 )    
	  
 declare @Data_Table table  
(  
 Ad_ID  Numeric,  
 Cmp_Id Numeric,  
 Emp_ID Numeric,  
 CTC    Numeric,  
 For_Date Datetime ,
 Increment_ID numeric,
 Ad_Name varchar(50),
 ad_not_effect_salary tinyint,
 ad_flag char(1) ,
 ad_sort_name varchar(40),
 Branch_id numeric
 
 )       
 
  declare @Old_Data_Table table			-- Added By Gadriwala 10042014
(  
 Ad_ID  Numeric,  
 Cmp_Id Numeric,  
 Emp_ID Numeric,  
 CTC    Numeric,  
 For_Date Datetime ,
 Increment_ID numeric,
 Ad_Name varchar(50),
 ad_not_effect_salary tinyint,
 ad_flag char(1) ,
 ad_sort_name varchar(40),
 Branch_id numeric
 
 )  
 
 if @Constraint <> ''    
  begin    
   Insert Into @Emp_Cons    
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')     
  end  
  else    
  begin    
       
       
   Insert Into @Emp_Cons    
    
   select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join     
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)   
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date     
           
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
  
  ---- Added By Gadriwala 10042014 - Start	
		-- Declare  @Old_Increment_ID  numeric		
		--	set @Old_Increment_ID = 0				
  
  
  -- select Top  1 @Old_Increment_ID= i.Increment_ID  
	 --from T0095_Increment I inner join     
  --   ( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment   -- Ankit 10092014 for Same Date Increment 
  --   where Increment_Effective_date <= @To_Date    
  --   and Cmp_ID = @Cmp_ID    
  --   group by emp_ID  ) Qry on    
    
  --   I.Emp_ID = Qry.Emp_ID and I.Increment_Id < Qry.Increment_Id    Left outer join
	 --T0080_EMP_MASTER E  on  E.Emp_ID = I.Emp_ID   Left outer join 
	 --T0010_Company_master CM on E.Cmp_ID =Cm.Cmp_ID Left join
	 --T0040_DESIGNATION_MASTER DGM ON I.Desig_Id = DGM.Desig_Id 
	 --WHERE E.Cmp_ID = @Cmp_Id and	 I.Increment_Effective_Date < @to_Date  and (i.Increment_Type='Increment' or  i.Increment_Type='Joining') /* And  i.Increment_Type='Increment'  AND   And  I.Increment_Effective_Date > @From_Date And i.Increment_Type='Increment'  */
	 --And E.Emp_ID in (select Emp_ID From @Emp_Cons) order by i.Increment_ID Desc
 
 
  
	--if ISNULL(@Old_Increment_ID,0) = 0 
	--set @Old_Increment_ID  =0
	
		-- added by rohit on 07052016
		Create table #Tbl_Get_AD
	(
		Emp_ID numeric(18,0),
		Ad_ID numeric(18,0),
		for_date datetime,
		E_Ad_Percentage numeric(18,5),
		E_Ad_Amount numeric(18,2)
		
	)
		insert into #Tbl_Get_AD
	exec P_Emp_Revised_Allowance_Get	@cmp_id=@cmp_id,@To_Date = @previous_date ,@Constraint= @constraint
	--select * from #Tbl_Get_AD
	--Insert into @Old_Data_Table
	--	select  AM.Ad_ID,EEM.cmp_id,EEM.Emp_ID,EEM.E_Ad_Amount,EEM.For_Date,I.increment_ID,am.Ad_Name,isnull(am.ad_not_effect_salary,0) as ad_not_effect_salary,am.ad_flag,am.ad_sort_name ,I.Branch_ID  
	--	  from t0050_ad_master am Left outer join   
 --              t0100_emp_earn_deduction EEM on am.Ad_ID = EEM.Ad_ID  Inner join   
	--	       t0080_emp_master EM on EEM.Emp_ID = EM.Emp_ID inner join  
	--	       t0095_increment I on EM.Increment_ID > I.Increment_Id and Em.Emp_ID = I.Emp_ID   
	--	  where am.cmp_id=@CMP_ID     and i.Increment_Effective_Date = EEM.For_Date 
	--				And i.Increment_Effective_Date <= @To_Date 
	--				and i.Increment_ID = @Old_Increment_ID
	--				and EEM.Emp_ID in (select Emp_ID From @Emp_Cons) order by I.Increment_ID Desc
   
    	Insert into @Old_Data_Table
		select  AM.Ad_ID,am.cmp_id,EEM.Emp_ID,EEM.E_Ad_Amount,EEM.For_Date,Em.Increment_ID,am.Ad_Name,isnull(am.ad_not_effect_salary,0) as ad_not_effect_salary,am.ad_flag,am.ad_sort_name ,EM.Branch_ID  
		  from t0050_ad_master am WITH (NOLOCK) Left outer join   
               #Tbl_Get_AD EEM on am.Ad_ID = EEM.Ad_ID   Inner join   
		       t0080_emp_master EM WITH (NOLOCK) on EEM.Emp_ID = EM.Emp_ID
		  where am.cmp_id=@CMP_ID     
					--and EEM.Emp_ID in (select Emp_ID From @Emp_Cons) 
    
    Insert into @Old_Data_Table 
		
	    select 0,i.cmp_id,i.Emp_ID,i.Basic_salary,I.Increment_Effective_Date,I.Increment_id,'Basic Salary',0,'I','Basic Salary',I.Branch_ID
		from 
		(select max(increment_id) as increment_id ,emp_id from t0095_increment WITH (NOLOCK) where Increment_Effective_Date <= @previous_date group by emp_id) new_i inner join
		T0095_INCREMENT I WITH (NOLOCK) on I.increment_id =New_i.Increment_ID and i.Emp_ID=New_i.emp_id inner join
		T0010_Company_master CM WITH (NOLOCK) on i.Cmp_ID =Cm.Cmp_ID
		WHERE i.Cmp_ID = @Cmp_Id  AND I.Increment_Effective_Date <= @previous_date 
		--And I.Increment_ID = @Old_Increment_ID 
		And i.Emp_ID in (select Emp_ID From @Emp_Cons) 
	
		
	Insert into @Old_Data_Table
	
			 select 0,i.cmp_id,i.Emp_ID,i.Emp_PT_Amount,I.Increment_Effective_Date,I.Increment_id,'PT',0,'D','PT',I.Branch_ID
				from (select max(increment_id) as increment_id ,emp_id from t0095_increment WITH (NOLOCK) where Increment_Effective_Date <= @previous_date group by emp_id) new_i inner join
				T0095_INCREMENT I WITH (NOLOCK) on I.increment_id =New_i.Increment_ID and i.Emp_ID=New_i.emp_id inner join   
				T0080_EMP_MASTER E  WITH (NOLOCK) on  I.Emp_ID = E.Emp_ID inner join 
				t0030_branch_master bm WITH (NOLOCK) on i.Branch_id = bm.branch_id 
				WHERE E.Cmp_ID = @Cmp_Id	
				--AND I.Increment_ID = @Old_Increment_ID  
				and E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
				
	 -- Added By Gadriwala 10042014 - End			
  
  
   Insert into @Data_Table  
   
	  select AM.Ad_ID,EEM.cmp_id,EEM.Emp_ID,EEM.E_Ad_Amount,EEM.For_Date,I.increment_ID,am.Ad_Name,isnull(am.ad_not_effect_salary,0) as ad_not_effect_salary,am.ad_flag,am.ad_sort_name ,I.Branch_ID  
	   from T0095_Increment I WITH (NOLOCK) inner join     
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment  
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID 	Left outer join
     t0080_emp_master EM WITH (NOLOCK) on I.Emp_ID = EM.Emp_ID inner join  
	 t0100_emp_earn_deduction EEM WITH (NOLOCK) on  EEM.EMP_ID = Em.Emp_ID and EEM.INCREMENT_ID=qry.Increment_ID  --added jimit 03022016
	 Inner join   
	 t0050_ad_master am WITH (NOLOCK) on  EEM.AD_ID = am.AD_ID             		        
	where am.cmp_id=@CMP_ID   and i.Increment_Effective_Date = EEM.For_Date And i.Increment_Effective_Date <= @To_Date And i.Increment_Effective_Date >= @From_Date   And EEM.Emp_ID in (select Emp_ID From @Emp_Cons) 
		and am.Hide_In_Reports = 0 --Added by Jaina 23-05-2017
		

		
	 --select * from @Data_Table order by Ad_Name desc
        Insert into @Data_Table  
        
		 select 0,i.cmp_id,i.Emp_ID,i.Basic_salary,I.Increment_Effective_Date,I.Increment_id,'Basic Salary',0,'I','Basic Salary',I.Branch_ID
		from --T0080_EMP_MASTER E Left outer join 
		t0095_increment i WITH (NOLOCK)
		inner join     
		( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment 
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID
		inner join
		T0010_Company_master CM WITH (NOLOCK) on i.Cmp_ID =Cm.Cmp_ID
		WHERE i.Cmp_ID = @Cmp_Id	AND I.Increment_Effective_Date <= @to_Date And  I.Increment_Effective_Date >= @From_Date  And
		i.Emp_ID in (select Emp_ID From @Emp_Cons) 
      
      	
      	
		-- Changed By Gadriwala 10042014
		
		 select @PT =isnull(i.Emp_PT,0),@PT_Branch = i.Branch_ID,@PT_Emp_Id=i.Emp_ID,@Effect_Date=Increment_Effective_Date,@Increment_ID=i.Increment_ID
		from  T0095_Increment I WITH (NOLOCK) inner join     
		( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment 
     where Increment_Effective_date <= @To_Date    
     and Cmp_ID = @Cmp_ID    
     group by emp_ID  ) Qry on    
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  Left outer Join
		T0080_EMP_MASTER E  WITH (NOLOCK) on  I.Emp_ID = E.Emp_ID  inner join
		t0030_branch_master bm WITH (NOLOCK) on i.Branch_id = bm.branch_id 
		WHERE E.Cmp_ID = @Cmp_Id	AND I.Increment_Effective_Date <= @to_Date And  I.Increment_Effective_Date >= @From_Date  And
		E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
   
		
      
      Declare @pt_Branch_ID numeric
      Declare @pt_Emp_ID1    numeric
      DEclare @PT_Emp_pt numeric
      declare @PT_Effect_Date datetime
      declare @PT_Increment_ID numeric
      
      
		Declare curPTSetting cursor for
				select i.Emp_ID, i.Branch_ID,isnull(i.Emp_PT,0) as Emp_PT,i.Increment_Effective_Date,i.Increment_Id
					from T0095_Increment I WITH (NOLOCK) inner join     
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment	 
						  where Increment_Effective_date <= @To_Date    
						 and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on    
				I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  Inner join
				T0080_EMP_MASTER E  WITH (NOLOCK) on  I.Emp_ID = E.Emp_ID inner join 
				t0030_branch_master bm WITH (NOLOCK) on i.Branch_id = bm.branch_id 
				WHERE E.Cmp_ID = @Cmp_Id	AND I.Increment_Effective_Date <= @to_Date And  I.Increment_Effective_Date >= @From_Date  And
				E.Emp_ID in (select Emp_ID From @Emp_Cons) order by E.Emp_Code asc 
		
		open curPTSetting
			fetch next from curPTSetting into @pt_Emp_ID1,@pt_Branch_ID,@PT_Emp_pt,@PT_Effect_Date,@PT_Increment_ID
			while @@fetch_status = 0
				Begin
				
					if @PT_Emp_pt <> 0
						Begin
      						select @Net_Salary = sum(CTC) from @Data_Table where ad_not_effect_salary <> 1 And ad_flag ='I' and Emp_ID = @pt_Emp_ID1
							--Commented and Addedn isnull condition by sumit in case branch is null in that table on 17052016
							--select @PT_Amount=Amount from T0040_PROFESSIONAL_SETTING where branch_id = @PT_Branch and @Net_Salary >= From_limit and @Net_Salary <= To_Limit
							select @PT_Amount=Amount from T0040_PROFESSIONAL_SETTING WITH (NOLOCK) where isnull(branch_id,@PT_Branch) = @PT_Branch and @Net_Salary >= From_limit and @Net_Salary <= To_Limit
							
			
							Insert into @Data_Table(Ad_ID,Cmp_Id,Emp_ID,CTC,For_Date,Increment_ID,Ad_Name,ad_not_effect_salary,ad_flag,ad_sort_name,Branch_id)  
							values(0,@Cmp_Id,@PT_Emp_Id1,@PT_Amount,@PT_Effect_Date,@PT_Increment_ID,'PT',0,'D','PT',@PT_Branch)
						End
					
					Declare @Amount  numeric(18,0)
					
					
					
					--select @Amount=max(lea.limit)  from  t0100_emp_earn_deduction eem inner join t0050_ad_master am on eem.ad_id = am.ad_id inner join t0040_late_extra_amount lea on eem.ad_id = lea.allowance_id where ad_calculate_on='Present Senario' and increment_id=@PT_Increment_ID
					
					
					insert into @Data_Table(Ad_ID,Cmp_Id,Emp_ID,CTC,For_Date,Increment_ID,Ad_Name,ad_not_effect_salary,ad_flag,ad_sort_name,Branch_id)  
					select eem.ad_id,am.cmp_id,@pt_Emp_ID1,limit,eem.for_date,@PT_Increment_ID,am.ad_name,am.ad_not_effect_salary,am.ad_flag,am.ad_sort_name,@pt_Branch_ID  from  t0100_emp_earn_deduction eem WITH (NOLOCK) inner join t0050_ad_master am WITH (NOLOCK) on eem.ad_id = am.ad_id inner join t0040_late_extra_amount lea WITH (NOLOCK) on eem.ad_id = lea.allowance_id where ad_calculate_on='Present Senario' and increment_id=@PT_Increment_ID and limit=@Amount
					
				fetch next from curPTSetting into @pt_Emp_ID1,@pt_Branch_ID,@PT_Emp_pt,@PT_Effect_Date,@PT_Increment_ID
				end
			close curPTSetting
			deallocate curPTSetting
			
    
  --   -- Changed By Gadriwala 10042014
  --    select distinct New_Data.*,isnull(old_Data.Ad_ID,'-1') as Old_Ad_ID,isnull(old_Data.Ad_Name,'') as Old_ad_Name, isnull(old_Data.CTC,0) as OLD_CTC 
  --     ,isnull(Am.ad_part_of_ctc,0)  as ad_part_of_ctc
  --    from @Data_Table New_Data 
  --    left outer join @Old_Data_Table old_Data on New_Data.Ad_ID = old_Data.Ad_ID and New_Data.ad_sort_name = Old_data.ad_sort_name 
  --     and New_Data.Emp_ID=old_Data.emp_id 
		----	and New_Data.Increment_ID = old_Data.Increment_ID		--added jimit 03022016
  --      left join T0050_AD_MASTER AM On New_Data.Ad_ID = AM.ad_id  
  --     --order by Am.AD_LEVEL asc
   
	 --New Code Added By Ramiz on 06/07/2017--
	
	  ----- Distinct Add by jignesh Patel 21-Aug-2021--------
		select * from
		(
		SELECT distinct  dt.* ,isnull(Am.ad_part_of_ctc,0)  as ad_part_of_ctc , QRY_CTC.MONTHLY_CTC,
						dbo.F_Number_TO_Word(QRY_CTC.MONTHLY_CTC) as MONTHLY_CTC_In_Words --As Error coming at Havmor that MONTHLY_CTC_In_Words not found in rpt 11072018
						,AM.AD_DEF_ID
						,Isnull(AM.Allowance_Type,'')as Allowance_Type,AD_LEVEL
		FROM 
		  (
			SELECT DISTINCT isnull(New_Data.Ad_ID,old_Data.Ad_ID) as ad_id,ISNULL(New_Data.Cmp_Id,old_Data.Cmp_Id) as cmp_id, 
							isnull(New_Data.Emp_ID,old_Data.Emp_ID) as emp_id,isnull(New_Data.CTC,0) as ctc, isnull(New_Data.For_Date,'') as for_date,
							isnull(New_Data.Increment_ID,0)as increment_id, isnull(New_Data.Ad_Name ,old_Data.Ad_Name) as ad_name,
							isnull(New_Data.ad_not_effect_salary,old_Data.ad_not_effect_salary) as ad_not_effect_salary, 
							isnull(New_Data.ad_flag,old_Data.ad_flag) as ad_flag,isnull(New_Data.ad_sort_name,old_Data.ad_sort_name) as ad_sort_name, 
							isnull(New_Data.Branch_id ,old_Data.Branch_id ) as branch_id,isnull(old_Data.Ad_ID,'-1') as Old_Ad_ID,
							isnull(old_Data.Ad_Name,'') as Old_ad_Name, isnull(old_Data.CTC,0) as OLD_CTC ,ISNULL(New_Data.Ad_ID,old_Data.Ad_ID) as ad_id_new
			FROM @Data_Table New_Data 
			FULL OUTER JOIN @Old_Data_Table old_Data on New_Data.Ad_ID = old_Data.Ad_ID and New_Data.ad_sort_name = Old_data.ad_sort_name and New_Data.Emp_ID=old_Data.emp_id 
		   ) AS dt
		LEFT JOIN T0050_AD_MASTER AM WITH (NOLOCK) ON DT.AD_ID_NEW = AM.AD_ID 
		LEFT OUTER JOIN (
							SELECT EMP_ID , SUM(CTC) AS MONTHLY_CTC 
							FROM @Data_Table 
							WHERE AD_FLAG = 'I' 
							GROUP BY EMP_ID
						) QRY_CTC ON QRY_CTC.Emp_ID = dt.Emp_ID
		---- Add by Jignesh 26-Dec-2019---
		inner join @Data_Table as A
		On A.Ad_ID=dt.Ad_ID
		and A.Emp_ID=dt.emp_id 
		) as am
		order by AM.AD_LEVEL
    
 Return




