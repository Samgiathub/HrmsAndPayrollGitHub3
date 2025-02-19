
Create PROCEDURE [dbo].[SP_IT_EMPLOYEE_PREPARATION_GET_Ratanamani_byronakk21122022]    
  @Cmp_ID  numeric      
 ,@From_Date  datetime      
 ,@To_Date  datetime       
 ,@Branch_ID  varchar(Max) = ''     
 ,@Cat_ID     varchar(Max) = ''     
 ,@Grd_ID     varchar(Max) = ''      
 ,@Type_ID    varchar(Max) = ''      
 ,@Dept_ID    varchar(Max) = ''       
 ,@Desig_ID   varchar(Max) = ''     
 ,@Emp_ID  numeric  = 0      
 ,@Constraint varchar(MAX) = ''      
 ,@Is_IT_Declaration numeric = 0    
 ,@Salary_Cycle_id  NUMERIC  = 0 -- Added By Ali 05042014    
 ,@Segment_ID varchar(Max) = ''     
 ,@Vertical_Id varchar(Max) = ''     
 ,@SubVertical_Id varchar(Max) = ''     
 ,@SubBranch_Id varchar(Max) = ''     
 --,@Branch_ID  numeric   = 0      
 --,@Cat_ID  numeric  = 0      
 --,@Grd_ID  numeric = 0      
 --,@Type_ID  numeric  = 0      
 --,@Dept_ID  numeric  = 0      
 --,@Desig_ID  numeric = 0     
 /*    
 ,@Segment_ID Numeric = 0   -- Added By Ali 05042014     
 ,@Vertical Numeric = 0    -- Added By Ali 05042014     
 ,@SubVertical Numeric = 0   -- Added By Ali 05042014     
 ,@subBranch Numeric = 0   -- Added By Ali 05042014 */     
 ,@Format   INT = 1   --added jimit 01072016    
 ,@Regime varchar(20) = ''
