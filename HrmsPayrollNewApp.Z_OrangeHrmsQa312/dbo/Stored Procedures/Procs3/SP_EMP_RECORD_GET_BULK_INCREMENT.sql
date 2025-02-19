
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_RECORD_GET_BULK_INCREMENT]      
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 ,@Branch_ID  numeric   
 ,@Cat_ID  numeric 
 ,@Grd_ID  numeric 
 ,@Type_ID  numeric  
 ,@Dept_ID  numeric  
 ,@Desig_ID  numeric 
 ,@Emp_ID  numeric 
 ,@Constraint varchar(MAX) = '' 
 ,@Emp_Search int=0     
 ,@St_Date datetime = NULL
 ,@End_Date datetime = NULL
 ,@BSegment_ID numeric		= 0		--Added By Gadriwala 21102013
 ,@Vertical_ID numeric		= 0		--Added By Gadriwala 21102013
 ,@subVertical_ID numeric	= 0		--Added By Gadriwala 21102013
 ,@subBranch_ID numeric		= 0		--Added By Gadriwala 21102013
 ,@Increment_Mode	Varchar(30)
 ,@Basic_Salary		Numeric(18,4)
 ,@Gross_Salary		Numeric(18,4)
 ,@CTC		Numeric(18,2)
 ,@Branch_ID_Multi varchar(max)=''   --Added By Jaina 23-09-2015
 ,@Vertical_ID_Multi varchar(max)='' --Added By Jaina 23-09-2015
 ,@Subvertical_ID_Multi varchar(max)='' --Added By Jaina 23-09-2015
 ,@Dept_ID_Multi varchar(max)=''  --Added By Jaina 23-09-2015
AS      
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON   
 

      
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
 
 if @BSegment_ID = 0 
  set @BSegment_ID = null    
 if @Vertical_ID = 0				--Added By Gadriwala 21102013
  set @Vertical_ID = null
 if @subVertical_ID = 0				--Added By Gadriwala 21102013
  set @subVertical_ID = null
 if @subBranch_ID  = 0				--Added By Gadriwala 21102013
  set @subBranch_ID = null       
  
 IF @Branch_ID_Multi='0' or @Branch_ID_Multi=''  --Added By Jaina 23-09-2015
	set @Branch_ID_Multi=null	

IF @Vertical_ID_Multi='0' or @Vertical_ID_Multi='' --Added By Jaina 23-09-2015
	set @Vertical_ID_Multi=null	

IF @Subvertical_ID_Multi='0' or @Subvertical_ID_Multi='' --Added By Jaina 23-09-2015
	set @Subvertical_ID_Multi=null	
	
