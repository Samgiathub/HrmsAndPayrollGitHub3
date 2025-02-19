
  
  
CREATE PROCEDURE [dbo].[SP_RPT_FORMVI_A_Notice_GET_BKronakb230724]  
  @Cmp_ID  Numeric  
 ,@From_Date  Datetime  
 ,@To_Date  Datetime  
 ,@Branch_ID  varchar(max) = ''  
 ,@Cat_ID  varchar(max) = ''  
 ,@Grd_ID  varchar(max) = ''  
 ,@Type_ID  varchar(max) = ''  
 ,@Dept_ID  varchar(max) = ''  
 ,@Desig_ID  varchar(max) = ''  
 ,@Emp_ID  Numeric  
 ,@Constraint varchar(MAX)  
 ,@Salary_Cycle_id numeric = NULL  
 ,@Segment_Id  varchar(max) = ''    
 ,@Vertical_Id varchar(max) = ''    
 ,@SubVertical_Id varchar(max) = ''    
 ,@SubBranch_Id varchar(max) = ''    
 --,@Format    varchar(10) = ''  
 --,@Status Varchar(10) = 'All'  
 ,@flag   int=0  
 ,@ReportType varchar(MAX)  
 ,@New_Join_emp numeric = 0   
 ,@Left_Emp  Numeric = 0  
