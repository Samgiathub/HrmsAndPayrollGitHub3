



---------Created by Sumit--01/01/2015-----------------------------------------------------
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_EXP_GET]
	 @CMP_ID 		NUMERIC
	,@FROM_DATE 	DATETIME
	,@TO_DATE 		DATETIME
	,@BRANCH_ID 	NUMERIC
	,@CAT_ID 		NUMERIC 
	,@GRD_ID 		NUMERIC
	,@TYPE_ID 		NUMERIC
	,@DEPT_ID 		NUMERIC
	,@DESIG_ID 		NUMERIC
	,@EMP_ID 		NUMERIC
	,@CONSTRAINT 	VARCHAR(MAX)
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		
	,@Vertical_Id numeric = 0		
	,@SubVertical_Id numeric = 0	
	,@SubBranch_Id numeric = 0		
	,@from_Exp numeric(18,0)=0
	,@to_Exp numeric(18,0)=50
	,@Exp_Diff numeric(18,0)=5
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
	IF @Salary_Cycle_id = 0	 
	set @Salary_Cycle_id = null	
	If @Segment_Id = 0		 
	set @Segment_Id = null
	If @Vertical_Id = 0		 
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 
	set @SubBranch_Id = null
	
	CREATE TABLE #Emp_Cons 	
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )   		 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 

create table #temp_Exp_details
(
	Emp_id nvarchar(50),
	Emp_name varchar(100),
	cmp_id numeric(18,0),
	emp_age numeric(18,0),			
	emp_Exp numeric(18,1),			
	design_name varchar(100),
	emp_code numeric(18,0),
	type_name varchar(100),
	dept_name varchar(200),
	cmp_name varchar(200),
	cmp_address varchar(500),
	comp_name varchar(200),
	p_from_date datetime,
	p_to_date datetime,
	branch_name varchar(200),
	branch_address varchar(500),
	branch_id numeric(18,0),
	Grd_name varchar(200),
	Emp_Exp_lable varchar(100),
	date_of_birth datetime,
	Exp_year varchar(50),
	Exp_month varchar(50),
	Exp_days varchar(50),
	
	joining_date datetime,
	vertical_name varchar(100),
	subvertical_name varchar(100)
)
	
insert into #temp_Exp_details
			select E.Alpha_Emp_Code,
			ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name) as Emp_Full_Name,E.Cmp_ID,
			dbo.F_GET_AGE(Date_Of_Birth,getdate(),'','')as emp_age,			
			
			--cast(cast(dbo.Get_Age_CountDMY(ED.St_Date,ED.End_Date,'YM')as numeric(18,2)) + dbo.Get_Age_CountDMY(E.Date_of_join,GETDATE(),'YM')as numeric(18,2)) as total_exp,
			--cast(ttl_exp + dbo.Get_Age_CountDMY(E.Date_of_join,GETDATE(),'YM')as numeric(18,2)) as total_exp,
			cast(case when ttl_exp is null then 0 else ttl_exp end+ dbo.Get_Age_CountDMY(E.Date_of_join,GETDATE(),'YM')as numeric(18,2)) as total_exp,
			DGM.Desig_Name,EMP_CODE,Type_Name,Dept_Name,Cmp_Name,Cmp_Address,Comp_name,@From_date,@TO_DATE,Branch_Name,Branch_Address
			,BM.Branch_ID,Grd_Name,'',			
			date_of_birth,	
			dbo.Get_Age_CountDMY('2007-08-18 00:00:00.000','2009-10-31 00:00:00.000','Y') as Exp_year,			
			dbo.Get_Age_CountDMY('2007-08-18 00:00:00.000','2009-10-31 00:00:00.000','M') as Exp_Month,			
			dbo.Get_Age_CountDMY('2007-08-18 00:00:00.000','2009-10-31 00:00:00.000','D') as Exp_days,			
			Date_Of_Join,VG.Vertical_Name,SB.SubVertical_Name
			From T0080_Emp_master E WITH (NOLOCK)
			inner join
  			(select I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Cmp_ID,Increment_effective_Date,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join 
			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
						on E.Emp_ID = I_Q.Emp_ID  left join
						(select EG.Emp_ID,sum(EG.EmpExp)as ttl_exp from T0090_EMP_EXPERIENCE_DETAIL EG WITH (NOLOCK)
						where Eg.Cmp_id=@cmp_id group by EG.Emp_id 
						) EXPD on EXPD.Emp_ID=E.Emp_ID left join
						--T0090_EMP_EXPERIENCE_DETAIL ED on ED.Emp_ID=E.Emp_ID LEFT outer join
						T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
						T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
						T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
						T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
						T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  inner join
						T0010_Company_Master CM WITH (NOLOCK) on I_Q.Cmp_ID = CM.Cmp_ID left outer join
						T0040_Vertical_Segment VG WITH (NOLOCK) on VG.Vertical_ID=I_Q.Vertical_ID left outer join
						T0050_SubVertical SB WITH (NOLOCK) on SB.SubVertical_ID=I_Q.SubVertical_ID
				WHERE		E.Cmp_ID = @Cmp_Id 
				--and  For_Date >=@From_Date and For_Date <=@To_Date 
				And E.Emp_Id In (Select Emp_Id From #Emp_Cons) 
					
					
					
				Declare @Query nvarchar(200)
				DECLARE @Set_value INT;
				declare @age_difference varchar(50)
				declare @frm_ag numeric(18,2)
				declare @start numeric(18,2)
				set @start=@from_Exp
				SET @Set_value = 0;	
				WHILE @Set_value <= @to_Exp
					BEGIN
					if @Set_value > 0 
							begin	
								set @age_difference='Exp_'+case when @frm_ag <10 then '0'+ cast(@frm_ag as varchar(50)) else cast(@frm_ag as varchar(50)) end+'_to_'+cast(@Set_value as varchar(50))
							end
					else 
							begin						
								set @age_difference='Under_'+cast(@from_Exp as varchar(50))
							end
						Set @Query = 'update #temp_Exp_details set Emp_Exp_lable =''' + REPLACE(@age_difference,' ','_') + ''' where #temp_Exp_details.emp_Exp between '+cast(@frm_ag as varchar(50))+' and '+cast(@Set_value as varchar(50))+''
						set @frm_ag=@from_Exp
						set @Set_value=@frm_ag+@Exp_Diff
						set @frm_ag=@from_Exp+ 0.01
						set @from_Exp=@Set_value				
						exec(@Query)
				END;
				set @Query='update #temp_Exp_details set Emp_Exp_lable = ''Exp_Above_'+cast(@to_Exp as varchar(50))+''' from #temp_Exp_details t inner join #temp_Exp_details on t.emp_Exp=#temp_Exp_details.emp_Exp where #temp_Exp_details.emp_Exp >'+cast(@to_Exp as varchar(50))										
				exec(@Query)					
				set @Query='update #temp_Exp_details set Emp_Exp_lable = ''Exp_'+cast(@start as varchar(50))+'_or_Below'' from #temp_Exp_details t inner join #temp_Exp_details on t.emp_Exp=#temp_Exp_details.emp_Exp where #temp_Exp_details.emp_Exp <='+cast(@start as varchar(50))
				exec(@Query)
select * from #temp_Exp_details
drop table #temp_Exp_details
		
	RETURN 
	