IF @Dept_ID_Multi='0' or @Dept_ID_Multi='' --Added By Jaina 23-09-2015
	set @Dept_ID_Multi=null	           
       
       
 CREATE table #Emp_Cons 
 (      
  Emp_ID numeric ,     
  Branch_ID numeric,
  Increment_ID numeric,
  Vertical_ID numeric(18,0), --Added By Jaina 23-09-2015
  SubVertical_ID numeric(18,0), --Added By Jaina 23-09-2015
  Dept_ID numeric(18,0)   --Added By Jaina 23-09-2015
 )      
         
       
 if @Constraint <> ''      
  begin      
   Insert Into #Emp_Cons      
   select  cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) from dbo.Split (@Constraint,'#')       
  end      
 else      
  begin      
        
    if isnull(@St_Date,0) = 0 or isnull(@end_date,0) = 0
		begin 
		
		
		   Insert Into #Emp_Cons      
		      select emp_id,branch_id,Increment_ID,Vertical_ID,SubVertical_ID,Dept_ID from V_Emp_Cons where   --Change By Jaina 23-09-2015
		      cmp_id=@Cmp_ID 
		       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
		   and ISNULL(Segment_ID,0) = ISNULL(@BSegment_ID,isnull(Segment_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(Vertical_ID,0) = ISNULL(@vertical_id,isnull(Vertical_ID,0))		--Added By Gadriwala 21102013
		   and ISNULL(SubVertical_ID,0) = ISNULL(@subVertical_ID,isnull(SubVertical_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(subBranch_ID,0) = ISNULL(@subBranch_ID,isnull(subBranch_ID,0)) --Added By Gadriwala 21102013
		  
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
		      and Increment_Effective_Date <= @To_Date 
		      and 
                      ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
						or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
						or (Left_date is null and @To_Date >= Join_Date)      
						or (@To_Date >= left_date  and  @From_Date <= left_date ))
						order by Emp_ID
			
			Delete From #Emp_Cons Where Increment_ID Not In	--Ankit 30012014
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
				Where Increment_effective_Date <= @to_date)			
			
		end
	else
		begin
		
		   Insert Into #Emp_Cons      
		      select emp_id,branch_id,Increment_ID,Vertical_ID,SubVertical_ID,Dept_ID from V_Emp_Cons where  --Change By Jaina 23-09-2015
		      cmp_id=@Cmp_ID 
		       and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
		   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
		   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
		   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
		   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
		   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
		   and ISNULL(Segment_ID,0) = ISNULL(@BSegment_ID,isnull(Segment_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(Vertical_ID,0) = ISNULL(@vertical_id,isnull(Vertical_ID,0))		--Added By Gadriwala 21102013
		   and ISNULL(SubVertical_ID,0) = ISNULL(@subVertical_ID,isnull(SubVertical_ID,0)) --Added By Gadriwala 21102013
		   and ISNULL(subBranch_ID,0) = ISNULL(@subBranch_ID,isnull(subBranch_ID,0)) --Added By Gadriwala 21102013
		 
		   and Emp_ID = isnull(@Emp_ID ,Emp_ID)  
		      and Increment_Effective_Date <= @To_Date 
		      and 
                     ( isnull(Left_date,@to_date) = @to_date or 
					(@St_Date <= isnull(left_date,@St_Date)  and @end_date >= isnull(left_date,@end_date) ) OR (join_Date <= @End_Date and isnull(left_date,@To_Date) = @To_Date)  ) 
						order by Emp_ID
			
			Delete From #Emp_Cons Where Increment_ID Not In	--Ankit 30012014
				(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
				Where Increment_effective_Date <= @to_date)	
			
		end    
  end    
	
	DECLARE @ROUNDING AS INT
	SET @ROUNDING = 0
	
	If @Branch_ID is null
		Begin 
			select Top 1 @ROUNDING = ISNULL(Ad_Rounding,0)
			  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= getdate() and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @ROUNDING = ISNULL(Ad_Rounding,0)
			  from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from dbo.T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <= getdate() and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End
	
	
--Added By Jaina 23-09-2015 Start    
    if (@Branch_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM #Emp_Cons Where Branch_Id NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Branch_ID_Multi, '#')) OR Branch_Id IS NULL
    END
    if (@Vertical_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM #Emp_Cons Where Vertical_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Vertical_ID_Multi, '#'))  OR Vertical_ID IS NULL
    END
    if (@Subvertical_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM #Emp_Cons Where SubVertical_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Subvertical_ID_Multi, '#')) OR SubVertical_ID IS NULL
    END
     if (@Dept_ID_Multi Is Not NUll)
    BEGIN
		DELETE FROM #Emp_Cons Where Dept_ID NOT IN (SELECT CAST(DATA AS NUMERIC) FROM dbo.Split(@Dept_ID_Multi, '#')) OR Dept_ID IS NULL
    END
    --Added By Jaina 23-09-2015 End	
  
   CREATE TABLE #Emp_Sal
	 (      
	  Emp_ID		Numeric ,     
	  Increment_ID	Numeric,
	  Grd_ID		Numeric, 
	  Basic_Salary	Numeric(18,4),
	  Gross_Salary	Numeric(18,4),
	  CTC			Numeric(18,4),
	  New_Basic_Salary Numeric(18,4),
	  New_Gross_Salary Numeric(18,4),
	  New_CTC		Numeric(18,4)
	 )      
	    
	  Insert Into #Emp_Sal   
		Select Emp_ID,Increment_ID,Grd_ID,Basic_Salary,Gross_Salary,CTC,Basic_Salary,Gross_Salary,CTC 
		From T0095_INCREMENT WITH (NOLOCK)
		Where Emp_ID IN (Select Emp_ID From #Emp_Cons) 
			  And Cmp_ID = @Cmp_ID

			
	  Delete From #Emp_Sal Where Increment_ID Not In	--Ankit 30012014
		(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
		(Select Max(Increment_ID) as Increment_ID,Emp_ID from T0095_Increment WITH (NOLOCK)
		Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
		on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_ID=new_inc.Increment_ID
		Where Increment_effective_Date <= @to_date)	


	  Declare @CurrEmp_ID	Numeric
	  Declare @Increment_ID Numeric
	  Declare @CurrGrd_ID	Numeric
	  Declare @New_Basic_Salary Numeric(18,2)
	  Declare @New_Gross_Salary Numeric(18,2)
	  Declare @New_CTC		Numeric(18,2)
	  Declare @Inc_Allowance_Amt	Numeric(18,2)
	  Declare @Basic_Per			Numeric(18,0)
	  Declare @Calc_On				Varchar(20)
	  
	  Set @Increment_ID = 0
	  Set @New_Basic_Salary = 0
	  Set @New_Gross_Salary = 0
	  Set @New_CTC = 0
	  Set @Inc_Allowance_Amt = 0
	  Set @Basic_Per = 0
	  Set @Calc_On = 0
	  	 --Added by Gadriwala Muslim 12102014
	  Declare @Basic_Salary_Upper_Rounding numeric  
	  set @Basic_Salary_Upper_Rounding = 0  
	  Select @Basic_Salary_Upper_Rounding = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Setting_Name='Bulk Increment Basic Salary Upper Rouning'
	
	  	  Declare CusrAllow cursor for	                 
			Select Emp_ID,Increment_ID,New_Basic_Salary,New_Gross_Salary,New_CTC ,Basic_Percentage,Basic_Calc_On
			From #Emp_Sal Inner Join
					T0040_GRADE_MASTER gm WITH (NOLOCK) on gm.Grd_ID = #Emp_Sal.Grd_ID
				
			Open CusrAllow
				Fetch next from CusrAllow into @CurrEmp_ID,@Increment_ID,@New_Basic_Salary,@New_Gross_Salary,@New_CTC,@Basic_Per,@Calc_On
				While @@fetch_status = 0                    
					Begin 
					
						IF @Increment_Mode = 'AMT' 
							Begin
								Set @New_Basic_Salary = @New_Basic_Salary + @Basic_Salary
								IF @ROUNDING = 1
									Set @New_Gross_Salary = Round(@New_Gross_Salary + @Gross_Salary,0)
								Else
									Set @New_Gross_Salary = @New_Gross_Salary + @Gross_Salary
									
								Set @New_CTC = @New_CTC + @CTC
							End
						Else
							Begin
								Set @New_Basic_Salary = ( @New_Basic_Salary * @Basic_Salary ) / 100 + @New_Basic_Salary
								IF @ROUNDING = 1
									Set @New_Gross_Salary = Round(( @New_Gross_Salary * @Gross_Salary ) / 100 + @New_Gross_Salary,0)
								Else
									Set @New_Gross_Salary = ( @New_Gross_Salary * @Gross_Salary ) / 100 + @New_Gross_Salary
									
								Set @New_CTC = ( @New_CTC * @CTC ) / 100 + @New_CTC
							End
						
						If @Basic_Salary = 0
							Begin 
								If @Calc_On = 'CTC'
									Begin
										set @New_Basic_Salary = isnull((@New_CTC * @Basic_Per)/100,0)
									End	
								Else if @Calc_On = 'Gross' 
									Begin
										set @New_Basic_Salary = isnull((@New_Gross_Salary * @Basic_Per)/100,0)
									End
							End	
						IF @Basic_Salary_Upper_Rounding > 0  --Added by Gadriwala Muslim 12102014
							begin
							
								if  (@New_Basic_Salary % @Basic_Salary_Upper_Rounding)  > 0
									begin
											set  @New_Basic_Salary =  @New_Basic_Salary + (@Basic_Salary_Upper_Rounding - (@New_Basic_Salary % @Basic_Salary_Upper_Rounding))
									end
							end
					
						--Select @Inc_Allowance_Amt=SUM(E_AD_AMOUNT) from T0100_EMP_EARN_DEDUCTION e inner join T0050_AD_MASTER ad on ad.AD_ID=e.AD_ID 
						--Where e.Cmp_ID=@Cmp_ID and Emp_ID=@CurrEmp_ID and Increment_ID=@Increment_ID and e.E_AD_FLAG='I' and isnull(ad.AD_NOT_EFFECT_SALARY,0)=0 --and AD_CALCULATE_ON <> 'Import'
						
						IF @Gross_Salary = 0
							Begin
								Select @Inc_Allowance_Amt=SUM(E_AD_AMOUNT) 
								From T0100_EMP_EARN_DEDUCTION e WITH (NOLOCK) inner join T0050_AD_MASTER ad WITH (NOLOCK) on ad.AD_ID=e.AD_ID 
								Where e.Cmp_ID=@Cmp_ID and Emp_ID=@CurrEmp_ID and Increment_ID=@Increment_ID and e.E_AD_FLAG='I' and isnull(ad.AD_NOT_EFFECT_SALARY,0)=0 --and AD_CALCULATE_ON <> 'Import'
								
								IF @ROUNDING = 1
									Begin
										Set @New_Gross_Salary = Round(isnull(@New_Basic_Salary,0) + ISNULL(@Inc_Allowance_Amt,0),0)
									End	
								Else
									Begin
										Set @New_Gross_Salary = isnull(@New_Basic_Salary,0) + ISNULL(@Inc_Allowance_Amt,0)
									End	
							End
							
						Update #Emp_Sal Set New_Basic_Salary = @New_Basic_Salary ,New_Gross_Salary = @New_Gross_Salary , New_CTC = @New_CTC
						Where  Emp_ID  = @CurrEmp_ID And Increment_ID = @Increment_ID
						
						fetch next from CusrAllow into @CurrEmp_ID,@Increment_ID,@New_Basic_Salary,@New_Gross_Salary,@New_CTC,@Basic_Per,@Calc_On
					End
				Close CusrAllow                    
			Deallocate CusrAllow
		
		
  Declare @Show_Left_Employee_for_Salary as tinyint
  Set @Show_Left_Employee_for_Salary = 0

  Select @Show_Left_Employee_for_Salary = Isnull(Setting_Value,0) 
  From T0040_SETTING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Setting_Name like 'Show Left Employee for Salary'
  
   If @Show_Left_Employee_for_Salary = 0  and  (isnull(@St_Date,0) = 0 or isnull(@end_date,0) = 0)
		Begin
    
		   Select I_Q.* ,E.Emp_Code, 
		   case @Emp_Search 
			when 0
				then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
			when 1
				then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 2
				then  cast( E.Alpha_Emp_Code as varchar)
			when 3
				then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 4
				then  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
			end as Emp_Full_Name
		   ,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
			 ,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
			 ,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left ,E.Alpha_Emp_Code 
			 ,dbo.F_Show_Decimal(ES.Basic_Salary,E.cmp_id) as Basic_Salary ,dbo.F_Show_Decimal(ES.Gross_Salary,E.cmp_id) as Gross_Salary,dbo.F_Show_Decimal(ES.CTC,E.Cmp_ID) as CTC,dbo.F_Show_Decimal(ES.New_Basic_Salary,E.cmp_id) as New_Basic_Salary,dbo.F_Show_Decimal(ES.New_Gross_Salary,E.cmp_id) as New_Gross_Salary ,dbo.F_Show_Decimal(ES.New_CTC,E.cmp_id) as New_CTC
		  from T0080_EMP_MASTER E WITH (NOLOCK) inner join           
			T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID left outer join          
			T0100_LEFT_EMP EL on E.Emp_Id=EL.Emp_Id inner join        
		   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Vertical_ID,SubVertical_ID from T0095_Increment I WITH (NOLOCK) inner join       --Changed By Gadriwala 18102013
			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)     
			where Increment_Effective_date <= @To_Date      
			and Cmp_ID = @Cmp_ID      
			group by emp_ID  ) Qry on      
			 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q       
			on E.Emp_ID = I_Q.Emp_ID  inner join      
			 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
			 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
			 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
			 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
			 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN     
			 T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id LEFT OUTER JOIN 
			 #Emp_Sal ES ON ES.Emp_ID = E.Emp_ID
			    
		  WHERE E.Cmp_ID = @Cmp_Id   And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
		  And Emp_Left <> 'Y' 
		   ORDER BY 
			  Case @Emp_Search 
				When 3 Then
					e.Emp_First_Name
				When 4 Then
					e.Emp_First_Name
				Else
					RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
				End
		End				
	Else
		Begin
	
		   Select I_Q.* ,E.Emp_Code, 
		   case @Emp_Search 
			when 0
				then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
			when 1
				then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 2
				then  cast( E.Alpha_Emp_Code as varchar)
			when 3
				then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 4
				then  e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
			end as Emp_Full_Name
		   ,Lo.Login_ID,E.Emp_Full_Name as Emp_Full_Name_only,Emp_superior      
			 ,E.Emp_Full_Name as Emp_Full_Name_Only,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
			 ,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left,E.Alpha_Emp_Code 
			 ,dbo.F_Show_Decimal(ES.Basic_Salary,E.cmp_id) as Basic_Salary,dbo.F_Show_Decimal(ES.Gross_Salary,E.cmp_id) as Gross_Salary,dbo.F_Show_Decimal(ES.CTC,E.Cmp_ID) as CTC,dbo.F_Show_Decimal(ES.New_Basic_Salary,E.cmp_id) as New_Basic_Salary ,dbo.F_Show_Decimal(ES.New_Gross_Salary,E.Cmp_ID) as New_Gross_Salary,dbo.F_Show_Decimal(ES.New_CTC,E.Cmp_ID) as New_CTC
			 
		  from T0080_EMP_MASTER E WITH (NOLOCK) inner join           
			T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID left outer join          
			T0100_LEFT_EMP EL on E.Emp_Id=EL.Emp_Id inner join        
		   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Vertical_ID,SubVertical_ID
				from T0095_Increment I WITH (NOLOCK) inner join    --Changed By Gadriwala 18102013    
			( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)     
			where Increment_Effective_date <= @To_Date      
			and Cmp_ID = @Cmp_ID      
			group by emp_ID  ) Qry on      
			 I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q       
			on E.Emp_ID = I_Q.Emp_ID  inner join      
			 T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
			 T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
			 T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
			 T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
			 T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID INNER JOIN     
			 T0011_Login LO  WITH (NOLOCK) ON LO.Emp_Id = E.Emp_Id INNER JOIN
			 #Emp_Sal ES ON ES.Emp_ID = E.Emp_ID
		  WHERE E.Cmp_ID = @Cmp_Id   And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
		   ORDER BY 
			  Case @Emp_Search 
				When 3 Then
					e.Emp_First_Name
				When 4 Then
					e.Emp_First_Name
				Else
					 Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
					--RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500)
				End
		  
		End	
  
 RETURN
