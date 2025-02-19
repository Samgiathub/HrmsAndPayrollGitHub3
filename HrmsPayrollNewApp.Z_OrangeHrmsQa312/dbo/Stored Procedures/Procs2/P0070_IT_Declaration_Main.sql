

---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[P0070_IT_Declaration_Main] 
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@Year Numeric,
	@Financial_Year Varchar(20),
	@Regime	varchar(20) = 'Tax Regime 1'	
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @IT_Disp_ID Numeric	
	Declare @IT_SR_ID Numeric
	Declare @Acc_Level As Numeric 
	Declare @IT_ID Numeric
	Declare @Emp_ID1 Numeric
	Declare @IT_Tran_ID Numeric
	Declare @IT_CmpID Numeric
	Declare @IT_Name Varchar(350) -- Changed By Ali 21012014
	Declare @For_Date Datetime
	Declare @IT_Flag Char(1)
	Declare @Amount Numeric(18,2)  --Change by Jaina 28-03-2017
	Declare @Amount_Ess Numeric(18,2)
	Declare @IT_Def_ID Numeric
	Declare @IT_Parent_IT Numeric
	Declare @Is_Main_Group Numeric
	Declare @IT_Doc_Name Varchar(max) -- Changed By Ali 21012014
	Declare @IT_Max_Limit Numeric(18,0)
	Declare @IT_DFlag Numeric
	Declare @IT_Level_ITMaster Numeric
	Declare @FY Varchar(20)
	Declare @Year1 Numeric 
	Declare @Is_Metro_NonMetro varchar(30)
		Set @Year1 = @Year + 1
	
	-- Added By Ali 02122013
	Declare @IT_Alias_Name Varchar(100)
	-- Added By Ali 02122013
	Declare @IS_IT_Attah_Comp tinyint
	
	-- Added By Ali 22012014
	Declare @Is_Lock tinyint
		
	-- Added By Ali 24012014
	Declare @IT_Is_Details tinyint
	
		
		Set @Acc_Level =0
		 CREATE table #IT_Declaration
		 (
			IT_Disp_ID Numeric,
			IT_SR_ID Varchar(5),
			IT_Tran_ID Numeric,
			IT_ID Numeric,
			Cmp_ID Numeric,
			Emp_ID Numeric,
			IT_Name Varchar(350), -- Added By Ali 22012014
			IT_Max_Limit Numeric(18,0),
			IT_Flag Char(1),
			IT_Def_ID Numeric,
			IT_Parent_ID Numeric,
			IT_Main_Group Numeric,
			IT_Doc_Name Varchar(max),
			For_Date Datetime,
			Amount Numeric(18,2),   --Change by Jaina 28-03-2017
			Amount_Ess Numeric(18,2),
			IT_DFlag tinyint,			
			IT_Level_ITMaster Numeric,
			Financial_Year Varchar(20),
			IT_Leval Numeric,
			Doc_Name nvarchar(200),
			IT_Alias_Name Varchar(1000), -- Added By Ali 22012014
			IS_IT_Attah_Comp tinyint,	-- Added By Ali 02122013
			Is_Lock bit  default 0, -- Added By Ali 22012014
			IT_Is_Details tinyint -- Added By Ali 24012014
		 )
		 
		Declare @HraFlag tinyint
		Declare @Doc_Name Varchar(200)
		Set @HraFlag = 0
		set @Doc_Name = ''
		
		
		
		 Declare Cur_Declaration1 Cursor for							
			Select IT_Tran_ID, ITM.IT_ID, ITM.Cmp_ID, ITD.Emp_ID, IT_Name, IT_Max_Limit, ITM.IT_Flag, IT_Def_ID, ISNULL(IT_Parent_ID, 0), IT_Main_Group
			, IT_Doc_Name, For_Date,
				(case when (D.AMOUNT is null or D.AMOUNT = 0) then ITD.Amount else D.AMOUNT END) AS Amount,  ---Changed By Jimit 20012018
				 Amount_Ess, ITD.IT_FLAG, ITM.IT_Level, @Financial_Year
			 , ITD.DOC_NAME, ITM.IT_Alias,ISNULL(ITM.IT_Is_Atth_Comp,0) as IT_Is_Atth_Comp 
			 ,ISNULL(ITD.Is_Lock,0) as Is_Lock,ISNULL(ITM.IT_Is_Details,0) as IT_Is_Details -- Added By Ali 24012014			 
			 from T0070_IT_MASTER  ITM WITH (NOLOCK)
				Left outer join (select * from T0100_IT_DECLARATION WITH (NOLOCK) where EMP_ID = @Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and Financial_Year = @Financial_Year And Cmp_Id =@Cmp_Id) ITD on ITM.IT_ID = ITD.IT_ID
				LEFT OUTER JOIN (SELECT EMP_ID, IT_ID, SUM(AMOUNT) AS AMOUNT FROM T0110_IT_Emp_Details WITH (NOLOCK) WHERE Financial_Year=@Financial_Year GROUP BY EMP_ID, IT_ID) AS D ON D.IT_ID=ITD.IT_ID AND D.EMP_ID=ITD.EMP_ID 
				Where ITM.Cmp_ID = @Cmp_ID and ITM.IT_Is_Active = 1 and isnull(ITM.It_is_perquisite,0) = 0  and ISNULL(IT_Parent_ID,0) = 0 Order By IT_Level				
		Open Cur_Declaration1
		Fetch next from Cur_Declaration1 into @IT_Tran_ID, @IT_ID, @IT_CmpID, @Emp_ID1, @IT_Name, @IT_Max_Limit, @IT_Flag, @IT_Def_ID, @IT_Parent_IT, @Is_Main_Group, @IT_Doc_Name, @For_Date, @Amount, @Amount_Ess, @IT_DFlag, @IT_Level_ITMaster, @FY  ,@Doc_Name,@IT_Alias_Name,@IS_IT_Attah_Comp,@Is_Lock,@IT_Is_Details
			while @@FETCH_STATUS = 0
				BEGIN
					
					If @IT_Def_ID = 1
						BEGIN	
							If @HraFlag = 0
								BEGIN	
									
									Set @Acc_Level = @Acc_Level + 1								
										
									Select @IT_Disp_ID = Isnull(Max(IT_Disp_ID),0) + 1
									From #IT_Declaration
									
									--IF ISNULL(@IT_Parent_IT,0) = 0
									--	BEGIN
											Select @IT_SR_ID = ISNULL(Max(Cast(IT_SR_ID as numeric)),0) + 1 
											From #IT_Declaration
										--END
									
									Insert Into #IT_Declaration (IT_Disp_ID, IT_SR_ID, IT_Tran_ID, IT_ID, Cmp_ID, Emp_ID, IT_Name, IT_Max_Limit, IT_Flag, IT_Def_ID, IT_Parent_ID, IT_Main_Group, IT_Doc_Name, For_Date, Amount, Amount_Ess, IT_DFlag, IT_Level_ITMaster, Financial_Year, IT_Leval,Doc_Name,IT_Alias_Name,IS_IT_Attah_Comp,Is_Lock,IT_Is_Details) --  added By Ali 24012014
									Values (@IT_Disp_ID, @IT_SR_ID, @IT_Tran_ID, @IT_ID, @IT_CmpID, @Emp_ID1, @IT_Name, @IT_Max_Limit, @IT_Flag, @IT_Def_ID, @IT_Parent_IT, @Is_Main_Group, @IT_Doc_Name, @For_Date, @Amount, @Amount_Ess, @IT_DFlag, @IT_Level_ITMaster, @FY, @Acc_Level,@Doc_Name,@IT_Alias_Name,@IS_IT_Attah_Comp,@Is_Lock,@IT_Is_Details) --  added By Ali 24012014
								
									Exec P0070_IT_Declaration @Cmp_ID, @Emp_ID, @Year, @FY, @IT_ID, @Acc_Level
									Set @Acc_Level = @Acc_Level - 1
									Set @HraFlag = 1
								END
						END
					Else
						BEGIN
							
							Set @Acc_Level = @Acc_Level + 1							
																
							Select @IT_Disp_ID = Isnull(Max(IT_Disp_ID),0) + 1
							From #IT_Declaration
							
							--IF ISNULL(@IT_Parent_IT,0) = 0
							--	BEGIN
									Select @IT_SR_ID = ISNULL(Max(Cast(IT_SR_ID as numeric)),0) + 1 
									From #IT_Declaration
								--END
							
							Insert Into #IT_Declaration (IT_Disp_ID, IT_SR_ID, IT_Tran_ID, IT_ID, Cmp_ID, Emp_ID, IT_Name, IT_Max_Limit, IT_Flag, IT_Def_ID, IT_Parent_ID, IT_Main_Group, IT_Doc_Name, For_Date, Amount, Amount_Ess, IT_DFlag, IT_Level_ITMaster, Financial_Year, IT_Leval, Doc_Name,IT_Alias_Name,IS_IT_Attah_Comp,Is_Lock,IT_Is_Details) --  added By Ali 24012014
									Values (@IT_Disp_ID, @IT_SR_ID, @IT_Tran_ID, @IT_ID, @IT_CmpID, @Emp_ID1, @IT_Name, @IT_Max_Limit, @IT_Flag, @IT_Def_ID, @IT_Parent_IT, @Is_Main_Group, @IT_Doc_Name, @For_Date, @Amount, @Amount_Ess, @IT_DFlag, @IT_Level_ITMaster, @FY, @Acc_Level,@Doc_Name,@IT_Alias_Name,@IS_IT_Attah_Comp,@Is_Lock,@IT_Is_Details) --  added By Ali 24012014
							
							
							Exec P0070_IT_Declaration @Cmp_ID, @Emp_ID, @Year, @FY, @IT_ID, @Acc_Level
							
							
							Set @Acc_Level = @Acc_Level - 1
							
						END
					Fetch Next from Cur_Declaration1 into @IT_Tran_ID, @IT_ID, @IT_CmpID, @Emp_ID1, @IT_Name, @IT_Max_Limit, @IT_Flag, @IT_Def_ID, @IT_Parent_IT, @Is_Main_Group, @IT_Doc_Name, @For_Date, @Amount, @Amount_Ess, @IT_DFlag, @IT_Level_ITMaster, @FY  ,@Doc_Name,@IT_Alias_Name,@IS_IT_Attah_Comp,@Is_Lock,@IT_Is_Details
				END
		Close Cur_Declaration1
		Deallocate Cur_Declaration1
		
		
		
		/*Added by Nimesh 21-Jul-2015*/
		SET	@Is_Metro_NonMetro = NULL;
		
		SELECT  @Is_Metro_NonMetro= ITD.Is_Metro_NonMetro
		FROM	T0070_IT_MASTER  ITM WITH (NOLOCK) Left outer join (
														SELECT	IT_ID,Is_Metro_NonMetro 
														FROM	T0100_IT_DECLARATION WITH (NOLOCK)
														WHERE	EMP_ID = @Emp_ID AND YEAR(FOR_DATE) IN (@Year,@Year + 1) 
																AND Financial_Year = @Financial_Year
																AND Is_Metro_NonMetro IS NOT NULL
													) ITD on ITM.IT_ID = ITD.IT_ID
		WHERE	ITM.Cmp_ID = @Cmp_ID AND ITM.IT_Is_Active = 1 AND ISNULL(IT_Parent_ID,0) = 0 
		ORDER BY IT_Level				
		
		IF (@Is_Metro_NonMetro IS NULL)
			SELECT	@Is_Metro_NonMetro = CASE WHEN Is_Metro_City = 1 THEN 'Metro' ELSE 'Non-Metro' END 
			FROM	V0080_Employee_Master
			WHERE	Emp_ID = @Emp_ID AND Cmp_ID=@Cmp_ID
		
		/*End*/
		
		
		
		Select ITD.IT_Disp_ID, ISNULL(IT_SR_ID,'') As IT_SR_ID, ISNULL(ITD.IT_Tran_ID, 0) As IT_Tran_ID, ITD.IT_ID, ITD.Cmp_ID, ITD.Emp_ID
		, ITD.IT_Name + Case ITD.IT_Max_Limit When 0 Then '' Else ' (Max '+(Convert(varchar(10),ITD.IT_Max_Limit)) + ')' End As IT_NAME
		, ISNULL(ITD.IT_Max_Limit,0) As IT_Max_Limit, ITD.IT_Flag, ITD.IT_Def_ID
		, ITD.IT_Parent_ID, ITD.IT_Main_Group, ITD.IT_Doc_Name, ITD.For_Date, Isnull(ITD.Amount,0.00) as Amount
		, Isnull(ITD.Amount_Ess,0) as Amount_Ess, ISNULL(ITD.IT_DFlag, 0) As IT_DFlag, ITD.IT_Level_ITMaster
		, ITD.Financial_Year, ITD.IT_Leval , ITD.Doc_Name,ITD.IT_Alias_Name 
		,ITD.IS_IT_Attah_Comp
		,ITD.Is_Lock --  added By Ali 22012014
		,ITD.IT_Is_Details--  added By Ali 22012014
		,@Is_Metro_NonMetro As Is_Metro_NonMetro --Added By Nimesh 27-Jul-2015
		INTO #IT_FINAL
		From #IT_Declaration ITD
		--left outer join T0100_IT_FORM_DESIGN IFD on  ITD.IT_ID = IFD.IT_ID		and ITD.CMP_ID =IFD.Cmp_Id
		--order by IFD.Row_Id
		Order By IT_Level_ITMaster
			
		if @regime = 'Tax Regime 1'	
			SELECT	IsNull(T.ROW_ID,1) As Row_ID, IT.*
			FROM	#IT_FINAL IT LEFT OUTER JOIN (SELECT ROW_NUMBER() OVER(ORDER BY IT_Level_ITMaster, IT_Disp_ID) AS ROW_ID,IT_ID FROM #IT_FINAL WHERE IT_Parent_ID > 0) T ON IT.IT_ID=T.IT_ID
			ORDER BY IT_Level_ITMaster, T.ROW_ID
		else
		
			select ROW_NUMBER() OVER(ORDER BY IT_Level_ITMaster, IT_Disp_ID) AS ROW_ID, * from #IT_Final I 
			Where (IT_Parent_ID in 
				(select IT_ID from #IT_FINAL IT where IT.IT_Alias_name in ('E','F')) or I.IT_Alias_name in ('E','F') or I.IT_Def_ID=152) -- 152 added by Hardik 07/12/2020 for WCL as Leave Encash they need to show in New regime
				And IT_Def_ID not in (170,153)  And IT_Name not like '%Previous Employer PT%' 
				and IT_Name not like '%Previous Employer PF%'
			
							
END
	
	
RETURN

