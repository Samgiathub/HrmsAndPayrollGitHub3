
CREATE PROCEDURE [dbo].[SP_GET_LEAVE_REGISTER]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID		Numeric 
	,@Cat_ID		Numeric	
	,@Grd_ID		Numeric
	,@Type_ID		Numeric 
	,@Dept_Id		Numeric
	,@Desig_Id		Numeric
	,@Emp_ID		Numeric
	--,@Leave_ID		Numeric
	,@Constraint	varchar(MAX)
	--,@PBranch_ID varchar(2) = '0'
	
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


	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			Insert Into @Emp_Cons(Emp_ID)

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	
							
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			AND I.Emp_ID in (select emp_Id from
					(select emp_id, Cmp_ID, join_Date, isnull(left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
					where Cmp_ID = @Cmp_ID   and  
					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
					or ( @From_Date <= join_Date  and @To_Date >= left_date )	
					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
					or left_date is null and  @To_Date >= Join_Date)) 
		end	

   --       CREATE table #Emp_Leave_Bal 
			--(
			--	Cmp_ID			numeric,
			--	Emp_ID			numeric,
			--	For_Date		datetime,
			--	Leave_Opening	numeric(18,1),
			--	Leave_Credit	numeric(18,1),
			--	Leave_Used		numeric(18,1),
			--	Leave_Closing	numeric(18,1),
			--	Leave_ID		numeric
			--) 

		--declare @Temp_Date datetime
		--Declare @count numeric 
		--set @Temp_Date = @From_Date 
		--set @count = 1 
		--while @Temp_Date <=@To_Date 
		--	Begin
		--		Declare @End_Date datetime
		--		set @End_Date=DBO.GET_MONTH_END_DATE(month(@Temp_Date),year(@Temp_Date))
		--		EXEC  SP_RPT_LEAVE_BALANCE_GET_SUB_SP @Cmp_ID,@Temp_Date,@End_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_Id,@Desig_Id,@Emp_ID,@Leave_ID,@Constraint
		--		set @Temp_Date = dateadd(m,1,@Temp_date)
		--	End
			
			  CREATE table #Emp_Leave_Encash 
			(
				Cmp_ID			numeric,
				Emp_ID			numeric,
				month_id		numeric,
				year_id		    numeric(10,0),
				leave_str		varchar(max)
			) 
			
		Select	LM.CMP_ID,LT.EMP_ID,LM.LEAVE_CODE,Month(Month_End_Date)[Month],Year(Month_End_Date)[Year],LT.Leave_Credit 
		--Added by Rajput 29062017
		INTO 	#LEAVE_CREDIT_TBL	 
		From	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner Join  t0200_monthly_salary EM WITH (NOLOCK)
							on EM.Emp_ID = LT.Emp_ID 
							inner join T0040_LEAVE_MASTER as LM WITH (NOLOCK) on LM.Leave_ID=LT.Leave_ID
							
							where MONTH(MONTH_END_DATE)= MONTH(LT.FOR_DATE)
							and YEAR(MONTH_END_DATE)= YEAR(LT.FOR_DATE) 
							and lt.Leave_Credit <> 0 
							and EM.Month_St_Date >= @From_Date And EM.Month_End_Date <= @To_Date and LM.Cmp_ID=@Cmp_ID


		SELECT Emp_ID, MONTH, Year,W1.LC
		INTO #LEAVE_CREDIT_FINAL
		FROM (Select Distinct Emp_ID, MONTH, Year From #Leave_Credit_Tbl) T
				CROSS APPLY (
								SELECT	DISTINCT STUFF(IsNull(REPLACE(REPLACE((
													SELECT	',' + T2.LEAVE_CODE +'-' +  CAST(CAST(T2.LEAVE_CREDIT AS NUMERIC(18,2)) AS VARCHAR(11)) AS LEAVE_CREDIT 
													FROM	#Leave_Credit_Tbl T2
													WHERE	T1.EMP_ID=T2.EMP_ID AND T1.MONTH=T2.MONTH AND T1.YEAR=T2.YEAR FOR XML PATH('')
												), '<LEAVE_CREDIT>', ''), '</LEAVE_CREDIT>', ''), ''), 1,1, '') LC
								FROM	#Leave_Credit_Tbl T1
								WHERE	T1.EMP_ID=T.EMP_ID AND T1.MONTH=T.MONTH AND T1.YEAR=T.YEAR
							) W1
		
		;WITH CTE(Cmp_ID,Emp_ID,leave_code,month_id,Year_Id,Lv_Encash_Apr_Days,Leave_Encash_Amount)
		as
		(SELECT LEA.Cmp_ID,LEA.Emp_ID,LM.leave_code,MONTH(Lv_Encash_Apr_Date),YEAR(Lv_Encash_Apr_Date),SUM(Lv_Encash_Apr_Days),SUM(Leave_Encash_Amount)
				from T0120_LEAVE_ENCASH_APPROVAL  LEA WITH (NOLOCK)
				inner JOIN @Emp_Cons E ON LEA.Emp_ID = E.emp_id
				inner JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LEA.Leave_ID = LM.Leave_ID
				group BY LEA.Emp_ID,LEA.Cmp_ID,LM.leave_code,MONTH(Lv_Encash_Apr_Date),YEAR(Lv_Encash_Apr_Date)
				
		)
		INSERT INTO #Emp_Leave_Encash (Cmp_ID,Emp_ID,month_id,year_id,leave_str)
		SELECT  cmp_id,emp_id,month_id,year_id,STUFF((SELECT '' + s.str_val FROM 
		( select ( ' ' + cast(isnull(leave_code,'') as varchar(10)) + ' - Rs.' + cast(isnull(leave_encash_amount,0) as varchar(10)) + ' For '+ cast(isnull(LV_Encash_Apr_Days,0) as varchar(12)) + ' Days ; ' ) as str_val,Cmp_ID,emp_id,month_id,year_id from CTE
		)
		 s WHERE s.Cmp_id = t.Cmp_id and s.emp_id=t.emp_id and s.month_id = t.month_id and s.year_id = t.year_id FOR XML PATH('')),1,1,'') AS CSV FROM CTE AS t GROUP BY t.Cmp_ID,t.emp_id,t.month_id,t.year_id 


		 ------------------- Add By Jignesh Patel 18-Sep-2021-------------------
		Select *  into #EmpwiseLeaveOpening from (
		Select ROW_NUMBER() over (Partition by  LT.EMP_ID,LT.Leave_ID,Month(Month_End_Date) ORDER BY LT.EMP_ID,LT.Leave_ID,Month(Month_End_Date),Lt.for_Date)  as Sr_No,	
		LM.CMP_ID,LT.EMP_ID,LT.Leave_ID,LM.LEAVE_CODE,
		Month(Month_End_Date)[Month],
		Year(Month_End_Date)[Year],
		LT.Leave_Opening,Lt.Leave_Tran_ID 
		From	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner Join  t0200_monthly_salary EM WITH (NOLOCK)
							on EM.Emp_ID = LT.Emp_ID 
							inner join T0040_LEAVE_MASTER as LM WITH (NOLOCK) on LM.Leave_ID=LT.Leave_ID
							inner join @Emp_Cons As E on LT.Emp_ID = E.Emp_ID 
							where MONTH(MONTH_END_DATE)= MONTH(LT.FOR_DATE)
							and YEAR(MONTH_END_DATE)= YEAR(LT.FOR_DATE) and 
							EM.Month_St_Date >= @From_Date And EM.Month_End_Date <= @To_Date and LM.Cmp_ID=@Cmp_ID
							-----order by LT.EMP_ID,LT.Leave_ID,Month(Month_End_Date)
		) as A Where Sr_No =1
		order by EMP_ID,Leave_ID,Month
		-------------------------------- End ---------------------------------


	  select Ms.Cmp_Id,Ms.Emp_Id,Ms.Month_St_Date,MS.Month_End_Date,Month(Month_End_Date)[Month],Year(Month_End_Date)[Year], --ELB.Cmp_ID,ELB.Emp_ID,ELB.For_Date,ELB.Leave_Opening,ELB.Leave_Credit,ELB.Leave_Used,ELB.Leave_Closing,ELB.Leave_ID,
	  Sal_Cal_Days,Grd_NAme,Dept_Name,Comp_name,Branch_Address,Gender,Date_of_join,emp_Left_date,Desig_Name,Cmp_NAme,Cmp_Address,Emp_Code,Emp_Full_Name,EM.Worker_Adult_No,EM.Father_Name,BM.Branch_ID,Ms.Present_Days as P_Days
	  ,Ms.Weekoff_Days,ms.Holiday_Days,ms.Absent_Days,Ms.Outof_Days,MS.Paid_Leave_Days,MS.Total_Leave_Days
	  ,em.Alpha_Emp_Code,Em.Emp_First_Name
	  ,BM.Branch_Name    --added jimit 10062015	
	  ,CM.cmp_state_Name 
	  ,LEA.leave_str,LF.LC, MS.Gross_Salary, MS.Actually_Gross_Salary
	  ,cast(isnull(PLOP.Leave_Opening,0) as numeric(18,2)) as 'PL_Opening'
	  
	  into #tblEmpLeaveData

	  from --#Emp_Leave_Bal ELB Left outer join 
	  
	  t0200_monthly_salary  MS WITH (NOLOCK) inner join @Emp_Cons EC on MS.Emp_Id = EC.Emp_Id

	  left outer join #Leave_Credit_Final LF on ms.Emp_ID=LF.Emp_ID AND MONTH(MS.MONTH_END_DATE) = LF.Month AND YEAR(MS.MONTH_END_DATE) = LF.Year
	  Inner Join
	    --on ELB.Emp_ID=MS.Emp_ID  inner join
	    ( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 08092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)IQ on
				MS.Emp_ID = iq.emp_Id inner join
					T0080_EMP_MASTER EM WITH (NOLOCK) ON Ms.Emp_ID = EM.EMP_ID INNER JOIN 
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON IQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON IQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON IQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IQ.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on IQ.Branch_ID = BM.Branch_ID inner join 
					T0010_COMPANY_MASTER cm WITH (NOLOCK) on Ms.cmp_Id = cm.cmp_Id 
					left JOIN #Emp_Leave_Encash LEA ON MS.Emp_ID = LEA.Emp_ID and month(MS.Month_End_Date) = LEA.month_id
					and YEAR(MS.Month_End_Date)=LEA.year_id
		
			------------------- Jignesh Patel 19-Sep-2021-----------------	
			Left Outer Join #EmpwiseLeaveOpening as PLOP ON MS.Emp_ID = PLOP.Emp_ID 
			AND MONTH(MS.MONTH_END_DATE) = PLOP.Month AND YEAR(MS.MONTH_END_DATE) = PLOP.Year
			And PLOP.Leave_Code = 'PL'
		     
			--------------------- End ---------------------

			where  ms.Month_St_Date >= @From_Date And Ms.Month_End_Date <= @To_Date --And isnull(Ms.is_FNF,0) <> 1	commented by Rajput 26062017 due to during FNF time Leave Encashamount was not show
			order by Ms.Emp_ID,Month(Month_End_Date),Year(Month_End_Date)


Create Table #tblYear
(
ForDate Datetime
)


DECLARE @ForDate datetime 

SET @ForDate=@From_Date

WHILE ( @ForDate <= @To_Date)
BEGIN
    ---PRINT 'The counter value is = ' + CONVERT(VARCHAR,@ForDate)
	Insert into #tblYear(ForDate) select @ForDate
    SET @ForDate  = Dateadd(month,1,@ForDate)
END


DECLARE @empId int 
Declare @cmpid int
Declare @Row_No int
Declare @PL_Opening decimal(18,2)
Declare @CurForDate datetime
 
 

SELECT   A.*,ROW_NUMBER() Over (order by EmpId) as SrNo
into #tblLeaveData
 from (
	Select EL.*,Ty.Emp_ID as EmpId ,Ty.ForDate,Ty.Cmp_ID as CmpId
	from #tblEmpLeaveData as EL 
	Right Outer Join (Select Distinct cmp_id ,Emp_ID,ForDate from #tblEmpLeaveData Cross join #tblYear) TY
	On EL.Emp_ID = Ty.Emp_ID And TY.ForDate = EL.Month_St_Date
   ) as A   
   

 --  --mansi st

	select em.emp_code,iq.Cmp_Name,tl.SrNo,em.Alpha_Emp_Code,em.Emp_Full_Name,em.Date_Of_Join,em.Father_name,tl.EmpId,tl.CmpId,iq.Branch_ID,iq.Grd_ID,iq.Desig_Id,iq.Dept_ID,iq.Type_ID into #tmp_fnl_leave from #tblLeaveData tl
     inner join T0080_EMP_MASTER Em on em.Emp_ID=tl.EmpId
	 inner join ( select Cmp_Name,Cmp_ID,I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID 
	        from T0095_Increment I WITH (NOLOCK) inner join 
					( select cm.Cmp_Name,max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					inner join 
					T0010_COMPANY_MASTER cm WITH (NOLOCK) on T0095_Increment.cmp_Id = cm.cmp_Id -- Ankit 08092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and T0095_Increment.Cmp_ID = @Cmp_ID
					group by emp_ID,cm.Cmp_Name  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID	)IQ on tl.EmpId = iq.emp_Id and tl.CmpId=iq.Cmp_ID

	alter table #tblLeaveData add Grd_ID Numeric,Desig_Id numeric,Dept_ID numeric,Type_ID numeric
    update #tblLeaveData  set Branch_ID= (select Branch_ID from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo)
	, Grd_ID= (select Grd_ID from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo),
	Desig_Id= (select Desig_Id from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo),
	Dept_ID= (select Dept_ID from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo),
	Type_ID= (select Type_ID from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo),
	Cmp_Name= (select Cmp_Name from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo),
	Emp_Full_Name= (select Emp_Full_Name from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo),
		Father_name= (select Father_name from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo),
				Date_Of_Join= (select Date_Of_Join from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo)
					,Emp_code= (select Emp_code from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo)
					,Alpha_Emp_Code= (select Alpha_Emp_Code from #tmp_fnl_leave fl where fl.SrNo=#tblLeaveData.SrNo)

	

	
 -- --mansi end
DECLARE emp_cursor CURSOR FOR
SELECT SrNo,Empid,CmpId,ForDate from #tblLeaveData

OPEN emp_cursor

FETCH NEXT FROM emp_cursor INTO @Row_No,@empId,@cmpid,@CurForDate


WHILE @@FETCH_STATUS = 0
BEGIN
    
	Select @PL_Opening =Isnull(PL_Opening,0) from  #tblLeaveData where empid= @empId And SrNo=@Row_No-1

	Update #tblLeaveData SEt Cmp_ID = @cmpid, Emp_id = @empid, 
	PL_Opening = isnull(@PL_Opening,0) ,P_Days =0
	,Month_St_Date = @CurForDate,Month_End_Date = dateadd(day,-1,dateadd(month,1,@CurForDate))  ,
	[month]= month(@CurForDate),[year]= year(@CurForDate)
	where empid= @empId And SrNo=@Row_No and isnull(PL_Opening,0) =0
	
    FETCH NEXT FROM emp_cursor INTO  @Row_No,@empId,@cmpid,@CurForDate

END
CLOSE emp_cursor;
DEALLOCATE emp_cursor;

select * from #tblLeaveData
order by Emp_id,SrNo 


		--UPDATE @Yearly_Leave
		--SET TOTAL = MONTH_1 + MONTH_2 + MONTH_3 + MONTH_4 + MONTH_5 +MONTH_6 + MONTH_7 + MONTH_8 + MONTH_9	
		--			+ MONTH_10 + MONTH_11 + MONTH_12 
		
		/*select  Ys.*,Grd_NAme,Dept_Name,Comp_name,Branch_Address,Desig_Name,Branch_NAme,Type_NAme 
			,Cmp_NAme,Cmp_Address,Emp_Code,Emp_Full_Name ,LEAVE_NAME
			,@From_Date as P_From_Date , @To_Date as P_To_Date
		from @Yearly_Leave  Ys inner join 
		( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID from T0095_Increment I inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)IQ on
				ys.emp_Id = iq.emp_Id inner join
					T0080_EMP_MASTER EM ON YS.EMP_ID = EM.EMP_ID INNER JOIN 
					T0040_GRADE_MASTER GM ON IQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM ON IQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM ON IQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM ON IQ.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM on IQ.Branch_ID = BM.Branch_ID inner join 
					T0010_COMPANY_MASTER cm on ys.cmp_Id = cm.cmp_Id INNER JOIN 
					T0040_LEAVE_MASTER LM ON YS.LEAVE_ID =LM.LEAVe_iD
					where LM.lEAVE_TYPE <> 'Company Purpose' AND Ys.Leave_ID  in(					
		SELECT LT.LEAVE_ID FROM T0140_LEAVE_TRANSACTION LT INNER JOIN  
		( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION 
			WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@To_DATE
		GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
		LT.FOR_DATE = Q.FOR_DATE INNER JOIN T0040_LEAVE_MASTER LM ON LT.LEAVE_ID = LM.LEAVE_ID)
		order by ys.Emp_ID ,Row_ID */
			
					
	RETURN


