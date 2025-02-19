
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Pro_Rpt_Emp_Birthday_List]
	@Cmp_Id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric	
	,@Grade_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if OBJECT_ID('tempdb..#month') is null
		Begin
			create table #month(
				month_id  numeric(3,0),
				from_Day_id numeric(3,0),
				to_Day_id numeric(3,0)
			 )
		End	 

	if @Branch_ID = 0
		set @Branch_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grade_ID = 0
		set @Grade_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
	
		
		/*---Added by Rohit Bhai and Sumit on 06022017-------------------------*/
		
		DECLARE @TEMP_DATE AS DATETIME
		DECLARE @COUNT AS NUMERIC
		SET @COUNT = 0
		
		SET @TEMP_DATE = DBO.GET_MONTH_ST_DATE( MONTH(@FROM_DATE),YEAR(@FROM_DATE))
		
		WHILE @TEMP_DATE <= @TO_DATE AND @COUNT<=12
		BEGIN
			IF MONTH(@TEMP_DATE)=MONTH(@FROM_DATE) AND MONTH(@TEMP_DATE) = MONTH(@TO_DATE)  AND YEAR(@FROM_DATE) = YEAR(@TO_DATE)
				INSERT INTO #MONTH VALUES(MONTH(@TEMP_DATE),DAY(@FROM_DATE),DAY(@TO_DATE))
			ELSE IF MONTH(@TEMP_DATE)=MONTH(@FROM_DATE)AND YEAR(@TEMP_DATE) = YEAR(@FROM_DATE) 
				INSERT INTO #MONTH VALUES(MONTH(@TEMP_DATE),DAY(@FROM_DATE),31)
			ELSE IF MONTH(@TEMP_DATE) = MONTH(@TO_DATE)	AND YEAR(@TEMP_DATE) = YEAR(@TO_DATE)
				INSERT INTO #MONTH VALUES(MONTH(@TEMP_DATE),1,DAY(@TO_DATE))
			ELSE
				INSERT INTO #MONTH VALUES(MONTH(@TEMP_DATE),1,31)
				
			SET @COUNT = @COUNT + 1
			SET @TEMP_DATE = DATEADD(MM,1,@TEMP_DATE)
		END
	
	/*---Ended by Rohit Bhai and Sumit on 06022017-------------------------*/	
		--select * from #month
		--return
		
			
CREATE table #Emp_Cons 
 (      
	Emp_ID numeric ,     
	Branch_ID numeric,
	Increment_ID numeric    
 )            
         
