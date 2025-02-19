-- =============================================
-- Author:		<Mihir Trivedi>
-- ALTER date: <12/06/2012>
-- Description:	<Developed for IT Declaration>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0070_IT_Declaration] 
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@Year Numeric,
	@Financial_Year Varchar(20),
	@Grp_Parent_Id As Numeric = 0,
    @Acc_Level As Numeric = 0    
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @IT_ID Numeric
	Declare @IT_SR_ID Numeric
	Declare @IT_CmpID Numeric
	Declare @Emp_ID1 Numeric
	Declare @IT_Tran_ID Numeric
	Declare @IT_Name Varchar(100)
	Declare @IT_Max_Limit Numeric(18,0)
	Declare @For_Date Datetime
	Declare @IT_Flag Char(1)
	Declare @Amount Numeric(18,2) --Change by Jaina 29-03-2017
	Declare @Amount_Ess Numeric(18,2)
	Declare @IT_Def_ID Numeric
	Declare @IT_Parent_IT Numeric
	Declare @Is_Main_Group Numeric
	Declare @IT_Doc_Name Varchar(max)
	Declare @IT_Disp_ID Numeric
	Declare @IT_DFlag Numeric
	Declare @IT_Level_ITMaster Numeric
	Declare @FY Varchar(20)
	Declare @HraFlag tinyint
	Set @HraFlag = 0
	Declare @Year1 Numeric
	Set @Year1 = @Year + 1	
	Declare @Doc_Name Varchar(200)
	set @doc_name = ''		
			
	-- Added By Ali 05122013
	Declare @IT_Alias_Name Varchar(100)
	Declare @IS_IT_Attah_Comp tinyint
	
	-- Added By Ali 22012014
	Declare @Is_Lock tinyint
	
	-- Added By Ali 24012014
	Declare @IT_Is_Details tinyint
	
		Declare Cur_Declaration Cursor LOCAL for				
		--Select IT_Tran_ID,ITM.IT_ID, ITM.Cmp_ID, Emp_ID, IT_Name, IT_Max_Limit, ITM.IT_Flag, IT_Def_ID, ISNULL(IT_Parent_ID, 0), IT_Main_Group, IT_Doc_Name, For_Date, Amount, Amount_Ess, ITD.IT_Flag, ITM.IT_Level, Financial_Year,ITD.Doc_Name,ITM.IT_Alias,ISNULL(ITM.IT_Is_Atth_Comp,0) as IT_Is_Atth_Comp
		--,ISNULL(ITD.Is_Lock,0) as Is_Lock 
		--,ISNULL(ITM.IT_Is_Details,0) as IT_Is_Details -- Added By Ali 24012014
		-- from T0070_IT_MASTER  ITM
		--Left outer join (select * from T0100_IT_DECLARATION where EMP_ID = @Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and Financial_Year = @Financial_Year) ITD on ITM.IT_ID = ITD.IT_ID
		--Where ITM.Cmp_ID = @Cmp_ID and ITM.IT_Is_Active = 1 and ISNULL(IT_Parent_ID,0) = @Grp_Parent_Id Order By IT_Level 
		
		--Above Commented by Hardik 25/03/2015 and Added Max(IT_Tran_id) Join in below query.
		Select IT_Tran_ID,ITM.IT_ID, ITM.Cmp_ID, Emp_ID, IT_Name, IT_Max_Limit, ITM.IT_Flag, IT_Def_ID, ISNULL(IT_Parent_ID, 0), IT_Main_Group, IT_Doc_Name, For_Date, Amount, Amount_Ess, ITD.IT_Flag, ITM.IT_Level, Financial_Year,ITD.Doc_Name,ITM.IT_Alias,ISNULL(ITM.IT_Is_Atth_Comp,0) as IT_Is_Atth_Comp
		,ISNULL(ITD.Is_Lock,0) as Is_Lock 
		,ISNULL(ITM.IT_Is_Details,0) as IT_Is_Details -- Added By Ali 24012014
		 from T0070_IT_MASTER  ITM WITH (NOLOCK)
		Left outer join (select * from T0100_IT_DECLARATION A WITH (NOLOCK) inner join
		(Select Max(IT_TRAN_ID) as IT_Tran_Id_max, EMP_ID as E_Id,IT_ID as I_Id from T0100_IT_DECLARATION WITH (NOLOCK) where EMP_ID = @Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and Financial_Year = @Financial_Year 
		and CMP_ID=@Cmp_ID group by EMP_ID,it_id) qry on a.IT_TRAN_ID=qry.IT_Tran_Id_max and a.EMP_ID=qry.E_ID and a.IT_ID=qry.I_ID
		where a.EMP_ID = @Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and Financial_Year = @Financial_Year 
		and CMP_ID=@Cmp_ID) ITD on ITM.IT_ID = ITD.IT_ID
		Where ITM.Cmp_ID = @Cmp_ID and ITM.IT_Is_Active = 1 and ISNULL(IT_Parent_ID,0) = @Grp_Parent_Id Order By IT_Level 
		
		Open Cur_Declaration
		Fetch next from Cur_Declaration into @IT_Tran_ID, @IT_ID, @IT_CmpID, @Emp_ID1, @IT_Name, @IT_Max_Limit, @IT_Flag, @IT_Def_ID, @IT_Parent_IT, @Is_Main_Group, @IT_Doc_Name, @For_Date, @Amount, @Amount_Ess, @IT_DFlag, @IT_Level_ITMaster,@FY,@Doc_Name,@IT_Alias_Name,@IS_IT_Attah_Comp,@Is_Lock,@IT_Is_Details --  added By Ali 24012014
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
					
							Insert Into #IT_Declaration (IT_Disp_ID, IT_SR_ID, IT_Tran_ID, IT_ID, Cmp_ID, Emp_ID, IT_Name, IT_Max_Limit, IT_Flag, IT_Def_ID, IT_Parent_ID, IT_Main_Group, IT_Doc_Name, For_Date, Amount, Amount_Ess, IT_DFlag, IT_Level_ITMaster, Financial_Year, IT_Leval, Doc_Name,IT_Alias_Name,IS_IT_Attah_Comp,Is_Lock,IT_Is_Details) --  Added By Ali 24012014
							Values (@IT_Disp_ID, @IT_SR_ID, @IT_Tran_ID, @IT_ID, @IT_CmpID, @Emp_ID1, @IT_Name, @IT_Max_Limit, @IT_Flag, @IT_Def_ID, @IT_Parent_IT, @Is_Main_Group, @IT_Doc_Name, @For_Date, @Amount, @Amount_Ess, @IT_DFlag, @IT_Level_ITMaster, @FY, @Acc_Level, @Doc_Name,@IT_Alias_Name,@IS_IT_Attah_Comp,@Is_Lock,@IT_Is_Details) -- Added By Ali 24012014
								
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
					
					Insert Into #IT_Declaration (IT_Disp_ID, IT_SR_ID, IT_Tran_ID, IT_ID, Cmp_ID, Emp_ID, IT_Name, IT_Max_Limit, IT_Flag, IT_Def_ID, IT_Parent_ID, IT_Main_Group, IT_Doc_Name, For_Date, Amount, Amount_Ess, IT_DFlag, IT_Level_ITMaster, Financial_Year, IT_Leval,Doc_Name,IT_Alias_Name,IS_IT_Attah_Comp,Is_Lock,IT_Is_Details) --  Added By Ali 24012014
					Values (@IT_Disp_ID, @IT_SR_ID, @IT_Tran_ID, @IT_ID, @IT_CmpID, @Emp_ID1, @IT_Name, @IT_Max_Limit, @IT_Flag, @IT_Def_ID, @IT_Parent_IT, @Is_Main_Group, @IT_Doc_Name, @For_Date, @Amount, @Amount_Ess, @IT_DFlag, @IT_Level_ITMaster, @FY, @Acc_Level, @Doc_Name,@IT_Alias_Name,@IS_IT_Attah_Comp,@Is_Lock,@IT_Is_Details) -- Added By Ali 24012014
				
					Exec P0070_IT_Declaration @Cmp_ID, @Emp_ID, @Year, @FY, @IT_ID, @Acc_Level
					Set @Acc_Level = @Acc_Level - 1			
					
				END
				Fetch Next from Cur_Declaration into @IT_Tran_ID, @IT_ID, @IT_CmpID, @Emp_ID1, @IT_Name, @IT_Max_Limit, @IT_Flag, @IT_Def_ID, @IT_Parent_IT, @Is_Main_Group, @IT_Doc_Name, @For_Date, @Amount, @Amount_Ess, @IT_DFlag, @IT_Level_ITMaster,@FY,@Doc_Name,@IT_Alias_Name,@IS_IT_Attah_Comp,@Is_Lock,@IT_Is_Details --  added By Ali 24012014
			END
		Close Cur_Declaration
		Deallocate Cur_Declaration
			
			
END
RETURN
