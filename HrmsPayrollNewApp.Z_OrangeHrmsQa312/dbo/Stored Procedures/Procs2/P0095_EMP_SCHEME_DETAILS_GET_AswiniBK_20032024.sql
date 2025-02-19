
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
create PROCEDURE [dbo].[P0095_EMP_SCHEME_DETAILS_GET_AswiniBK_20032024]
	 @Scheme_ID		Numeric(18,0)
	,@CMP_ID		NUMERIC(18,0)
	,@From_Date		DATETIME	= NULL
	,@Type			Varchar(100)	
	,@Dept_ID 		NUMERIC		= 0
	,@Branch_ID		NUMERIC		= 0
	,@Desig_ID 		NUMERIC		= 0
	,@Grd_ID 		NUMERIC		= 0
	,@Emp_ID 		NUMERIC		= 0
	,@constraint 	VARCHAR(MAX)= ''
	,@Exists		Char(1)
	,@PBranch_ID	varchar(5000)= '' --Added By Jaina 24-09-2015
	,@PVertical_ID	varchar(5000)= '' --Added By Jaina 24-09-2015
	,@PSubVertical_ID	varchar(5000)= '' --Added By Jaina 24-09-2015
	,@PDept_ID varchar(5000)=''  --Added By Jaina 24-09-2015
	,@PCatID varchar(max)=''	 --Added By Ronakk 09022022
	,@PSalCycle varchar(max)=''	 --Added By Ronakk 09022022
	,@PBusinSgmt varchar(max)='' --Added By Ronakk 09022022
	,@PSubBranch varchar(max)='' --Added By Ronakk 09022022
	,@PBand varchar(max)=''		 --Added By Ronakk 09022022
	,@PEmpType varchar(max)=''	 --Added By Ronakk 09022022

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF ISNULL(@From_Date,GETDATE()) = GETDATE()
		SET @From_Date = GETDATE()
	
	IF @Dept_ID = 0  
		SET @Dept_ID = NULL
		
	IF @Branch_ID = 0  
		SET @Branch_ID = NULL
		
	IF @Desig_ID = 0  
		SET @Desig_ID = NULL

	IF @Grd_ID = 0  
		SET @Grd_ID = NULL

	IF @Emp_ID = 0  
		SET @Emp_ID = NULL
	
	IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 24-09-2015
		set @PBranch_ID = null   	
	
	if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 24-09-2015
		set @PVertical_ID = null
	
	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 24-09-2015
		set @PsubVertical_ID = null
	
	IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 24-09-2015
		set @PDept_ID = NULL	
		


		
		--Added By Ronakk 09022022

		IF @PCatID = '0' or @PCatID='' 
		set @PCatID = NULL	

		IF @PSalCycle = '0' or @PSalCycle='' 
		set @PSalCycle = NULL

		IF @PBusinSgmt = '0' or @PBusinSgmt='' 
		set @PBusinSgmt = NULL

		IF @PSubBranch = '0' or @PSubBranch='' 
		set @PSubBranch = NULL

		IF @PBand = '0' or @PBand='' 
		set @PBand = NULL

		IF @PEmpType = '0' or @PEmpType='' 
		set @PEmpType = NULL

		--End



	--Added By Jaina 24-09-2015 Start		
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0';
		else
			set @PVertical_ID = @PVertical_ID + ',0'	
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
	Begin
		select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		if @PDept_ID is null
			set @PDept_ID = '0';
		else
			set @PDept_ID = @PDept_ID + ',0'	
	End
	--Added By Jaina 24-09-2015 End




	-- Added By Ronakk 09022022