EXEC SP_RPT_FILL_EMP_CONS  @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,0,@Grade_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID ,@EMP_ID ,@CONSTRAINT 
	--Added by Sumit on 04022017
	--if @Constraint <> ''        
	-- BEGIN	 
	--   Insert Into #Emp_Cons(Emp_ID)        
	--   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')         
	--  END      
	

	
			Select E.Emp_Id,E.Alpha_Emp_Code As Emp_Code , E.Emp_Full_Name , Grd.Grd_Name , desg.Desig_Name , dept.Dept_Name ,
			--REPLACE(CONVERT(VARCHAR(11),E.Date_Of_birth , 113),' ','-') as Date_Of_Birth  
			REPLACE(convert(varchar(6),E.Date_Of_birth,106),' ',' - ') as Date_Of_Birth --Changed by Sumit on 04022017 to show only Date and Month
			,C.Cmp_ID,C.Cmp_Name,C.Cmp_Address,B.Branch_Id , B.Branch_Name, B.Comp_Name, B.Branch_Address,
			isnull(VS.Vertical_Name,'') as Vertical_Name,
			ISNULL(BS.Segment_Name,'') as Segment_Name,
			ISNULL(sv.SubVertical_Name,'') as SubVertical_Name,
			ISNULL(SB.SubBranch_Name,'') as SubBranch_Name
			from T0080_Emp_master E WITH (NOLOCK)
				inner join  
				#Emp_Cons EC ON e.emp_id = Ec.emp_ID 	INNER JOIN 	 --added jimit 03062015  
				--	(
				--		SELECT I.Emp_ID,TYPE_ID,Branch_ID,Grd_ID,Desig_ID,Dept_ID,Cmp_ID,I.Vertical_ID,I.Segment_ID,I.subBranch_ID,I.SubVertical_ID FROM dbo.T0095_INCREMENT I inner join 
				--			( 
				--				select max(Increment_id) as Increment_id , Emp_ID from dbo.T0095_INCREMENT
				--				where Increment_Effective_date <= @To_Date
				--				and Cmp_ID = @Cmp_Id
				--				group by emp_ID  
				--			) Qry on
				--	I.Emp_ID = Qry.Emp_ID	and I.Increment_id = Qry.Increment_id
				--)QRY1 
					 T0095_INCREMENT QRY1 WITH (NOLOCK) on QRY1.Emp_ID = EC.Emp_ID and QRY1.Increment_ID=EC.Increment_ID --Added by Sumit on 06022017
					
					inner join T0040_GRADE_MASTER Grd WITH (NOLOCK) on QRY1.Grd_ID = Grd.Grd_ID 
					inner join T0040_DESIGNATION_MASTER desg WITH (NOLOCK) on QRY1.desig_Id = desg.Desig_ID
					left outer join T0040_DEPARTMENT_MASTER dept WITH (NOLOCK) on QRY1.Dept_ID = dept.Dept_Id
					inner join T0030_BRANCH_MASTER B WITH (NOLOCK) on QRY1.Branch_ID = B.Branch_ID
					inner join T0010_COMPANY_MASTER C WITH (NOLOCK) on QRY1.Cmp_ID = C.Cmp_Id
					LEFT JOIN T0040_VERTICAL_SEGMENT VS WITH (NOLOCK) ON VS.VERTICAL_ID=QRY1.VERTICAL_ID
					LEFT JOIN T0040_BUSINESS_SEGMENT BS WITH (NOLOCK) ON BS.SEGMENT_ID=QRY1.SEGMENT_ID
					LEFT JOIN T0050_SUBVERTICAL SV WITH (NOLOCK) ON SV.SUBVERTICAL_ID=QRY1.SUBVERTICAL_ID
					LEFT JOIN T0050_SUBBRANCH SB WITH (NOLOCK) ON SB.SUBBRANCH_ID=QRY1.SUBBRANCH_ID --Added by Sumit on 01122016
					inner join (select distinct * from #month )M on month(E.Date_Of_Birth) = m.month_id and (DAY(E.Date_Of_Birth)>= m.from_Day_id and day(E.Date_Of_Birth) <= m.to_Day_id)
		 where E.cmp_id=@Cmp_Id
				and E.emp_id in (Select emp_id from t0080_emp_Master WITH (NOLOCK) where Emp_Left_Date is null or (CONVERT(VARCHAR(10),Emp_Left_Date,120) >= CONVERT(VARCHAR(10),@To_Date,120) and day(Date_Of_Birth) <= day(Emp_Left_Date)) and cmp_id=@Cmp_Id) 
				--and (
				--		--(E.Date_Of_Birth>=@From_Date 
				--		--and E.Date_Of_Birth<=@To_Date)
						
				--		--(
				--		--	Month(E.Date_Of_Birth)>=Month(@From_Date) 
				--		--	And (
				--		--			Month(E.Date_Of_Birth)<=Month(@To_Date)
									
				--		--		)
				--		--) 
				--And (day(E.Date_Of_Birth)>=day(@From_Date) 
				--And day(E.Date_Of_Birth)<=day(@To_Date))
				--)  --Commneted by Sumit 06022017
				and QRY1.Branch_ID = isnull(@Branch_ID ,QRY1.Branch_ID)
				and QRY1.Grd_ID = isnull(@Grade_ID ,QRY1.Grd_ID)
				and isnull(QRY1.Dept_ID,0) = isnull(@Dept_ID ,isnull(QRY1.Dept_ID,0))
				and Isnull(QRY1.Type_ID,0) = isnull(@Type_ID ,Isnull(QRY1.Type_ID,0))
				and Isnull(QRY1.Desig_ID,0) = isnull(@Desig_ID ,Isnull(QRY1.Desig_ID,0))
				and QRY1.Emp_ID = isnull(@Emp_ID ,QRY1.Emp_ID) 	   
		order by month(E.Date_Of_Birth),day(E.Date_Of_Birth)
		
drop table #month		
END


