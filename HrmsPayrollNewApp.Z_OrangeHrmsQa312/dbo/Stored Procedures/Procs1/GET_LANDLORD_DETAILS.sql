
--exec GET_LANDLORD_DETAILS 119,'2019-2020',13693
CREATE PROCEDURE [dbo].[GET_LANDLORD_DETAILS]
	 @CMP_ID numeric(18,0)
	,@FIN_YEAR varchar(20)
	,@EMP_ID numeric(18,0)
	,@Iscolumn  Tinyint  = 0
	,@Constraint nvarchar(Max) = ''
	,@From_Date  datetime    
	,@To_Date  datetime     
	,@Branch_ID  varchar(Max) = ''    
	,@Cat_ID  varchar(Max) = ''    
	,@Grd_ID  varchar(Max) = ''    
	,@Type_ID  varchar(Max) = ''    
	,@Dept_ID  varchar(Max) = ''    
	,@Desig_ID  varchar(Max) = ''    
	,@Segment_Id  varchar(Max) = ''    
	,@Vertical_Id  varchar(Max) = ''    
	,@SubVertical_Id varchar(Max) = ''    
	,@SubBranch_Id  varchar(Max) = ''    
	,@Gender  varchar(20) = ''    
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
IF @Gender = ''    
	SET @Gender = null    
    
     
 CREATE table #Emp_Cons     
 (          
   Emp_ID numeric ,         
  Branch_ID numeric,    
  Increment_ID numeric        
 )          
     
   --exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'0',0,0  
  
  --EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0,0,0,0 ,0,@New_Join_emp,@Left_Emp    
     
 if @Constraint <> ''    
  begin    
	   Insert Into #Emp_Cons    
	   Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#')     
  end    
  ELSE
  BEGIN
		insert into #Emp_Cons (emp_Id) 
		select Emp_ID 
		from T0080_EMP_MASTER em  where em.Alpha_Emp_Code in(
		select e.Alpha_Emp_Code
		from	T0100_IT_DECLARATION ITD  WITH (NOLOCK) INNER JOIN
				T0070_IT_MASTER ITM  with (nolock) ON ITD.IT_ID = ITM.IT_ID INNER JOIN
				T0110_IT_Emp_Details ITED with (nolock) ON ITD.IT_ID = ITED.IT_ID		
				and Itd.FINANCIAL_YEAR = ITED.Financial_Year 
				INNER JOIN T0080_EMP_MASTER e with (nolock) ON e.Emp_ID = ITD.EMP_ID
		where	ITD.EMP_ID = e.Emp_ID and ITD.CMP_ID = @CMP_ID
				AND ITM.IT_Def_ID = 1 and ITED.Emp_ID = e.Emp_ID
				AND ISNULL(ITED.Date,'') = '' and ITED.Amount = 0
				AND ITED.Financial_Year = @FIN_YEAR 
		group by ITD.Emp_ID,Detail_1,Detail_2,Detail_3,Comments,ITD.Is_Metro_NonMetro,e.Alpha_Emp_Code)
  END

  
if  @Iscolumn = 0
Begin 
		select em.Alpha_Emp_Code, em.Emp_ID,em.Emp_code, em.Emp_Full_Name,em.Emp_First_Name,em.Mobile_No 
		from T0080_EMP_MASTER em  where em.Alpha_Emp_Code in(
		select e.Alpha_Emp_Code
		from	T0100_IT_DECLARATION ITD  WITH (NOLOCK) INNER JOIN
				T0070_IT_MASTER ITM  with (nolock) ON ITD.IT_ID = ITM.IT_ID INNER JOIN
				T0110_IT_Emp_Details ITED with (nolock) ON ITD.IT_ID = ITED.IT_ID		
				and Itd.FINANCIAL_YEAR = ITED.Financial_Year 
				INNER JOIN T0080_EMP_MASTER e with (nolock) ON e.Emp_ID = ITD.EMP_ID
		where	ITD.EMP_ID = e.Emp_ID and ITD.CMP_ID = @CMP_ID
				AND ITM.IT_Def_ID = 1 and ITED.Emp_ID = e.Emp_ID
				AND ISNULL(ITED.Date,'') = '' and ITED.Amount = 0
				AND ITED.Financial_Year = @FIN_YEAR 
		group by ITD.Emp_ID,Detail_1,Detail_2,Detail_3,Comments,ITD.Is_Metro_NonMetro,e.Alpha_Emp_Code)
			

END
if @Iscolumn = 1      
 begin
		select distinct e.Alpha_Emp_Code,
				e.Emp_Full_Name,
				SUM(ITD.AMOUNT)as Amount,
				Detail_1 As Address,
				Detail_2 as Address1,
				Detail_3 as Pan_No
				,Comments,
				ITD.Is_Metro_NonMetro 
		from	T0100_IT_DECLARATION ITD  WITH (NOLOCK) INNER JOIN
				T0070_IT_MASTER ITM  with (nolock) ON ITD.IT_ID = ITM.IT_ID INNER JOIN
				T0110_IT_Emp_Details ITED with (nolock) ON ITD.IT_ID = ITED.IT_ID		
				and Itd.FINANCIAL_YEAR = ITED.Financial_Year 
				INNER JOIN T0080_EMP_MASTER e with (nolock) ON e.Emp_ID = ITD.EMP_ID
				Inner Join #Emp_Cons EC on E.Emp_ID = EC.Emp_ID
		where	ITD.EMP_ID = e.Emp_ID and ITD.CMP_ID = @CMP_ID
				AND ITM.IT_Def_ID = 1 and ITED.Emp_ID = e.Emp_ID
				AND ISNULL(ITED.Date,'') = '' and ITED.Amount = 0
				AND ITED.Financial_Year = @FIN_YEAR 
			
		group by ITD.Emp_ID,Detail_1,Detail_2,Detail_3,Comments,ITD.Is_Metro_NonMetro,e.Alpha_Emp_Code,e.Emp_Full_Name

 end
END