if @PCatID is null  
 Begin 
 
  select   @PCatID = COALESCE(@PCatID + ',', '') + cast(Cat_ID as nvarchar(5))  from T0030_Category_Master WITH (NOLOCK) where cmp_ID=@Cmp_ID   
    
  If @PCatID IS NULL  
   set @PCatID = '0';  
  else  
   set @PCatID = @PCatID + ',0'  
 End  


 if @PBusinSgmt is null  
 Begin 
 
  select   @PBusinSgmt = COALESCE(@PBusinSgmt + ',', '') + cast(Segment_ID as nvarchar(5))  from T0040_Business_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID   
    
  If @PBusinSgmt IS NULL  
   set @PBusinSgmt = '0';  
  else  
   set @PBusinSgmt = @PBusinSgmt + ',0'  
 End  

 if @PSubBranch is null  
 Begin 
 
  select   @PSubBranch = COALESCE(@PSubBranch + ',', '') + cast(SubBranch_ID as nvarchar(5))  from T0050_SubBranch WITH (NOLOCK) where Cmp_ID=@Cmp_ID   
    
  If @PSubBranch IS NULL  
   set @PSubBranch = '0';  
  else  
   set @PSubBranch = @PSubBranch + ',0'  
 End  


  if @PEmpType is null  
 Begin 
 
  select   @PEmpType = COALESCE(@PEmpType + ',', '') + cast(Type_ID as nvarchar(5))  from T0040_TYPE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID   
    
  If @PEmpType IS NULL  
   set @PEmpType = '0';  
  else  
   set @PEmpType = @PEmpType + ',0'  
 End  


  if @PBand is null  
 Begin 
 
  select   @PBand = COALESCE(@PBand + ',', '') + cast(BandId as nvarchar(5))  from tblBandMaster WITH (NOLOCK) where Cmp_Id=@Cmp_ID   
    
  If @PBand IS NULL  
   set @PBand = '0';  
  else  
   set @PBand = @PBand + ',0'  
 End  

 
  if @PSalCycle is null  
 Begin 
 
  select   @PSalCycle = COALESCE(@PSalCycle + ',', '') + cast(Tran_Id as nvarchar(5))  from T0040_Salary_Cycle_Master WITH (NOLOCK) where Cmp_id=@Cmp_ID   
    
  If @PSalCycle IS NULL  
   set @PSalCycle = '0';  
  else  
   set @PSalCycle = @PSalCycle + ',0'  
 End  