AS      
 SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON   
       
      

 CREATE table #Emp_Cons     
 (          
   Emp_ID numeric ,         
  Branch_ID numeric,    
  Increment_ID numeric        
 )          
     
 exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'',0,0    

 IF @Is_IT_Declaration = 1     
  BEGIN    
     Declare @Emp_Cons_Temp Table      
     (      
      Emp_ID numeric ,     
      Branch_ID numeric,    
      Increment_ID numeric        
     )     
         
    Insert into @Emp_Cons_Temp    
     Select Emp_ID,Branch_ID,Increment_Id from #Emp_Cons where Emp_ID in (Select distinct Emp_ID from T0100_IT_DECLARATION WITH (NOLOCK)   
     where CMP_ID = @Cmp_ID And FINANCIAL_YEAR = cast(year(@From_Date) as varchar) + '-' + cast(year(@To_Date) as varchar))    
    
    Delete from #Emp_Cons    
        
    insert into #Emp_Cons    
     Select Emp_ID,Branch_ID,Increment_Id from @Emp_Cons_Temp    
       
  END     
        

  IF @Format  = 1     
   BEGIN   
	If @Regime = 'Tax Regime 1' OR @Regime = '' 
	BEGIN
		SELECT I_Q.* ,E.Alpha_Emp_Code as Alpha_Emp_Code,E.Emp_First_Name, ISNULL(E.EmpName_Alias_Tax,E.Emp_Full_Name) as Emp_Full_Name,Emp_superior      
			,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
			,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left, E.Emp_code,e.Pan_No, cast(year(@From_Date) as varchar) + '-' + cast(year(@To_Date) as varchar) as FY_year    
			,e.work_email,e.Mobile_No    
			,E.Vertical_ID,E.SubVertical_ID   --Added By Jaina 7-10-2015    
			,CASE WHEN ETR.Regime = 'Tax Regime 2' THEN 'New Regime' ELSE 'Old Regime' END AS Regime
			--,ETR.Regime AS Regime
		FROM T0080_EMP_MASTER E WITH (NOLOCK) --Left outer join  #Allowance AW on E.Emp_Id= AW.Emp_ID     
			INNER JOIN T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID 
			LEFT OUTER JOIN T0100_LEFT_EMP EL WITH (NOLOCK) on E.Emp_Id=EL.Emp_Id
			INNER JOIN
			(SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
				FROM T0095_Increment I WITH (NOLOCK) INNER JOIN       
					(SELECT max(Increment_Id) as Increment_Id , Emp_ID 
					FROM T0095_Increment WITH (NOLOCK)  --Changed by Hardik 05/09/2014 for Same Date Increment    
					WHERE Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID      
					GROUP BY Emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id) I_Q   --Changed by Hardik 05/09/2014 for Same Date Increment    
			on E.Emp_ID = I_Q.Emp_ID  INNER JOIN      
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
			T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN 
			T0095_IT_Emp_Tax_Regime ETR WITH (NOLOCK) on E.Emp_ID = ETR.Emp_ID 
			and ETR.Financial_Year = cast(year(@From_Date) as varchar) + '-' + cast(year(@To_Date) as varchar)      
		WHERE E.Cmp_ID = @Cmp_Id --   and (AW.Amount > 160000 or AW.Amount > 190000) --and Emp_Left<>'y'    
			And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
			and  (isnull(Regime,'') = Case When @Regime = '' then isnull(Regime,'')  else @Regime END OR isnull(Regime,'') = '')

		ORDER BY CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)    
			WHEN IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)    
				ELSE e.Alpha_Emp_Code END    
	END
	ELSE
	BEGIN
		SELECT I_Q.* ,E.Alpha_Emp_Code as Alpha_Emp_Code,E.Emp_First_Name, ISNULL(E.EmpName_Alias_Tax,E.Emp_Full_Name) as Emp_Full_Name,Emp_superior      
			,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender      
			,BM.Comp_Name,BM.Branch_Address,CM.Cmp_Name,Cm.Cmp_address,E.Emp_Left, E.Emp_code,e.Pan_No, cast(year(@From_Date) as varchar) + '-' + cast(year(@To_Date) as varchar) as FY_year    
			,e.work_email,e.Mobile_No    
			,E.Vertical_ID,E.SubVertical_ID   --Added By Jaina 7-10-2015    
			,CASE WHEN ETR.Regime = 'Tax Regime 2' THEN 'New Regime' ELSE 'Old Regime' END AS Regime
			--,ETR.Regime AS Regime
		FROM T0080_EMP_MASTER E WITH (NOLOCK) --Left outer join  #Allowance AW on E.Emp_Id= AW.Emp_ID     
			INNER JOIN T0010_company_master Cm WITH (NOLOCK) on E.Cmp_ID = Cm.Cmp_ID 
			LEFT OUTER JOIN T0100_LEFT_EMP EL WITH (NOLOCK) on E.Emp_Id=EL.Emp_Id
			INNER JOIN
			(SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
				FROM T0095_Increment I WITH (NOLOCK) INNER JOIN       
					(SELECT max(Increment_Id) as Increment_Id , Emp_ID 
					FROM T0095_Increment WITH (NOLOCK)  --Changed by Hardik 05/09/2014 for Same Date Increment    
					WHERE Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID      
					GROUP BY Emp_ID  ) Qry on I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id) I_Q   --Changed by Hardik 05/09/2014 for Same Date Increment    
			on E.Emp_ID = I_Q.Emp_ID  INNER JOIN      
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN      
			T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN      
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN      
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN       
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN 
			T0095_IT_Emp_Tax_Regime ETR WITH (NOLOCK) on E.Emp_ID = ETR.Emp_ID 
			and ETR.Financial_Year = cast(year(@From_Date) as varchar) + '-' + cast(year(@To_Date) as varchar)      
		WHERE E.Cmp_ID = @Cmp_Id --   and (AW.Amount > 160000 or AW.Amount > 190000) --and Emp_Left<>'y'    
			And E.Emp_ID in (select Emp_ID From #Emp_Cons) 
			and  isnull(Regime,'') = Case When @Regime = '' then isnull(Regime,'')  else @Regime END 
		ORDER BY CASE WHEN IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)    
			WHEN IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)    
				ELSE e.Alpha_Emp_Code END    
	END

    END   -- Format 1 end 
   --added jimit 01072016    
   ELSE IF @Format = 0      
	BEGIN    
	
		Declare @IT_ID_Exempt_U_S10 numeric(18,0)    
		DECLARE @IT_ID_80C  VARCHAR(50)    
		DECLARE @IT_ID_HRA  VARCHAR(50)    
		DECLARE @Financial_Year varchar(50)    
		SET @Financial_Year = ''       
      
		DECLARE @IT_ID_Other  VARCHAR(50)    
      
		DECLARE @IT_ID_HOUSING_LOAN AS NUMERIC    
		SELECT @IT_ID_HOUSING_LOAN =  IT_ID from T0070_IT_master WITH (NOLOCK) where  IT_Name LIKE '%Housing Loan%' and IT_Def_ID= 153 and Cmp_ID= @Cmp_ID    
      
		DECLARE @IT_ID_LTA AS NUMERIC    
		SELECT @IT_ID_LTA = AD_ID FROM T0050_AD_MASTER WITH (NOLOCK) WHERE AD_NAME LIKE '%LTA NT%' AND CMP_ID= @CMP_ID    
      
		SET @Financial_Year = CONVERT(varchar(20),YEAR(@From_Date)) + '-' + CONVERT(varchar(20),YEAR(@To_Date))       
		SELECT @IT_ID_Exempt_U_S10 = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = 'Exempt. U|S 10' and Cmp_ID = @Cmp_Id    
      
		SELECT @IT_ID_HRA = IT_ID from T0070_IT_MASTER  WITH (NOLOCK)    
		Where (IT_Name LIKE '%HRA%' or IT_Name LIKE '%Housing Rent%' or IT_Name LIKE '%House Rent%')     
			and Cmp_ID = @Cmp_Id and IT_Parent_ID = @IT_ID_Exempt_U_S10    

		select @IT_ID_80C = IT_ID from T0070_IT_master WITH (NOLOCK) where IT_Name = '80 C' and Cmp_ID = @Cmp_ID    
		select @IT_ID_80C = @IT_ID_80C + '#' + cast(IT_ID as varchar) from T0070_IT_master WITH (NOLOCK) where IT_Name = '80CCC' and Cmp_ID = @Cmp_ID    
		select @IT_ID_80C = @IT_ID_80C + '#' + cast(IT_ID as varchar) from T0070_IT_master WITH (NOLOCK) where IT_Name = '80 CCD' and Cmp_ID = @Cmp_ID    
      
		SELECT @IT_ID_Other = IT_ID from T0070_IT_MASTER WITH (NOLOCK) where IT_Name = '80 G' and Cmp_ID = @cmp_Id    
		SELECT @IT_ID_Other = @IT_ID_Other + '#' + cast(IT_ID as varchar) from T0070_IT_MASTER WITH (NOLOCK) where IT_Name = 'Chapter VI A' and Cmp_ID = @cmp_Id      
        
		
		Select --IED.BankName,IED.Detail_1,IED.Detail_2,IED.Detail_3,IED.Date,IED.Comments, --Comment by ronakk 21122022
		Em.emp_Id,Em.Alpha_Emp_Code,Emp_Full_Name,Em.Present_Street,Em.Pan_No,@Financial_Year as financial_Year,isnull(Bm.Branch_City,cm.Cmp_City) as City,Em.Father_name,   
			Dm.Desig_Name,IT.IT_Name,SUM(ISnull(ITD.AMOUNT,0)) as Amount,IT.Cmp_ID,IT.IT_ID,IT.IT_Parent_ID,    
			(case when It.IT_Parent_ID in (Select cast(data  as numeric) from dbo.Split (@IT_ID_80C,'#')) then '80 C'    
				when  It.IT_Parent_ID in (Select cast(data  as numeric) from dbo.Split (@IT_ID_Other,'#')) then 'Other'    
				end) as Name    
			,Qry.Rent_Amount    
				,qr.LTA  
			,case when ETR.Regime = 'Tax Regime 2' then 'New Regime' else 'Old Regime' end as Regime  
		from T0100_IT_DECLARATION ITD  WITH (NOLOCK)
		inner JOIN T0070_IT_MASTER IT  WITH (NOLOCK) On ITD.IT_ID = It.IT_ID 
		INNER JOIN  #Emp_Cons EC On Ec.Emp_ID = ITD.EMP_ID
		inner JOIN  T0080_EMP_MASTER Em WITH (NOLOCK) On Ec.Emp_ID = EM.Emp_ID 
		inner JOIN (SELECT I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,TYPE_ID FROM T0095_Increment I WITH (NOLOCK) INNER JOIN         
				(SELECT MAX(Increment_ID) AS Increment_ID , Emp_ID FROM T0095_Increment WITH (NOLOCK)        
				WHERE Increment_Effective_date <= @To_Date        
				AND Cmp_ID = @Cmp_ID        
				GROUP BY emp_ID  ) Qry ON        
				I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID  ) I_Q  ON EM.Emp_ID = I_Q.Emp_ID 
		Left Outer JOIN  T0040_DESIGNATION_MASTER Dm WITH (NOLOCK) On Dm.Desig_ID = I_Q.Desig_Id
		INNER JOIN  T0030_BRANCH_MASTER Bm WITH (NOLOCK) On Bm.Branch_ID = I_Q.Branch_ID 
		--inner join T0110_IT_Emp_Details IED WITH (NOLOCK) On IED.IT_ID = IT.IT_ID  --Comment by ronakk 21122022
		--and
		--IED.Financial_Year =ITD.FINANCIAL_YEAR
		--and IED.Emp_ID =ITD.EMP_ID
		inner JOIN  T0010_COMPANY_MASTER Cm WITH (NOLOCK) on cm.Cmp_Id = Em.Cmp_ID 
		Left Outer JOIN (  Select IsNull(ItE.Amount,0) as Rent_Amount,EC.Emp_ID    
							FROM    #Emp_Cons EC Inner JOIN                
							T0100_IT_DECLARATION ItE WITH (NOLOCK) On  EC.Emp_ID = ITe.EMP_ID    
							where   ItE.IT_ID = @IT_ID_HOUSING_LOAN and    
								ItE.Cmp_Id = @Cmp_Id    
							and ItE.Financial_Year = @Financial_Year           
							)QRY On QRY.Emp_ID = EC.Emp_ID  
							Left Outer JOIN (  Select EC.Emp_ID,sum(Isnull(rc.Tax_Free_amount,0)) as LTA    
									from T0210_Monthly_Reim_Detail RC WITH (NOLOCK) 
									INNER JOIN   #Emp_Cons EC On Ec.Emp_ID = Rc.Emp_ID    
									where RC.RC_ID = @IT_ID_LTA and RC.for_Date BETWEEN @From_date and @To_Date     
									GROUP by EC.Emp_ID    
									)Qr On qr.Emp_ID = Ec.Emp_ID  
		left outer join T0095_IT_Emp_Tax_Regime ETR WITH (NOLOCK) on EC.Emp_ID = ETR.Emp_ID and ETR.Financial_Year = @Financial_Year  
		where  IT.Cmp_ID = @cmp_Id and (    
			IT_Parent_ID in (Select cast(data  as numeric) from dbo.Split (@IT_ID_80C,'#')) or     
			IT_Parent_ID in (Select cast(data  as numeric) from dbo.Split (@IT_ID_Other,'#')))     
			and ITD.FINANCIAL_YEAR = @Financial_Year   
			and (isnull(Regime,'') = @Regime or isnull(@Regime ,'') = '')
			
		group by Em.emp_Id,Em.Alpha_Emp_Code,Emp_Full_Name,Em.Present_Street,Em.Pan_No,Em.City,Em.Father_name,Dm.Desig_Name,It_Name,IT.Cmp_ID,IT.IT_ID,IT_Parent_ID    
			,Bm.Branch_City,Cm.Cmp_City,QRY.Rent_Amount,qr.LTA ,ETR.Regime --,IED.BankName ,IED.Detail_1,IED.Detail_2,IED.Detail_3,IED.Date,IED.Comments --Comment by ronakk 21122022
         
      
           
		Select IeD.Emp_Id,IED.Detail_2 as Address_Of_Landlord    
		,IED.Detail_3 as Lanlord_Pan_No,IED.Detail_1 as Name_Of_The_LandLord,Sum(IsNull(ItE.Amount,0)) as Rent_Amount    
		FROM    #Emp_Cons EC Inner JOIN        
		T0110_IT_Emp_Details IED WITH (NOLOCK) On IED.Emp_ID = Ec.Emp_ID inner JOIN    
		T0100_IT_DECLARATION ItE WITH (NOLOCK) On Ite.IT_ID = IEd.IT_ID and Ied.Emp_ID = ITe.EMP_ID and Ied.Financial_Year = Ite.Financial_Year    
		where   ied.IT_ID = @IT_ID_HRA and    
			IED.Cmp_Id = @Cmp_Id    
		and Ied.Financial_Year = @Financial_Year     
		GROUP By  IeD.Emp_Id,IED.Detail_2,IED.Detail_3 ,IED.Detail_1         
         
		--Select  IT.IT_Name,SUM(ISnull(ITD.AMOUNT,0)) as Amount,ITD.EMP_ID,IT.Cmp_ID    
		--from T0070_IT_MASTER IT inner JOIN    
		--  T0100_IT_DECLARATION ITD On ITD.IT_ID = It.IT_ID INNER JOIN    
		--  #Emp_Cons EC On Ec.Emp_ID = ITD.EMP_ID    
		--where  It.Cmp_ID = @cmp_Id and IT_Parent_ID in (Select cast(data  as numeric) from dbo.Split (@IT_ID_Chapter_VI,'#'))      
		--  and ITD.FINANCIAL_YEAR = @Financial_Year    
		--group by Itd.emp_Id,It_Name,IT.Cmp_ID       
		--ended    
        
	END    
        
        
 RETURN      
      
      
    