AS  
 Set Nocount on   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET ARITHABORT ON  
  
 CREATE table #Emp_Cons   
    (        
       Emp_ID numeric ,       
       Branch_ID numeric,  
       Increment_ID numeric      
 )        
   
    exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,@New_Join_emp,@Left_Emp,0,'0',0,0 
 
 
 Declare @Qry varchar(max)  
 Declare @JoinBranch varchar(max)  
   
 if @Branch_ID <> ''    
    Begin     
     Set @JoinBranch = ' and ISNULL(BR.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(''' + Cast(@Branch_ID AS varchar(max)) + ''',ISNULL(BR.Branch_ID,0)),''#'') ) '    
    End  
 Else  
 Begin  
 Set @JoinBranch = ''  
 End
 
 if @Branch_ID =''
	set @Branch_ID =null
   
  IF @ReportType='FORMVI-Anotice'   
   BEGIN  
    SET @QRY = '	SELECT	CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
							CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
							BR.Branch_Name,BR.Branch_ID,BR.Branch_Address,
							--Case when Isnull(BR.Comp_Name,'''') <> '''' then BR.Comp_Name Else CM.Cmp_Name End Cmp_Name ,
							CM.Cmp_Name as Cmp_Name,
							BR.Comp_Name,
							CM.Cmp_Address,
							--Case when Isnull(BR.Comp_Name,'''') <> '''' then BR.Branch_Address Else CM.Cmp_Address End Cmp_Address, 
							
							CDM.No_Of_LabourEmployed,CDM.Vendor_Code    
							,CM.Cmp_ID as Cmp_ID
					FROM	T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
							Inner join (
											select	MAX(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID 
											from	T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
													inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID  and BR.Cmp_ID = ' + Cast(@Cmp_ID As Varchar(100)) + '
											where	(
														(CDM.Date_Of_Termination between ''' + Cast(@From_Date As Varchar(100)) + ''' and ''' + Cast(@To_Date As Varchar(100)) + ''' )  
														or (''' + Cast(@From_Date As Varchar(100)) + ''' between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
														or (''' + Cast(@To_Date As Varchar(100)) + ''' between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
														or (CDM.Date_Of_Commencement between ''' + Cast(@From_Date As Varchar(100)) + ''' and ''' + Cast(@To_Date As Varchar(100)) + ''' )
													)
											group by BR.Branch_ID 
										) I_Q on I_Q.Branch_ID = CDM.Branch_ID and I_Q.Date_Of_Termination = CDM.Date_Of_Termination  
							Inner JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=CDM.Branch_ID   
							INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=BR.Cmp_ID  
					WHERE	CM.Cmp_ID = ' + Cast(@Cmp_ID As Varchar(100)) + ' '+@JoinBranch+  
							' and ((CDM.Date_Of_Termination between ''' + Cast(@From_Date As Varchar(100)) + ''' and ''' + Cast(@To_Date As Varchar(100)) + ''' )  
							or (''' + Cast(@From_Date As Varchar(100)) + ''' between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
							or (''' + Cast(@To_Date As Varchar(100)) + ''' between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
							or (CDM.Date_Of_Commencement between ''' + Cast(@From_Date As Varchar(100)) + ''' and ''' + Cast(@To_Date As Varchar(100)) + ''' ))
					group by CDM.Contr_PersonName,CDM.Nature_Of_Work,CDM.Date_Of_Commencement,BR.Branch_Name,  
							BR.Branch_ID,BR.Branch_Address,BR.Comp_Name,CM.Cmp_Name,CM.Cmp_Address,CDM.Date_Of_Termination,CM.Cmp_ID,  
							CDM.No_Of_LabourEmployed,CDM.Vendor_Code '  
  
    Exec(@Qry)  
     
   END  
  ELSE IF @ReportType='FORMXIIRegisterContractor'   
   BEGIN  
    SET @Qry = 'SELECT CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
       CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
      BR.Branch_Name,BR.Branch_ID,BR.Branch_Address,
	  CM.Cmp_Name as Cmp_Name,
	  BR.Comp_Name,
	  CM.Cmp_Address,
	  --Case when Isnull(BR.Comp_Name,'''') <> '''' then BR.Comp_Name Else CM.Cmp_Name End Cmp_Name ,
	   --Case when Isnull(BR.Comp_Name,'''') <> '''' then BR.Branch_Address Else CM.Cmp_Address End Cmp_Address, 
	  --CM.Cmp_Name ,CM.Cmp_Address,  
      CDM.No_Of_LabourEmployed   
       FROM T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
       Inner join (select max(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
     inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID = ' + Cast(@Cmp_ID As Varchar(100)) + ' 
	  where ((CDM.Date_Of_Termination between ''' + Cast(@From_Date As Varchar(100)) + ''' and ''' + Cast(@To_Date As Varchar(100)) + ''' )  
       or (''' + Cast(@From_Date As Varchar(100)) + ''' between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (''' + Cast(@To_Date As Varchar(100)) + ''' between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (CDM.Date_Of_Commencement between ''' + Cast(@From_Date As Varchar(100)) + ''' and ''' + Cast(@To_Date As Varchar(100)) + ''' ))
     group by BR.Branch_ID ) I_Q on I_Q.Branch_ID = CDM.Branch_ID and I_Q.Date_Of_Termination = CDM.Date_Of_Termination  
       Inner JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=CDM.Branch_ID  
       INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=BR.Cmp_ID  
       WHERE CM.Cmp_ID = ' + Cast(@Cmp_ID As Varchar(100)) + ''+@JoinBranch+' and ((CDM.Date_Of_Termination between ''' + Cast(@From_Date As Varchar(100)) + ''' and ''' + Cast(@To_Date As Varchar(100)) + ''' )  
       or (''' + Cast(@From_Date As Varchar(100)) + ''' between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (''' + Cast(@To_Date As Varchar(100)) + ''' between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (CDM.Date_Of_Commencement between ''' + Cast(@From_Date As Varchar(100)) + ''' and ''' + Cast(@To_Date As Varchar(100)) + ''' ))group by CDM.Contr_PersonName,CDM.Nature_Of_Work,CDM.Date_Of_Commencement,BR.Branch_Name,  
       BR.Branch_ID,BR.Branch_Address,BR.Comp_Name,CM.Cmp_Name,CM.Cmp_Address,CDM.Date_Of_Termination,  
      CDM.No_Of_LabourEmployed '  
      
    Exec(@Qry)  
     
   End  
  ELSE IF @ReportType='FORMXIV_Employment_card'   
   BEGIN  
    SELECT EMP.Emp_First_Name + ' '+ isnull(EMP.Emp_Second_Name,'') + ' ' + isnull(EMP.Emp_Last_Name,'') AS Emp_Full_Name,  
     EMP.Emp_Code,EMP.Alpha_Emp_Code,DESIG.Desig_Name,  
     CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
       CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
       BR.Branch_Name,BR.Branch_ID,BR.Branch_Address, 
	   CM.Cmp_Name as Cmp_Name,
	   BR.Comp_Name,
	   CM.Cmp_Address,
	   --Case when Isnull(BR.Comp_Name,'') <> '' then BR.Comp_Name Else CM.Cmp_Name End Cmp_Name ,
	   --Case when Isnull(BR.Comp_Name,'') <> '' then BR.Branch_Address Else CM.Cmp_Address End Cmp_Address,
       --CM.Cmp_Name ,CM.Cmp_Address,  
       CDM.No_Of_LabourEmployed, EMP.Date_Of_Join,I_Q.Wages_Type,I_Q.Gross_Salary   
       FROM   
       T0080_EMP_MASTER EMP WITH (NOLOCK)   
       inner join  
      ( select I.Emp_Id ,Branch_ID,Desig_ID,Dept_ID,Cmp_ID,Wages_Type,Gross_Salary    
        from dbo.T0095_Increment I WITH (NOLOCK) inner join   
        ( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment  
        where Increment_Effective_date <= @To_Date  
        and Cmp_ID = @Cmp_ID  
        group by emp_ID  ) Qry on  
        I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q   
       on EMP.Emp_ID = I_Q.Emp_ID  
       Inner JOIN T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) on CDM.Branch_ID = I_Q.Branch_ID  
       Inner join (select max(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
     inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID = @Cmp_ID 
	 where ((CDM.Date_Of_Termination between @From_Date and @To_Date)  
       or (@From_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (@To_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (CDM.Date_Of_Commencement between @From_Date and @To_Date ))
     group by BR.Branch_ID,BR.Branch_Name,BR.Branch_Address ) C on I_Q.Branch_ID = CDM.Branch_ID and C.Date_Of_Termination = CDM.Date_Of_Termination  
       inner JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=C.Branch_ID   
       INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=I_Q.Cmp_ID  
       Inner join T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON DESIG.Desig_ID = I_Q.Desig_Id and I_Q.Cmp_ID = DESIG.Cmp_ID   
       Inner Join   
      #Emp_Cons EC on EMP.Emp_ID = EC.Emp_ID  
       WHERE CM.Cmp_ID = @Cmp_ID  
       --and CDM.Date_Of_Termination between @From_Date and @To_Date  
       and ((CDM.Date_Of_Termination between @From_Date and @To_Date)  
       or (@From_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (@To_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (CDM.Date_Of_Commencement between @From_Date and @To_Date ))  
      
   END  
  ELSE IF @ReportType='FORMXV_Service_Certificate'   
   BEGIN  
    SELECT EMP.Emp_First_Name + ' '+ isnull(EMP.Emp_Second_Name,'') + ' ' + isnull(EMP.Emp_Last_Name,'') AS Emp_Full_Name,  
     EMP.Emp_Code,EMP.Alpha_Emp_Code,DESIG.Desig_Name,EMP.Date_Of_Birth,EMP.Emp_Mark_Of_Identification,EMP.Father_name,  
     CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
       CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
       BR.Branch_Name,BR.Branch_ID,BR.Branch_Address,
	    CM.Cmp_Name as Cmp_Name,
	  BR.Comp_Name,
	  CM.Cmp_Address,
	   --Case when Isnull(BR.Comp_Name,'') <> '' then BR.Comp_Name Else CM.Cmp_Name End Cmp_Name ,
	   --Case when Isnull(BR.Comp_Name,'') <> '' then BR.Branch_Address Else CM.Cmp_Address End Cmp_Address,
       --CM.Cmp_Name ,CM.Cmp_Address,  
       CDM.No_Of_LabourEmployed, EMP.Date_Of_Join,I_Q.Wages_Type,I_Q.Gross_Salary   
       FROM   
       T0080_EMP_MASTER EMP WITH (NOLOCK)   
       inner join  
      ( select I.Emp_Id ,Branch_ID,Desig_ID,Dept_ID,Cmp_ID,Wages_Type,Gross_Salary    
        from dbo.T0095_Increment I WITH (NOLOCK) inner join   
        ( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment  
        where Increment_Effective_date <= @To_Date  
        and Cmp_ID = @Cmp_ID  
        group by emp_ID  ) Qry on  
        I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q   
       on EMP.Emp_ID = I_Q.Emp_ID  
       Inner JOIN T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) on CDM.Branch_ID = I_Q.Branch_ID  
       Inner join (select max(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
     inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID = @Cmp_ID  
	 where ((CDM.Date_Of_Termination between @From_Date and @To_Date)  
       or (@From_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (@To_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (CDM.Date_Of_Commencement between @From_Date and @To_Date ))
     group by BR.Branch_ID,BR.Branch_Name,BR.Branch_Address ) C on I_Q.Branch_ID = CDM.Branch_ID and C.Date_Of_Termination = CDM.Date_Of_Termination  
       LEFT JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=I_Q.Branch_ID  
       INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=I_Q.Cmp_ID  
       Inner join T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON DESIG.Desig_ID = I_Q.Desig_Id and I_Q.Cmp_ID = DESIG.Cmp_ID  
       Inner Join T0100_LEFT_EMP LFT WITH (NOLOCK) ON LFT.Emp_ID = EMP.Emp_ID and LFT.Cmp_ID = CM.Cmp_Id   
       Inner Join    
      #Emp_Cons EC on EMP.Emp_ID = EC.Emp_ID  
       WHERE CM.Cmp_ID = @Cmp_ID  
       and ((CDM.Date_Of_Termination between @From_Date and @To_Date)  
       or (@From_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (@To_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (CDM.Date_Of_Commencement between @From_Date and @To_Date ))  
       --and LFT.Is_Terminate = 1  
   End  
   ELSE IF @ReportType='FORM_XXII_Register_of_advances'   
   BEGIN
 
	 
    SELECT DISTINCT EMP.Emp_Id,EMP.Emp_First_Name + ' '+ isnull(EMP.Emp_Second_Name,'') + ' ' + isnull(EMP.Emp_Last_Name,'') AS Emp_Full_Name,  
		EMP.Emp_Code,EMP.Alpha_Emp_Code,DESIG.Desig_Name,  
		CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
		CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
		BR.Branch_Name,BR.Branch_ID,BR.Branch_Address, 
		CM.Cmp_Name as Cmp_Name,
		BR.Comp_Name,
		CM.Cmp_Address,
		CDM.No_Of_LabourEmployed, EMP.Date_Of_Join,I_Q.Wages_Type,I_Q.Gross_Salary,EMP.Father_name,
		ADVT.Adv_Amount,ADVT.For_Date,Adv_Comments,ADVReturn.Adv_Return,ADVReturn.For_Date
	FROM T0080_EMP_MASTER EMP WITH (NOLOCK)   
       INNER JOIN  
		  ( select I.Emp_Id ,Branch_ID,Desig_ID,Dept_ID,Cmp_ID,Wages_Type,Gross_Salary    
			from dbo.T0095_Increment I WITH (NOLOCK) inner join   
			( select max(T0095_Increment.Increment_ID) as Increment_ID , T0095_Increment.Emp_ID 
			from dbo.T0095_Increment WITH (NOLOCK) -- Ankit 10092014 for Same Date Increment  
				Inner Join #Emp_Cons EC on T0095_Increment.Emp_ID = EC.Emp_ID
			where Increment_Effective_date <= @To_Date  
			and Cmp_ID = @Cmp_ID  
			group by T0095_Increment.emp_ID  ) Qry on  
			I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q  on EMP.Emp_ID = I_Q.Emp_ID  
       Inner JOIN T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) on CDM.Branch_ID = I_Q.Branch_ID  
       INNER JOIN 
			(SELECT MAX(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
			     inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID = @Cmp_ID 
			 WHERE ((CDM.Date_Of_Termination between @From_Date and @To_Date)  
			   or (@From_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
			   or (@To_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
			   or (CDM.Date_Of_Commencement between @From_Date and @To_Date ))
			 GROUP BY BR.Branch_ID,BR.Branch_Name,BR.Branch_Address ) C on I_Q.Branch_ID = CDM.Branch_ID and C.Date_Of_Termination = CDM.Date_Of_Termination  
       INNER JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=C.Branch_ID AND BR.Branch_ID = I_Q.Branch_ID  
       INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=I_Q.Cmp_ID  
       INNER JOIN T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON DESIG.Desig_ID = I_Q.Desig_Id and I_Q.Cmp_ID = DESIG.Cmp_ID
	   LEFT JOIN T0100_ADVANCE_PAYMENT ADVT WITH (NOLOCK) ON ADVT.Emp_ID = I_Q.Emp_ID and Month(ADVT.For_Date) = Month(@From_Date) and Year(ADVT.For_Date) = Year(@From_Date)
	   LEFT JOIN T0140_ADVANCE_TRANSACTION ADVReturn WITH (NOLOCK) on ADVReturn.Emp_ID = I_Q.Emp_ID and Month(ADVReturn.For_Date) = Month(@From_Date) and Year(ADVReturn.For_Date) = Year(@From_Date) and ADVReturn.Adv_Return <> 0
       INNER JOIN #Emp_Cons EC on EMP.Emp_ID = EC.Emp_ID  
       WHERE CM.Cmp_ID = @Cmp_ID  
		   --and CDM.Date_Of_Termination between @From_Date and @To_Date  
		   and ((CDM.Date_Of_Termination between @From_Date and @To_Date)  
		   or (@From_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date and @To_Date ))  
   END
   ELSE IF @ReportType='FORM_XVII_Register_of_wages'   
   BEGIN
    SELECT EMP.Emp_First_Name + ' '+ isnull(EMP.Emp_Second_Name,'') + ' ' + isnull(EMP.Emp_Last_Name,'') AS Emp_Full_Name,  
     EMP.Emp_Code,EMP.Alpha_Emp_Code,DESIG.Desig_Name,  
     CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
       CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
       BR.Branch_Name,BR.Branch_ID,BR.Branch_Address, 
	   CM.Cmp_Name as Cmp_Name,
	  BR.Comp_Name,
	  CM.Cmp_Address,
       CDM.No_Of_LabourEmployed, EMP.Date_Of_Join,I_Q.Wages_Type,I_Q.Gross_Salary ,MS.Sal_Cal_Days, Working_Days,MS.Basic_Salary,OT_Amount,
	   Advance_Amount,PT_Amount,LWF_Amount,Salary_Amount
       FROM   
       T0080_EMP_MASTER EMP WITH (NOLOCK)   
       inner join  
      ( select I.Emp_Id ,Branch_ID,Desig_ID,Dept_ID,Cmp_ID,Wages_Type,Gross_Salary    
        from dbo.T0095_Increment I WITH (NOLOCK) inner join   
        ( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
        where Increment_Effective_date <= @To_Date  
        and Cmp_ID = @Cmp_ID  
        group by emp_ID  ) Qry on  
        I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q   
       on EMP.Emp_ID = I_Q.Emp_ID  
       Inner JOIN T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) on CDM.Branch_ID = I_Q.Branch_ID  
       Inner join (select max(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
     inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID = @Cmp_ID 
	 where ((CDM.Date_Of_Termination between @From_Date and @To_Date)  
       or (@From_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (@To_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (CDM.Date_Of_Commencement between @From_Date and @To_Date ))
     group by BR.Branch_ID,BR.Branch_Name,BR.Branch_Address ) C on I_Q.Branch_ID = CDM.Branch_ID and C.Date_Of_Termination = CDM.Date_Of_Termination  
       inner JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=C.Branch_ID   
       INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=I_Q.Cmp_ID  
       Inner join T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON DESIG.Desig_ID = I_Q.Desig_Id and I_Q.Cmp_ID = DESIG.Cmp_ID  
	   inner join T0200_MONTHLY_SALARY MS on MS.Emp_ID = I_Q.Emp_ID and MONTH(MS.Month_St_Date) = Month(@From_Date) and Year(MS.Month_St_Date) = Year(@From_Date)
      Inner Join    
      #Emp_Cons EC on EMP.Emp_ID = EC.Emp_ID   
       WHERE CM.Cmp_ID = @Cmp_ID  
       and ((CDM.Date_Of_Termination between @From_Date and @To_Date)  
       or (@From_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (@To_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (CDM.Date_Of_Commencement between @From_Date and @To_Date )) 
   END
 ELSE IF @ReportType='FORM_XXIII_Register_of_overtime'   
   BEGIN
    SELECT EMP.Emp_First_Name + ' '+ isnull(EMP.Emp_Second_Name,'') + ' ' + isnull(EMP.Emp_Last_Name,'') AS Emp_Full_Name,  
     EMP.Emp_Code,EMP.Alpha_Emp_Code,DESIG.Desig_Name,  
     CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
       CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
       BR.Branch_Name,BR.Branch_ID,BR.Branch_Address, 
	   CM.Cmp_Name as Cmp_Name,
	  BR.Comp_Name,
	  CM.Cmp_Address,
       CDM.No_Of_LabourEmployed, EMP.Date_Of_Join,I_Q.Wages_Type,I_Q.Gross_Salary,--MS.Sal_Cal_Days, Working_Days,
	   MS.Basic_Salary,OT_Amount,OT.For_Date as OT_Date,OT.Approved_OT_Hours,Emp.Father_name,Emp.Gender,MS.Month_End_Date
	   --Advance_Amount,PT_Amount,LWF_Amount,Salary_Amount
       FROM   
       T0080_EMP_MASTER EMP WITH (NOLOCK)   
       inner join  
      ( select I.Emp_Id ,Branch_ID,Desig_ID,Dept_ID,Cmp_ID,Wages_Type,Gross_Salary    
        from dbo.T0095_Increment I WITH (NOLOCK) inner join   
        ( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
        where Increment_Effective_date <= @To_Date  
        and Cmp_ID = @Cmp_ID  
        group by emp_ID  ) Qry on  
        I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q   
       on EMP.Emp_ID = I_Q.Emp_ID  
       Inner JOIN T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) on CDM.Branch_ID = I_Q.Branch_ID  
       Inner join (select max(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
     inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID = @Cmp_ID 
	 where ((CDM.Date_Of_Termination between @From_Date and @To_Date)  
       or (@From_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (@To_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (CDM.Date_Of_Commencement between @From_Date and @To_Date ))
     group by BR.Branch_ID,BR.Branch_Name,BR.Branch_Address ) C on I_Q.Branch_ID = CDM.Branch_ID and C.Date_Of_Termination = CDM.Date_Of_Termination  
       inner JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=C.Branch_ID   
       INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=I_Q.Cmp_ID  
       Inner join T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON DESIG.Desig_ID = I_Q.Desig_Id and I_Q.Cmp_ID = DESIG.Cmp_ID  
	   inner join T0200_MONTHLY_SALARY MS on MS.Emp_ID = I_Q.Emp_ID and MONTH(MS.Month_St_Date) = Month(@From_Date) and Year(MS.Month_St_Date) = Year(@From_Date)
	   inner join T0160_OT_APPROVAL OT on OT.Emp_ID = I_Q.Emp_ID and Month(OT.For_Date) = Month(@From_Date) and Year(OT.For_Date) = Year(@From_Date)
	   Inner Join    
      #Emp_Cons EC on EMP.Emp_ID = EC.Emp_ID   
       WHERE CM.Cmp_ID = @Cmp_ID  
       and ((CDM.Date_Of_Termination between @From_Date and @To_Date)  
       or (@From_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (@To_Date between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
       or (CDM.Date_Of_Commencement between @From_Date and @To_Date )) 
   End
ELSE IF @ReportType='FORM_XX_Reg_Deduction'   
	BEGIN
		SELECT DISTINCT EMP.Emp_Id,EMP.Emp_First_Name + ' '+ isnull(EMP.Emp_Second_Name,'') + ' ' + isnull(EMP.Emp_Last_Name,'') AS Emp_Full_Name,  
			EMP.Emp_Code,EMP.Alpha_Emp_Code,DESIG.Desig_Name,  
			QRY1.Contr_PersonName ContractorName,QRY1.Nature_Of_Work,  
			QRY1.Date_Of_Commencement,QRY1.Date_Of_Termination,  
			BR.Branch_Name,BR.Branch_ID,BR.Branch_Address, 
			CM.Cmp_Name as Cmp_Name,
			BR.Comp_Name,
			CM.Cmp_Address,
			QRY1.No_Of_LabourEmployed, EMP.Date_Of_Join,I_Q.Wages_Type,I_Q.Gross_Salary,EMP.Father_name
		FROM T0080_EMP_MASTER EMP WITH (NOLOCK)   
			INNER JOIN  
				( SELECT I.Emp_Id ,Branch_ID,Desig_ID,Dept_ID,Cmp_ID,Wages_Type,Gross_Salary    
					FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN   
						(SELECT MAX(T0095_Increment.Increment_ID) as Increment_ID , T0095_Increment.Emp_ID 
						FROM dbo.T0095_Increment WITH (NOLOCK)
							Inner Join #Emp_Cons EC on T0095_Increment.Emp_ID = EC.Emp_ID
						WHERE Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID  
						group by T0095_Increment.emp_ID  ) Qry on  
				I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q  on EMP.Emp_ID = I_Q.Emp_ID  
--			INNER JOIN T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) on CDM.Branch_ID = I_Q.Branch_ID  
			LEFT OUTER JOIN 
				(SELECT Branch_Id, CDM.Contr_PersonName,CDM.Nature_Of_Work,CDM.Date_Of_Commencement,CDM.Date_Of_Termination,CDM.No_Of_LabourEmployed
					FROM T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) INNER JOIN
						(SELECT MAX(Date_Of_Termination) DateOfTermination,BR.Branch_ID AS BR_ID 
						 FROM T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
							 INNER JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID = @Cmp_ID 
						 WHERE ((CDM.Date_Of_Termination BETWEEN @From_Date AND @To_Date)  
						   OR (@From_Date BETWEEN CDM.Date_Of_Commencement AND CDM.Date_Of_Termination)  
						   OR (@To_Date BETWEEN CDM.Date_Of_Commencement AND CDM.Date_Of_Termination)  
						   OR (CDM.Date_Of_Commencement BETWEEN @From_Date AND @To_Date ))
						 GROUP BY BR.Branch_ID,BR.Branch_Name,BR.Branch_Address ) C on C.BR_ID = CDM.Branch_ID and C.DateOfTermination = CDM.Date_Of_Termination
				) QRY1 ON I_Q.Branch_ID = QRY1.Branch_ID
			INNER JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID = I_Q.Branch_ID  
			INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=I_Q.Cmp_ID  
			INNER JOIN T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON DESIG.Desig_ID = I_Q.Desig_Id and I_Q.Cmp_ID = DESIG.Cmp_ID
			INNER JOIN #Emp_Cons EC on EMP.Emp_ID = EC.Emp_ID  
			WHERE CM.Cmp_ID = @Cmp_ID  


	END    
ELSE IF @ReportType='FORM_XXI_Register_Of_Fines'   
	BEGIN
		SELECT DISTINCT EMP.Emp_Id,EMP.Emp_First_Name + ' '+ isnull(EMP.Emp_Second_Name,'') + ' ' + isnull(EMP.Emp_Last_Name,'') AS Emp_Full_Name,  
			EMP.Emp_Code,EMP.Alpha_Emp_Code,DESIG.Desig_Name,  
			QRY1.Contr_PersonName ContractorName,QRY1.Nature_Of_Work,  
			QRY1.Date_Of_Commencement,QRY1.Date_Of_Termination,  
			BR.Branch_Name,BR.Branch_ID,BR.Branch_Address, 
			CM.Cmp_Name as Cmp_Name,
			BR.Comp_Name,
			CM.Cmp_Address,
			QRY1.No_Of_LabourEmployed, EMP.Date_Of_Join,I_Q.Wages_Type,I_Q.Gross_Salary,EMP.Father_name
		FROM T0080_EMP_MASTER EMP WITH (NOLOCK)   
			INNER JOIN  
				( SELECT I.Emp_Id ,Branch_ID,Desig_ID,Dept_ID,Cmp_ID,Wages_Type,Gross_Salary    
					FROM dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN   
						(SELECT MAX(T0095_Increment.Increment_ID) as Increment_ID , T0095_Increment.Emp_ID 
						FROM dbo.T0095_Increment WITH (NOLOCK)
							Inner Join #Emp_Cons EC on T0095_Increment.Emp_ID = EC.Emp_ID
						WHERE Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID  
						group by T0095_Increment.emp_ID  ) Qry on  
				I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q  on EMP.Emp_ID = I_Q.Emp_ID  
--			INNER JOIN T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) on CDM.Branch_ID = I_Q.Branch_ID  
			LEFT OUTER JOIN 
				(SELECT Branch_Id, CDM.Contr_PersonName,CDM.Nature_Of_Work,CDM.Date_Of_Commencement,CDM.Date_Of_Termination,CDM.No_Of_LabourEmployed
					FROM T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) INNER JOIN
						(SELECT MAX(Date_Of_Termination) DateOfTermination,BR.Branch_ID AS BR_ID 
						 FROM T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
							 INNER JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID = @Cmp_ID 
						 WHERE ((CDM.Date_Of_Termination BETWEEN @From_Date AND @To_Date)  
						   OR (@From_Date BETWEEN CDM.Date_Of_Commencement AND CDM.Date_Of_Termination)  
						   OR (@To_Date BETWEEN CDM.Date_Of_Commencement AND CDM.Date_Of_Termination)  
						   OR (CDM.Date_Of_Commencement BETWEEN @From_Date AND @To_Date ))
						 GROUP BY BR.Branch_ID,BR.Branch_Name,BR.Branch_Address ) C on C.BR_ID = CDM.Branch_ID and C.DateOfTermination = CDM.Date_Of_Termination
				) QRY1 ON I_Q.Branch_ID = QRY1.Branch_ID
			INNER JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID = I_Q.Branch_ID  
			INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=I_Q.Cmp_ID  
			INNER JOIN T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON DESIG.Desig_ID = I_Q.Desig_Id and I_Q.Cmp_ID = DESIG.Cmp_ID
			INNER JOIN #Emp_Cons EC on EMP.Emp_ID = EC.Emp_ID  
			WHERE CM.Cmp_ID = @Cmp_ID  


	END     
ELSE IF @ReportType='FORM_XXIV_RETURNS'
     BEGIN
		  SELECT CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
		   CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
		   BR.Branch_Name,BR.Branch_ID,BR.Branch_Address,CM.Cmp_Name as Cmp_Name,BR.Comp_Name,CM.Cmp_Address,CDM.No_Of_LabourEmployed 
		   INTO #CONTRACT_DETAILS
		   FROM T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
		   Inner join (select max(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
		   inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID =@Cmp_ID 
		   where ((CDM.Date_Of_Termination between @From_Date and @To_Date) 
		   or (@From_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date  and @To_Date ))
		   group by BR.Branch_ID ) I_Q on I_Q.Branch_ID = CDM.Branch_ID and I_Q.Date_Of_Termination = CDM.Date_Of_Termination  
		   Inner JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=CDM.Branch_ID  
		   INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=BR.Cmp_ID  
		   WHERE CM.Cmp_ID = @Cmp_ID  
		   and ISNULL(BR.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(BR.Branch_ID,0)),'#')) 
		   and ((CDM.Date_Of_Termination between @From_Date and @To_Date) 
		   or (@From_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date  and @To_Date))
		   --group by CDM.Contr_PersonName,CDM.Nature_Of_Work,CDM.Date_Of_Commencement,BR.Branch_Name,  
		   --BR.Branch_ID,BR.Branch_Address,BR.Comp_Name,CM.Cmp_Name,CM.Cmp_Address,CDM.Date_Of_Termination,  
		   --CDM.No_Of_LabourEmployed 		   
		
		CREATE TABLE #TMPEMPDETAILS
		(
		 BRANCH_ID INT
		,Tot_Male INT
		,Tot_Female	INT	
		,Total_Emp INT
		,TOT_Net_Amount_MALE INT	
		,TOT_Present_Days_MALE INT	--MAN-DAYS
		,TOT_Net_Amount_FEMALE INT	
		,TOT_Present_Days_FEMALE INT	
		,TOT_Net_Amount INT	
		,TOT_Present_Days INT
		,Total_Dedu_Amount_MALE INT
		,Total_Dedu_Amount_FEMALE INT	
		,New_Joining_Male INT
		,New_Joining_Female INT
		)

		INSERT INTO #TMPEMPDETAILS
		SELECT DISTINCT EC.Branch_ID,QRY1.Tot_Male,QRY1.Tot_Female,QRY1.Total_Emp,0,0,0,0,0,0,0,0,0,0--,QRY2.TOT_Net_Amount_MALE,QRY2.TOT_Present_Days_MALE--,QRY3.TOT_Net_Amount_FEMALE,QRY3.TOT_Present_Days_FEMALE,QRY4.TOT_Net_Amount,QRY4.TOT_Present_Days
		FROM #Emp_Cons EC		
		LEFT JOIN(SELECT  COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) as Tot_Male,COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) as Tot_Female,
					COUNT(E.Emp_Id) as Total_Emp from T0080_Emp_Master As E 
					INNER JOIN T0040_TYPE_MASTER T on T.Type_ID = E.Type_ID 
					INNER JOIN #Emp_Cons EC	ON EC.Emp_ID=E.EMP_ID
					INNER JOIN #CONTRACT_DETAILS CD ON CD.Branch_ID=EC.Branch_ID
					WHERE T.Type_Name like 'Contr%' and E.Emp_Left <> 'Y')QRY1 ON 1=1

		UPDATE #TMPEMPDETAILS
		SET New_Joining_Male=QRY2.Tot_Male,New_Joining_Female=QRY2.Tot_Female
		FROM #TMPEMPDETAILS T1,
		(SELECT  COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) as Tot_Male,COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) as Tot_Female,EC.Branch_ID
		from T0080_Emp_Master As E 
		INNER JOIN T0040_TYPE_MASTER T on T.Type_ID = E.Type_ID 
		INNER JOIN #Emp_Cons EC	ON EC.Emp_ID=E.EMP_ID
		INNER JOIN #CONTRACT_DETAILS CD ON CD.Branch_ID=EC.Branch_ID 
		WHERE Date_Of_Join BETWEEN @From_Date AND @To_Date GROUP BY EC.Branch_ID)QRY2 --ON QRY2.Branch_ID=T1.BRANCH_ID

		UPDATE #TMPEMPDETAILS
		SET TOT_Net_Amount_MALE=QRY2.TOT_Net_Amount_MALE,TOT_Present_Days_MALE=QRY2.TOT_Present_Days_MALE
		FROM #TMPEMPDETAILS T1
		INNER JOIN(select  SUM (MS.Sal_Cal_Days) as TOT_Present_Days_MALE , SUM (MS.Net_Amount ) as TOT_Net_Amount_MALE,EC.Branch_ID	
		from T0200_MONTHLY_SALARY MS 
		INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = MS.Emp_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = MS.Emp_ID	
		INNER JOIN #CONTRACT_DETAILS CD ON CD.Branch_ID=EC.Branch_ID
		where E.Gender='M' AND MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and MS.Cmp_ID = @Cmp_ID 
		GROUP BY EC.Branch_ID)QRY2 ON QRY2.Branch_ID=T1.BRANCH_ID

		UPDATE #TMPEMPDETAILS
		SET TOT_Net_Amount_FEMALE=QRY2.TOT_Present_Days_FEMALE,TOT_Present_Days_FEMALE=QRY2.TOT_Net_Amount_FEMALE
		FROM #TMPEMPDETAILS T1
		INNER JOIN(select  SUM (MS.Present_Days) as TOT_Present_Days_FEMALE , SUM (MS.Net_Amount) as TOT_Net_Amount_FEMALE,EC.Branch_ID
		from T0200_MONTHLY_SALARY MS 
		INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = MS.Emp_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = MS.Emp_ID
		INNER JOIN #CONTRACT_DETAILS CD ON CD.Branch_ID=EC.Branch_ID
		where E.Gender='F' AND MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and MS.Cmp_ID = @Cmp_ID 
		GROUP BY EC.Branch_ID)QRY2 ON QRY2.Branch_ID=T1.BRANCH_ID

		UPDATE #TMPEMPDETAILS
		SET TOT_Net_Amount=QRY2.TOT_Present_Days,TOT_Present_Days=QRY2.TOT_Net_Amount
		FROM #TMPEMPDETAILS T1
		INNER JOIN(select  SUM (MS.Present_Days ) as TOT_Present_Days , SUM (MS.Net_Amount ) as TOT_Net_Amount,EC.Branch_ID	
		from T0200_MONTHLY_SALARY MS 
		INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = MS.Emp_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = MS.Emp_ID
		INNER JOIN #CONTRACT_DETAILS CD ON CD.Branch_ID=EC.Branch_ID		
		where MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and MS.Cmp_ID = @Cmp_ID GROUP BY EC.Branch_ID)QRY2 ON QRY2.Branch_ID=T1.BRANCH_ID

		UPDATE #TMPEMPDETAILS
		SET Total_Dedu_Amount_MALE=QRY2.Total_Dedu_Amount_MALE
		FROM #TMPEMPDETAILS T1
		INNER JOIN(select  SUM (MS.Total_Dedu_Amount) as Total_Dedu_Amount_MALE,EC.Branch_ID		
		from T0200_MONTHLY_SALARY MS 
		INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = MS.Emp_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = MS.Emp_ID
		INNER JOIN #CONTRACT_DETAILS CD ON CD.Branch_ID=EC.Branch_ID
		where E.Gender='M' AND MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and MS.Cmp_ID = @Cmp_ID GROUP BY EC.Branch_ID)QRY2 ON QRY2.Branch_ID=T1.BRANCH_ID

		UPDATE #TMPEMPDETAILS
		SET Total_Dedu_Amount_FEMALE=QRY2.Total_Dedu_Amount_FEMALE
		FROM #TMPEMPDETAILS T1
		INNER JOIN(select  SUM (MS.Total_Dedu_Amount) as Total_Dedu_Amount_FEMALE,EC.Branch_ID	
		from T0200_MONTHLY_SALARY MS 
		INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = MS.Emp_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = MS.Emp_ID
		INNER JOIN #CONTRACT_DETAILS CD ON CD.Branch_ID=EC.Branch_ID
		where E.Gender='F' AND MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and MS.Cmp_ID = @Cmp_ID GROUP BY EC.Branch_ID)QRY2 ON QRY2.Branch_ID=T1.BRANCH_ID
				
		--SELECT * FROM #CONTRACT_DETAILS
		--SELECT * FROM #TMPEMPDETAILS

		SELECT CD.*,TD.* FROM #CONTRACT_DETAILS CD
		INNER JOIN #TMPEMPDETAILS TD ON CD.Branch_ID=TD.BRANCH_ID
	END
ELSE IF @ReportType='FORM_XXV_ANNUAL_RETURN'
     BEGIN	
		   SELECT CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
		   CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
		   BR.Branch_Name,BR.Branch_ID,BR.Branch_Address,CM.Cmp_Name as Cmp_Name,BR.Comp_Name,CM.Cmp_Address,CDM.No_Of_LabourEmployed
		   ,QRY2.Net_Payable_Bonus,Bonus_Percentage,Bonus_Paid_Date
		   --INTO #CONTRACT_DETAILS1
		   FROM T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
		   Inner join (select max(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
		   inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID =@Cmp_ID 
		   where ((CDM.Date_Of_Termination between @From_Date and @To_Date) 
		   or (@From_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date  and @To_Date ))
		   group by BR.Branch_ID ) I_Q on I_Q.Branch_ID = CDM.Branch_ID and I_Q.Date_Of_Termination = CDM.Date_Of_Termination  
		   Inner JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=CDM.Branch_ID  
		   INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=BR.Cmp_ID 
		   LEFT JOIN 
			   (SELECT SUM(BS.Net_Payable_Bonus)as Net_Payable_Bonus,EC.Branch_ID	
				from T0180_BONUS BS 
				INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = BS.Emp_ID
				INNER JOIN #Emp_Cons EC ON EC.Emp_ID = BS.Emp_ID		
				where  BS.FROM_DATE >= @From_Date and BS.TO_DATE <= @To_Date and BS.Cmp_ID = @Cmp_ID 
				GROUP BY EC.Branch_ID)QRY2 ON QRY2.Branch_ID=CDM.BRANCH_ID
			LEFT JOIN 
				(SELECT  Bonus_Percentage,To_Date AS Bonus_Paid_Date,Cmp_ID FROM T0180_BONUS BS1
				INNER JOIN #Emp_Cons EC ON EC.Emp_ID = BS1.Emp_ID	
				WHERE  FROM_DATE >= @From_Date and TO_DATE <= @To_Date and Cmp_ID = @Cmp_ID AND ISNULL(Net_Payable_Bonus,0) > 0
				)QRY3 ON QRY3.Cmp_ID=CM.CMP_ID
		   WHERE CM.Cmp_ID = @Cmp_ID  
		   and ISNULL(BR.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(BR.Branch_ID,0)),'#')) 
		   and ((CDM.Date_Of_Termination between @From_Date and @To_Date) 
		   or (@From_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date  and @To_Date))
		   --group by CDM.Contr_PersonName,CDM.Nature_Of_Work,CDM.Date_Of_Commencement,BR.Branch_Name,  
		   --BR.Branch_ID,BR.Branch_Address,BR.Comp_Name,CM.Cmp_Name,CM.Cmp_Address,CDM.Date_Of_Termination,  
		   --CDM.No_Of_LabourEmployed 			   
	END
ELSE IF @ReportType='FORM_D_EQUAL_REMUNERATION'
     BEGIN
		   SELECT CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
		   CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
		   BR.Branch_Name,BR.Branch_ID,BR.Branch_Address,CM.Cmp_Name as Cmp_Name,BR.Comp_Name,CM.Cmp_Address,CDM.No_Of_LabourEmployed   
		   INTO #CONTRACT_DETAILS1
		   FROM T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
		   Inner join (select max(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
		   inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID =@Cmp_ID 
		   where ((CDM.Date_Of_Termination between @From_Date and @To_Date) 
		   or (@From_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date  and @To_Date ))
		   group by BR.Branch_ID ) I_Q on I_Q.Branch_ID = CDM.Branch_ID and I_Q.Date_Of_Termination = CDM.Date_Of_Termination  
		   Inner JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=CDM.Branch_ID  
		   INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=BR.Cmp_ID  
		   WHERE CM.Cmp_ID = @Cmp_ID  
		   and ISNULL(BR.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(BR.Branch_ID,0)),'#')) 
		   and ((CDM.Date_Of_Termination between @From_Date and @To_Date) 
		   or (@From_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date  and @To_Date))group by CDM.Contr_PersonName,CDM.Nature_Of_Work,CDM.Date_Of_Commencement,BR.Branch_Name,  
		   BR.Branch_ID,BR.Branch_Address,BR.Comp_Name,CM.Cmp_Name,CM.Cmp_Address,CDM.Date_Of_Termination,  
		   CDM.No_Of_LabourEmployed 

		  -- DROP TABLE #EMP_SKILL
		   CREATE TABLE #EMP_SKILL_DETAILS
		   (
		   BRANCH_ID INT,
		   SkillType_ID INT,
		   SKILL_NAME VARCHAR(250),
		   DESIGNATION VARCHAR(200),
		   TOT_MALE	INT,
		   TOT_FEMALE INT,
		   GROSS_TOTAL FLOAT,
		   BASIC_TOTAL FLOAT,
		   HRA_TOTAL FLOAT,
		   DA_TOTAL FLOAT,
		   OTHER_ALLOWANCE_TOTAL FLOAT
		   )

		INSERT INTO #EMP_SKILL_DETAILS
		SELECT DISTINCT EC.Branch_ID,ms.SkillType_ID,Skill_Name,'',0,0,0,0,0,0,0
		FROM T0040_SkillType_Master MS 
		INNER JOIN T0080_EMP_MASTER E on E.SkillType_ID = MS.SkillType_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID		
		where ISNULL(E.SkillType_ID,0) > 0 AND E.Date_Of_Join BETWEEN @From_Date AND @To_Date AND E.Emp_Left <> 'Y' and MS.Cmp_ID = @Cmp_ID
		
		UPDATE #EMP_SKILL_DETAILS
		SET DESIGNATION=NameValues
		FROM #EMP_SKILL_DETAILS T1
		INNER JOIN(SELECT SkillType_ID,STUFF((SELECT distinct ', ' + CAST(Desig_Name AS VARCHAR(MAX)) 
		FROM T0080_EMP_MASTER E INNER JOIN T0095_INCREMENT IC on E.Increment_ID = IC.Increment_ID
		INNER JOIN T0040_DESIGNATION_MASTER DM ON DM.Desig_ID=IC.Desig_Id
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = E.Emp_ID 
		INNER JOIN #CONTRACT_DETAILS1 CD ON CD.Branch_ID=EC.Branch_ID
		WHERE ISNULL(SkillType_ID,0) > 0 AND e.CMP_ID=119
		FOR XML PATH ('')),1,2,'') AS NameValues
		FROM T0080_EMP_MASTER 
		GROUP BY SkillType_ID)QRY1 ON QRY1.SkillType_ID=T1.SkillType_ID
		
		UPDATE #EMP_SKILL_DETAILS
		SET TOT_MALE=QRY1.Tot_Male,TOT_FEMALE=QRY1.Tot_Female
		FROM #EMP_SKILL_DETAILS EC		
		LEFT JOIN(SELECT  COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) as Tot_Male,COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) as Tot_Female,
					COUNT(E.Emp_Id) as Total_Emp,E.SkillType_ID from T0080_Emp_Master As E 
					INNER JOIN T0040_SkillType_Master T on T.SkillType_ID = E.SkillType_ID
					INNER JOIN #Emp_Cons EC	ON EC.Emp_ID=E.EMP_ID
					INNER JOIN #CONTRACT_DETAILS1 CD ON CD.Branch_ID=EC.Branch_ID
					WHERE ISNULL(E.SkillType_ID,0) > 0 and E.Emp_Left <> 'Y' GROUP BY E.SkillType_ID)QRY1 ON QRY1.SkillType_ID=EC.SkillType_ID
	
		UPDATE #EMP_SKILL_DETAILS
		SET GROSS_TOTAL=QRY2.Total_Gross_Salary
		FROM #EMP_SKILL_DETAILS T1
		INNER JOIN(select  SUM (MS.Gross_Salary) as Total_Gross_Salary,EC.Branch_ID,SkillType_ID		
		from T0200_MONTHLY_SALARY MS 
		INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = MS.Emp_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = MS.Emp_ID
		INNER JOIN #CONTRACT_DETAILS1 CD ON CD.Branch_ID=EC.Branch_ID
		where MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and MS.Cmp_ID = @Cmp_ID GROUP BY EC.Branch_ID,SkillType_ID)QRY2 ON QRY2.Branch_ID=T1.BRANCH_ID AND QRY2.SkillType_ID=T1.SkillType_ID

		UPDATE #EMP_SKILL_DETAILS
		SET BASIC_TOTAL=QRY2.Total_Basic_Salary
		FROM #EMP_SKILL_DETAILS T1
		INNER JOIN(select  SUM (MS.Basic_Salary) as Total_Basic_Salary,EC.Branch_ID,SkillType_ID		
		from T0200_MONTHLY_SALARY MS 
		INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = MS.Emp_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = MS.Emp_ID
		INNER JOIN #CONTRACT_DETAILS1 CD ON CD.Branch_ID=EC.Branch_ID
		where MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and MS.Cmp_ID = @Cmp_ID GROUP BY EC.Branch_ID,SkillType_ID)QRY2 ON QRY2.Branch_ID=T1.BRANCH_ID AND QRY2.SkillType_ID=T1.SkillType_ID

		UPDATE #EMP_SKILL_DETAILS
		SET HRA_TOTAL=QRY2.Total_HRA
		FROM #EMP_SKILL_DETAILS T1
		INNER JOIN(select  SUM (AD.M_AD_Amount) as Total_HRA,EC.Branch_ID,SkillType_ID		
		FROM T0210_MONTHLY_AD_DETAIL AD 
		INNER JOIN V0120_GRADEWISE_ALLOWANCE GA ON AD.AD_ID=GA.Ad_ID AND AD_DEF_ID=17
		INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = AD.Emp_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = AD.Emp_ID
		INNER JOIN #CONTRACT_DETAILS1 CD ON CD.Branch_ID=EC.Branch_ID
		where M_AD_FLAG='I' AND AD.To_date between @From_Date and @To_Date and AD.Cmp_ID = @Cmp_ID GROUP BY EC.Branch_ID,SkillType_ID)QRY2 ON QRY2.Branch_ID=T1.BRANCH_ID AND QRY2.SkillType_ID=T1.SkillType_ID

		UPDATE #EMP_SKILL_DETAILS
		SET DA_TOTAL=QRY2.Total_DA
		FROM #EMP_SKILL_DETAILS T1
		INNER JOIN(select  SUM (AD.M_AD_Amount) as Total_DA,EC.Branch_ID,SkillType_ID		
		FROM T0210_MONTHLY_AD_DETAIL AD 
		INNER JOIN V0120_GRADEWISE_ALLOWANCE GA ON AD.AD_ID=GA.Ad_ID AND AD_DEF_ID=11
		INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = AD.Emp_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = AD.Emp_ID
		INNER JOIN #CONTRACT_DETAILS1 CD ON CD.Branch_ID=EC.Branch_ID
		where M_AD_FLAG='I' AND AD.To_date between @From_Date and @To_Date and AD.Cmp_ID = @Cmp_ID GROUP BY EC.Branch_ID,SkillType_ID)QRY2 ON QRY2.Branch_ID=T1.BRANCH_ID AND QRY2.SkillType_ID=T1.SkillType_ID

		UPDATE #EMP_SKILL_DETAILS
		SET OTHER_ALLOWANCE_TOTAL=QRY2.Total_Other_Allow_Amount
		FROM #EMP_SKILL_DETAILS T1
		INNER JOIN(select  SUM (MS.Other_Allow_Amount) as Total_Other_Allow_Amount,EC.Branch_ID	
		from T0200_MONTHLY_SALARY MS 
		INNER JOIN T0080_EMP_MASTER E on E.Emp_ID = MS.Emp_ID
		INNER JOIN #Emp_Cons EC ON EC.Emp_ID = MS.Emp_ID
		INNER JOIN #CONTRACT_DETAILS1 CD ON CD.Branch_ID=EC.Branch_ID
		where MS.Month_St_Date >= @From_Date and MS.Month_End_Date <= @To_Date and MS.Cmp_ID = @Cmp_ID GROUP BY EC.Branch_ID)QRY2 ON QRY2.Branch_ID=T1.BRANCH_ID
				
		SELECT CD.*,Tot_CR_Male,Tot_CR_Female,Total_CR_Emp FROM #CONTRACT_DETAILS1 CD		
		INNER JOIN (SELECT COUNT(CASE WHEN E.Gender = 'M' THEN 1 ELSE NULL END) AS Tot_CR_Male,
		COUNT(CASE WHEN E.Gender = 'F' THEN 1 ELSE NULL END) as Tot_CR_Female,
		COUNT(E.Emp_Id) as Total_CR_Emp,EC.BRANCH_ID 
		from T0080_Emp_Master As E 	
		INNER JOIN #Emp_Cons EC	ON EC.Emp_ID=E.EMP_ID
		INNER JOIN #CONTRACT_DETAILS1 CD ON CD.Branch_ID=EC.Branch_ID
		WHERE E.Emp_Left <> 'Y' AND E.CMP_ID=@CMP_ID GROUP BY EC.BRANCH_ID)QRY ON QRY.BRANCH_ID=CD.BRANCH_ID
	
		SELECT * FROM #EMP_SKILL_DETAILS
	END
ELSE IF @ReportType='FORM_L_M_N_O'
     BEGIN
		   SELECT CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
		   CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
		   BR.Branch_Name,BR.Branch_ID,BR.Branch_Address,CM.Cmp_Name as Cmp_Name,BR.Comp_Name,CM.Cmp_Address,CDM.No_Of_LabourEmployed   
		  -- INTO #CONTRACT_DETAILS1
		   FROM T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
		   Inner join (select max(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
		   inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID =@Cmp_ID 
		   where ((CDM.Date_Of_Termination between @From_Date and @To_Date) 
		   or (@From_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date  and @To_Date ))
		   group by BR.Branch_ID ) I_Q on I_Q.Branch_ID = CDM.Branch_ID and I_Q.Date_Of_Termination = CDM.Date_Of_Termination  
		   Inner JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=CDM.Branch_ID  
		   INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=BR.Cmp_ID  
		   WHERE CM.Cmp_ID = @Cmp_ID  
		   and ISNULL(BR.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(BR.Branch_ID,0)),'#')) 
		   and ((CDM.Date_Of_Termination between @From_Date and @To_Date) 
		   or (@From_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date  and @To_Date))group by CDM.Contr_PersonName,CDM.Nature_Of_Work,CDM.Date_Of_Commencement,BR.Branch_Name,  
		   BR.Branch_ID,BR.Branch_Address,BR.Comp_Name,CM.Cmp_Name,CM.Cmp_Address,CDM.Date_Of_Termination,  
		   CDM.No_Of_LabourEmployed 
		END
ELSE IF @ReportType='FORM_B_Welfare'
     BEGIN
		   SELECT CDM.Contr_PersonName ContractorName,CDM.Nature_Of_Work,  
		   CDM.Date_Of_Commencement,CDM.Date_Of_Termination,  
		   BR.Branch_Name,BR.Branch_ID,BR.Branch_Address,CM.Cmp_Name as Cmp_Name,BR.Comp_Name,CM.Cmp_Address,CDM.No_Of_LabourEmployed   
		  -- INTO #CONTRACT_DETAILS1
		   FROM T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
		   Inner join (select max(Date_Of_Termination) Date_Of_Termination,BR.Branch_ID from T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK)  
		   inner JOIN T0030_BRANCH_MASTER BR WITH (NOLOCK) on CDM.Branch_ID = BR.Branch_ID and BR.Cmp_ID =@Cmp_ID 
		   where ((CDM.Date_Of_Termination between @From_Date and @To_Date) 
		   or (@From_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date  and @To_Date ))
		   group by BR.Branch_ID ) I_Q on I_Q.Branch_ID = CDM.Branch_ID and I_Q.Date_Of_Termination = CDM.Date_Of_Termination  
		   Inner JOIN T0030_BRANCH_MASTER BR  WITH (NOLOCK) ON BR.Branch_ID=CDM.Branch_ID  
		   INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=BR.Cmp_ID  
		   WHERE CM.Cmp_ID = @Cmp_ID  
		   and ISNULL(BR.Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(BR.Branch_ID,0)),'#')) 
		   and ((CDM.Date_Of_Termination between @From_Date and @To_Date) 
		   or (@From_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (@To_Date  between CDM.Date_Of_Commencement and CDM.Date_Of_Termination)  
		   or (CDM.Date_Of_Commencement between @From_Date  and @To_Date))group by CDM.Contr_PersonName,CDM.Nature_Of_Work,CDM.Date_Of_Commencement,BR.Branch_Name,  
		   BR.Branch_ID,BR.Branch_Address,BR.Comp_Name,CM.Cmp_Name,CM.Cmp_Address,CDM.Date_Of_Termination,  
		   CDM.No_Of_LabourEmployed 
		END
		ELSE IF @ReportType='FORM_9_COMPA'   
   BEGIN
	 CREATE TABLE #EMP_COMPA
	 (
	 EMP_ID INT,
	 SHIFT_ID INT,
	 JAN_MAR_WF DATE,
	 APR_JUNE_WF DATE,
	 JULY_SEPT_WF DATE,
	 OCT_DEC_WF DATE,
	 JAN_MAR_CF DATE,
	 APR_JUNE_CF DATE,
	 JULY_SEPT_CF DATE,
	 OCT_DEC_CF DATE,
	 )

	   INSERT INTO #EMP_COMPA(EMP_ID,SHIFT_ID,JAN_MAR_WF,APR_JUNE_WF,JULY_SEPT_WF,OCT_DEC_WF,JAN_MAR_CF,APR_JUNE_CF,JULY_SEPT_CF,OCT_DEC_CF)
	   (SELECT DISTINCT EC.Emp_ID, dbo.fn_get_Shift_From_Monthly_Rotation(@Cmp_ID,EC.Emp_ID,W1.for_Date) As Shift_ID,W1.For_Date,W2.For_Date,W3.For_Date,W4.For_Date,C1.For_Date,C2.For_Date,C3.For_Date,C4.For_Date 
	   from #Emp_Cons EC 
	   LEFT Join T0140_LEAVE_TRANSACTION W1 on EC.Emp_ID = W1.Emp_ID AND MONTH(W1.FOR_DATE) IN(1,2,3) AND W1.For_Date between @From_Date and @To_Date  AND ISNULL(W1.CompOff_Credit,0) >0 
	   LEFT Join T0140_LEAVE_TRANSACTION W2 on EC.Emp_ID = W2.Emp_ID AND MONTH(W2.FOR_DATE) IN(4,5,6) AND W2.For_Date between @From_Date and @To_Date  AND ISNULL(W2.CompOff_Credit,0) >0 
	   LEFT Join T0140_LEAVE_TRANSACTION W3 on EC.Emp_ID = W3.Emp_ID AND MONTH(W3.FOR_DATE) IN(7,8,9) AND W3.For_Date between @From_Date and @To_Date  AND ISNULL(W3.CompOff_Credit,0) >0 
	   LEFT Join T0140_LEAVE_TRANSACTION W4 on EC.Emp_ID = W4.Emp_ID AND MONTH(W4.FOR_DATE) IN(10,11,12) AND W4.For_Date between @From_Date and @To_Date  AND ISNULL(W4.CompOff_Credit,0) >0 
	   LEFT Join T0140_LEAVE_TRANSACTION C1 on EC.Emp_ID = C1.Emp_ID AND MONTH(C1.FOR_DATE) IN(1,2,3) AND C1.For_Date between @From_Date and @To_Date  AND ISNULL(C1.CompOff_Used,0) >0  
	   LEFT Join T0140_LEAVE_TRANSACTION C2 on EC.Emp_ID = C2.Emp_ID AND MONTH(C2.FOR_DATE) IN(4,5,6) AND C2.For_Date between @From_Date and @To_Date  AND ISNULL(C2.CompOff_Used,0) >0  
	   LEFT Join T0140_LEAVE_TRANSACTION C3 on EC.Emp_ID = C3.Emp_ID AND MONTH(C3.FOR_DATE) IN(7,8,9) AND C3.For_Date between @From_Date and @To_Date  AND ISNULL(C3.CompOff_Used,0) >0  
	   LEFT Join T0140_LEAVE_TRANSACTION C4 on EC.Emp_ID = C4.Emp_ID AND MONTH(C4.FOR_DATE) IN(10,11,12) AND C4.For_Date between @From_Date and @To_Date  AND ISNULL(C4.CompOff_Used,0) >0  
	  -- WHERE YEAR(LT.FOR_DATE)=YEAR(@From_Date) 	  
	   )

	  -- SELECT * FROM #EMP_COMPA
	  

	 SELECT EMP.Emp_First_Name + ' '+ isnull(EMP.Emp_Second_Name,'') + ' ' + isnull(EMP.Emp_Last_Name,'') AS Emp_Full_Name,  
     EMP.Emp_Code,EMP.Alpha_Emp_Code,CDM.Contr_PersonName ContractorName,CM.Cmp_Name as Cmp_Name,
	 CM.Cmp_Address,EMP.Date_Of_Join,Shift_Name,JAN_MAR_WF,APR_JUNE_WF,JULY_SEPT_WF,OCT_DEC_WF,JAN_MAR_CF,APR_JUNE_CF,JULY_SEPT_CF,OCT_DEC_CF
     FROM T0080_EMP_MASTER EMP WITH (NOLOCK)   
     inner join (select I.Emp_Id ,Branch_ID,Desig_ID,Dept_ID,Cmp_ID,Wages_Type,Gross_Salary   
     from dbo.T0095_Increment I WITH (NOLOCK) inner join   
     (select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment WITH (NOLOCK)
      where Increment_Effective_date <= @To_Date and Cmp_ID = @Cmp_ID group by emp_ID  ) Qry on  
      I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q  on EMP.Emp_ID = I_Q.Emp_ID  
      LEFT JOIN T0035_CONTRACTOR_DETAIL_MASTER CDM WITH (NOLOCK) on CDM.Branch_ID = I_Q.Branch_ID             
      INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON CM.Cmp_Id=I_Q.Cmp_ID  
      Inner join T0040_DESIGNATION_MASTER DESIG WITH (NOLOCK) ON DESIG.Desig_ID = I_Q.Desig_Id and I_Q.Cmp_ID = DESIG.Cmp_ID  	  
	  Inner Join #Emp_Cons EC on EMP.Emp_ID = EC.Emp_ID	  
	  INNER JOIN #EMP_COMPA ECMPA ON ECMPA.EMP_ID=EMP.Emp_ID
	  LEFT JOIN T0040_SHIFT_MASTER SM ON ECMPA.SHIFT_ID=SM.Shift_ID
	  WHERE CM.Cmp_ID = @Cmp_ID  and isnull(Contr_PersonName,'') <> ''
   End