--End By Ronak 09022022



		
	DECLARE @Emp_Cons TABLE
	(
		Emp_ID	NUMERIC
		--Vertical_ID numeric(18,0),  --Added By Jaina 24-09-2015
		--SubVertical_ID numeric(18,0), --Added By Jaina 24-09-2015
		--Dept_ID numeric(18,0) --Added By Jaina 24-09-2015
	)
	
	IF @Constraint <> ''
		BEGIN
			INSERT INTO @Emp_Cons(Emp_ID)
			SELECT  CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#') 
		END
	ELSE
		BEGIN
		
			INSERT INTO @Emp_Cons(Emp_ID)--,Vertical_ID,SubVertical_ID,Dept_ID) --Change By Jaina 24-09-2015

			SELECT I.Emp_Id --,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID   --Change By Jaina 24-09-2015
				FROM T0095_Increment I WITH (NOLOCK)
					INNER JOIN (SELECT MAX(Increment_Id) AS Increment_ID, Emp_ID  --Change By Jaina 23-12-2015
									FROM T0095_Increment WITH (NOLOCK)
									WHERE Cmp_ID = @Cmp_ID -- And Increment_Effective_date <= @From_Date  
									GROUP BY emp_ID 
								) Qry 
					ON I.Emp_ID = Qry.Emp_ID AND I.Increment_ID = Qry.Increment_ID	--Change By Jaina 23-12-2015
					  
				WHERE Cmp_ID = @Cmp_ID 
					AND I.Branch_ID = ISNULL(@Branch_ID ,I.Branch_ID)
					AND I.Grd_ID = ISNULL(@Grd_ID ,Grd_ID)
					AND ISNULL(I.Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(I.Dept_ID,0))
					AND ISNULL(I.Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
					AND I.Emp_ID = ISNULL(@Emp_ID ,I.Emp_ID) 
					--Added By Jaina 14-10-2015 start   
					and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))
					and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
					and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
					and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
					--Added By Jaina 14-10-2015 end
					and EXISTS (select Data from dbo.Split(@PCatID, ',') C Where cast(C.data as numeric)=Isnull(I.Cat_ID,0)) 			  --added by ronakk 09022022
					and EXISTS (select Data from dbo.Split(@PBusinSgmt, ',') BS Where cast(BS.data as numeric)=Isnull(I.Segment_ID,0)) 	  --added by ronakk 09022022
					and EXISTS (select Data from dbo.Split(@PSubBranch, ',') SB Where cast(SB.data as numeric)=Isnull(I.subBranch_ID,0))  --added by ronakk 09022022
					and EXISTS (select Data from dbo.Split(@PBand, ',') BM Where cast(BM.data as numeric)=Isnull(I.Band_Id,0)) 			  --added by ronakk 09022022
					and EXISTS (select Data from dbo.Split(@PEmpType, ',') ET Where cast(ET.data as numeric)=Isnull(I.Type_ID,0)) 		  --added by ronakk 09022022
					and EXISTS (select Data from dbo.Split(@PSalCycle, ',') SC Where cast(SC.data as numeric)=Isnull(I.SalDate_id,0)) 	  --added by ronakk 09022022
			
		END
		
	If @Exists	= 'E'
		Begin
			Select 
			ISNULL(CONVERT(NVARCHAR,ES.Tran_ID),'-') as Tran_ID, 
					EMP.Cmp_ID, EMP.Emp_ID 
					,ISNULL(SM.Scheme_Name,'-') as Scheme_Name, 
					ISNULL(SM.Scheme_Type,'-') as Scheme_Type
					   ,EMP.EMP_FULL_NAME, EMP.ALPHA_EMP_CODE 
					,ISNULL(CONVERT(NVARCHAR,ES.Effective_Date,103),'-') as Effective_Date 
				From T0080_EMP_MASTER EMP WITH (NOLOCK)
					left Outer JOIN 
					--T0095_EMP_SCHEME ES 
					(SELECT QES.* from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
						(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
						where IES.effective_date <= @From_Date AND Cmp_ID = @CMP_ID AND Type = @Type 
						GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date and qes.Type = @Type  --Added By Mukti 23012015 and qes.Type = @Type
					) ES		
					
					ON ES.EMP_ID =  EMP.EMP_ID 
					left Outer JOIN T0040_Scheme_Master SM WITH (NOLOCK) On  ES.Scheme_ID = SM.Scheme_ID 
				Where Emp.EMP_ID in (select Emp_ID from @Emp_Cons)
				And EMP.Emp_Left = 'N' And ISNULL(CONVERT(NVARCHAR,ES.Tran_ID),'-') <> '-'
				
		End
		
	Else IF @Exists	= 'N'
		Begin
			Select 
			ISNULL(CONVERT(NVARCHAR,ES.Tran_ID),'-') as Tran_ID, 
					EMP.Cmp_ID, EMP.Emp_ID  
					,ISNULL(SM.Scheme_Name,'-') as Scheme_Name, 
					ISNULL(SM.Scheme_Type,'-') as Scheme_Type
					   ,EMP.EMP_FULL_NAME, EMP.ALPHA_EMP_CODE 
					,ISNULL(CONVERT(NVARCHAR,ES.Effective_Date,103),'-') as Effective_Date 
				From T0080_EMP_MASTER EMP WITH (NOLOCK)
					left Outer JOIN 
					--T0095_EMP_SCHEME ES 
					(SELECT QES.* from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
						(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
						where IES.effective_date <= @From_Date AND Cmp_ID = @CMP_ID AND Type = @Type
						GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date and qes.Type = @Type  --Added By Mukti 23012015 and qes.Type = @Type
					) ES		
					
					ON ES.EMP_ID =  EMP.EMP_ID 
					left Outer JOIN T0040_Scheme_Master SM WITH (NOLOCK) On  ES.Scheme_ID = SM.Scheme_ID 
				Where Emp.EMP_ID in (select Emp_ID from @Emp_Cons)
				And EMP.Emp_Left = 'N' And ISNULL(CONVERT(NVARCHAR,ES.Tran_ID),'-') = '-'
				
		End
	Else
		Begin
		
			-- Comment by nilesh patel on 13102015 --Start (For Multiple Scheme Assign to Employee)
			--Select 
			--ISNULL(CONVERT(NVARCHAR,ES.Tran_ID),'-') as Tran_ID, 
			--		EMP.Cmp_ID, EMP.Emp_ID 
			--		,ISNULL(SM.Scheme_Name,'-') as Scheme_Name, 
			--		ISNULL(SM.Scheme_Type,'-') as Scheme_Type
			--		   ,EMP.EMP_FULL_NAME, EMP.ALPHA_EMP_CODE 
			--		,ISNULL(CONVERT(NVARCHAR,ES.Effective_Date,103),'-') as Effective_Date 
			--	From T0080_EMP_MASTER EMP
			--		left Outer JOIN 
			--		--T0095_EMP_SCHEME ES 
			--		(SELECT QES.* from T0095_EMP_SCHEME QES INNER join 
			--			(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES
			--			where IES.effective_date <= @From_Date AND Cmp_ID = @CMP_ID AND Type = @Type
			--			GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date and qes.Type = @Type  --Added By Mukti 23012015 and qes.Type = @Type
			--		) ES		
					
			--		ON ES.EMP_ID =  EMP.EMP_ID 
			--		left Outer JOIN T0040_Scheme_Master SM On  ES.Scheme_ID = SM.Scheme_ID 
			--	Where Emp.EMP_ID in (select Emp_ID from @Emp_Cons) And EMP.Emp_Left = 'N' 
			
			-- Comment by nilesh patel on 13102015 --End
			
			SELECT	distinct
					EMP.Cmp_ID, EMP.Emp_ID ,	
					STUFF((Select ',' + Scheme_Name  From T0080_EMP_MASTER EMP1 WITH (NOLOCK)
					left Outer JOIN 
					(SELECT QES.* from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
						(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
						where IES.effective_date <= @From_Date AND Cmp_ID = @CMP_ID AND Type = @Type 
						GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date and qes.Type = @Type  --Added By Mukti 23012015 and qes.Type = @Type
					) ES1		
					
					ON ES1.EMP_ID =  EMP1.EMP_ID 
					left Outer JOIN T0040_Scheme_Master SM1 WITH (NOLOCK) On  ES1.Scheme_ID = SM1.Scheme_ID
					WHERE EMP1.Emp_ID = EMP.Emp_ID and EMP1.Cmp_ID = EMP.Cmp_ID
					 FOR XML PATH ('')
						),1,1,'') as Scheme_Name,
					ISNULL(SM.Scheme_Type,'-') as Scheme_Type
					   ,EMP.EMP_FULL_NAME, EMP.ALPHA_EMP_CODE 
					,ISNULL(CONVERT(NVARCHAR,ES.Effective_Date,103),'-') as Effective_Date
			From T0080_EMP_MASTER EMP WITH (NOLOCK)
					left Outer JOIN 
					(SELECT QES.* from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
						(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
						where IES.effective_date <= @From_Date AND Cmp_ID = @CMP_ID AND Type = @Type 
						GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date and qes.Type = @Type  --Added By Mukti 23012015 and qes.Type = @Type
					) ES		
					
					ON ES.EMP_ID =  EMP.EMP_ID 
					left Outer JOIN T0040_Scheme_Master SM WITH (NOLOCK) On  ES.Scheme_ID = SM.Scheme_ID 
					Where Emp.EMP_ID in (select Emp_ID from @Emp_Cons) And EMP.Emp_Left = 'N' 	
		End	 
		
	--Select 
	--ISNULL(CONVERT(NVARCHAR,ES.Tran_ID),'-') as Tran_ID, 
	--		EMP.Cmp_ID, EMP.Emp_ID 
	--		,ISNULL(SM.Scheme_Name,'-') as Scheme_Name, 
	--		ISNULL(SM.Scheme_Type,'-') as Scheme_Type
	--		   ,EMP.EMP_FULL_NAME, EMP.ALPHA_EMP_CODE 
	--		,ISNULL(CONVERT(NVARCHAR,ES.Effective_Date,103),'-') as Effective_Date 
	--	From T0080_EMP_MASTER EMP
	--		left Outer JOIN 
	--		--T0095_EMP_SCHEME ES 
	--		(SELECT QES.* from T0095_EMP_SCHEME QES INNER join 
	--			(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES
	--			where IES.effective_date <= @From_Date AND Cmp_ID = @CMP_ID AND Type = @Type	--@Type Ankit 01052014
	--			GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date
	--		) ES		
			
	--		ON ES.EMP_ID =  EMP.EMP_ID 
	--		left Outer JOIN T0040_Scheme_Master SM On  ES.Scheme_ID = SM.Scheme_ID 
	--	Where Emp.EMP_ID in (select Emp_ID from @Emp_Cons)
	--		 And EMP.Emp_Left = 'N'
RETURN


