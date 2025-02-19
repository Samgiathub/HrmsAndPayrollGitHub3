


---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0190_MONTHLY_PRESENT_IMPORT_GET]
	 @Tran_id			NUMERIC(18,0)
	,@CMP_ID			NUMERIC(18,0)
	,@Month				NUMERIC(18,0)
	,@Year				NUMERIC(18,0)
	,@Emp_id			NUMERIC(18,0)
	,@Salary_Cycle_id	NUMERIC(18,0)
	--,@Branch_id			NUMERIC(18,0) -- Comment by nilesh patel on 04112014 
	--,@Dept_Id			Numeric(18,0) = 0 -- Comment by nilesh patel on 04112014 
	,@Branch_id			Varchar(max) = '' -- Added by nilesh patel on 04112014 
	,@Dept_Id			Varchar(max) = '' -- Added by nilesh patel on 04112014
	,@Tran_Type			CHAR(1) = ''
	--,@BSegment_Id		NUMERIC(18,0) = 0 -- Comment by nilesh patel on 04112014 
	--,@Vertical_Id		NUMERIC(18,0) = 0 -- Comment by nilesh patel on 04112014 
	--,@SVertical_Id		NUMERIC(18,0) = 0 -- Comment by nilesh patel on 04112014 
	--,@Sub_Branch_Id		NUMERIC(18,0) = 0 -- Comment by nilesh patel on 04112014 
	,@BSegment_Id		Varchar(max) = '' -- Added by nilesh patel on 04112014
	,@Vertical_Id		Varchar(max) = '' -- Added by nilesh patel on 04112014
	,@SVertical_Id		Varchar(max) = '' -- Added by nilesh patel on 04112014
	,@Sub_Branch_Id		Varchar(max) = '' -- Added by nilesh patel on 04112014
	,@All_Record_Flag	TinyInt = 1			-- Added By Hiral 13 August, 2013
	,@pgNo				NUMERIC(18,0) = 0
	,@pgSize			NUMERIC(18,0) = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	/* Comment by nilesh patel on 04112014 
	IF @Branch_id  = 0
		SET @Branch_id = NULL
	
	IF @BSegment_Id  = 0
		SET @BSegment_Id = NULL
	
	IF @Vertical_Id  = 0
		SET @Vertical_Id = NULL
	
	IF @SVertical_Id  = 0
		SET @SVertical_Id = NULL
	
	IF @Sub_Branch_Id  = 0
		SET @Sub_Branch_Id = NULL
		
	IF @Salary_Cycle_id  = 0
		SET @Salary_Cycle_id = NULL
		
	If @Dept_Id = 0
		set @Dept_Id = Null		--Added By Gadriwala Muslim 03092013 */
	
	 IF @Branch_id  = ''
		SET @Branch_id = NULL
	
	IF @BSegment_Id  = ''
		SET @BSegment_Id = NULL
	
	IF @Vertical_Id  = ''
		SET @Vertical_Id = NULL
	
	IF @SVertical_Id  = ''
		SET @SVertical_Id = NULL
	
	IF @Sub_Branch_Id  = ''
		SET @Sub_Branch_Id = NULL
		
	IF @Salary_Cycle_id  = 0
		SET @Salary_Cycle_id = NULL
		
	If @Dept_Id = ''
		set @Dept_Id = Null
		
	DECLARE @Records1 as numeric(18) 
	DECLARE @Records2 as numeric(18) 
	
	if @pgNo > 0
		begin
			set @Records1 = ((@pgNo - 1) * @pgSize) + 1
			set @Records2 = @pgNo * @pgSize
		end
	else	
		begin
			 		
			set @Records1 = 1
			set @Records2 = 999999
		end

	
	
	CREATE TABLE #import_data (
		srn	numeric(18,0),
		Tran_ID numeric(18, 0) ,
		Emp_ID numeric(18, 0),
		Cmp_ID numeric(18, 0) ,
		Month int  ,
		Year int  ,
		For_Date datetime  ,
		P_Days numeric(18, 2) ,
		Extra_Days numeric(5, 1) ,
		Extra_Day_Month numeric(18, 0) ,
		Extra_Day_Year numeric(18, 0)  ,
		Cancel_Weekoff_Day numeric(18, 0) ,
		Cancel_Holiday numeric(18, 0),
		Over_Time numeric(18, 2),
		Payble_Amount numeric(18, 2) ,
		User_ID numeric,
		Time_Stamp datetime,
		Backdated_Leave_Days numeric(18, 2),
		WO_OT_Hour numeric(18,2),
		HO_OT_Hour  numeric(18,2),
		Present_On_Holiday tinyint,
		Alpha_Emp_Code nvarchar(50),
		Emp_Full_Name nvarchar(150),
		SalDate_id numeric(18),
		Branch_ID numeric(18),
		ctc numeric(18,2),
		Imported_Emp_Code nvarchar(50),
		Imported_Emp_Name nvarchar(150),
		Vertical_ID numeric(18),
		SubVertical_ID numeric(18),
		Dept_Id numeric(18,0) --Added By Jaina 29-09-2015 
	)
	
	
	 
	DECLARE @to_date AS DATETIME
	SET @to_date = dbo.GET_MONTH_END_DATE(@Month,@Year)
	
	
	IF @Tran_Type = ''
		BEGIN
			If @All_Record_Flag = 1		-- Condition Added By Hiral 13 August, 2013
				Begin
				
						insert INTO #import_data
						SELECT  row_number() over (order by EM.Emp_ID asc) as srn,MPI.*, EM.Alpha_Emp_Code, EM.Emp_Full_Name, QrySC.SalDate_id, INC.Branch_ID, INC.CTC ,Emuser.Alpha_Emp_Code as Imported_Emp_Code,Emuser.Emp_Full_Name as Imported_Emp_Name,INC.Vertical_ID,INC.SubVertical_ID,INC.Dept_ID	--Added By Gadriwala 28092013  --Added Jaina 29-09-2015 Dept_id
										FROM T0190_MONTHLY_PRESENT_IMPORT AS MPI WITH (NOLOCK)
											LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id, ESC.emp_id AS eid 
																FROM T0095_Emp_Salary_Cycle ESC  WITH (NOLOCK)
																	INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																					FROM T0095_Emp_Salary_Cycle  WITH (NOLOCK)
																					WHERE Effective_date <= @To_Date
																					GROUP BY emp_id
																				) Qry
																	ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
															) AS QrySC
											ON QrySC.eid = MPI.Emp_ID
											
											INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = MPI.Emp_ID 
											INNER JOIN (SELECT I.Emp_ID, I.Branch_ID, I.Increment_ID, CTC, I.subBranch_ID, I.Vertical_ID, I.SubVertical_ID, I.Segment_ID ,I.Dept_ID --Added By Gadriwala Muslim 03092013
																FROM T0095_INCREMENT I  WITH (NOLOCK)
																	INNER JOIN 	(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
																			(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
																			Where Increment_effective_Date <= @to_date  And Cmp_ID=@Cmp_Id Group by emp_ID) new_inc
																			on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
																			Where TI.Increment_effective_Date <= @to_date  And Cmp_ID=@Cmp_Id group by ti.emp_id) Qry on I.Increment_Id = Qry.Increment_Id											
 
															) INC 
											ON INC.Emp_ID = MPI.Emp_ID Left Outer Join
											T0080_EMP_MASTER EMUser WITH (NOLOCK) on  MPI.User_ID = emUser.Emp_ID  --Added By Gadriwala 28092013
											
										WHERE MPI.Month = @Month AND MPI.Year = @Year
											--AND INC.Branch_ID = ISNULL(@Branch_id,INC.Branch_ID)
											--AND ISNULL(INC.Dept_ID,0 ) = ISNULL(@Dept_Id,ISNULL(INC.Dept_ID,0))		--	Added By Gadriwala Muslim 03092013
											AND ISNULL(INC.Branch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Branch_id,ISNULL(INC.Branch_ID,0)),'#') )  -- Added by nilesh on 04112014 
											AND ISNULL(INC.Dept_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Dept_Id,ISNULL(INC.Dept_ID,0)),'#') )  -- Added by nilesh on 04112014 
											AND ISNULL(QrySC.SalDate_id,0) =  ISNULL(@Salary_Cycle_id,ISNULL(QrySC.SalDate_id,0))
											--AND ISNULL(INC.subBranch_ID,0) =  ISNULL(@Sub_Branch_Id,ISNULL(INC.subBranch_ID,0))
											--AND ISNULL(INC.Vertical_ID,0) =  ISNULL(@Vertical_Id,ISNULL(INC.Vertical_ID,0)) -- Changed By Gadriwala Muslim 03092013
											--AND ISNULL(INC.SubVertical_ID,0) =  ISNULL(@SVertical_Id,ISNULL(INC.SubVertical_ID,0))
											--AND ISNULL(INC.Segment_ID,0) =  ISNULL(@BSegment_Id,ISNULL(INC.Segment_ID,0))
											AND ISNULL(INC.subBranch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Sub_Branch_Id,ISNULL(INC.subBranch_ID,0)),'#') )  -- Added by nilesh on 04112014 
											AND ISNULL(INC.Vertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Vertical_Id,ISNULL(INC.Vertical_ID,0)),'#') )  -- Added by nilesh on 04112014 
											AND ISNULL(INC.SubVertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@SVertical_Id,ISNULL(INC.SubVertical_ID,0)),'#') )  -- Added by nilesh on 04112014 
											AND ISNULL(INC.Segment_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@BSegment_Id,ISNULL(INC.Segment_ID,0)),'#') )  -- Added by nilesh on 04112014 	
											
						if @pgNo > 0
							begin
									select TOP 15 * from 
									#import_data where  srn >= @Records1 AND srn <= @Records2  ORDER BY Month,Year,Alpha_Emp_Code
									
									select count(*),cast(round((count(*)/@pgSize),0) AS NUMERIC(18) ) from  #import_data
								end
							else
								begin
									 
										select * from #import_data ORDER BY Month,Year,Alpha_Emp_Code
											
										select count(*),1 from #import_data
								end
				End
			Else
				Begin
	


						insert INTO #import_data
						SELECT  row_number() over (order by EM.Emp_ID asc) srn,MPI.*, EM.Alpha_Emp_Code, EM.Emp_Full_Name, QrySC.SalDate_id, INC.Branch_ID, INC.CTC ,Emuser.Alpha_Emp_Code as Imported_Emp_Code,isnull(Emuser.Emp_Full_Name,'Admin') as Imported_Emp_Name,INC.Vertical_ID,INC.SubVertical_ID,INC.Dept_ID --Added By Gadriwala 28092013 Added By Jaina 29-09-2015
											FROM T0190_MONTHLY_PRESENT_IMPORT AS MPI WITH (NOLOCK)
												LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id, ESC.emp_id AS eid 
																	FROM T0095_Emp_Salary_Cycle ESC  WITH (NOLOCK)
																		INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
																						FROM T0095_Emp_Salary_Cycle  WITH (NOLOCK)
																						WHERE Effective_date <= @To_Date
																						GROUP BY emp_id
																					) Qry
																		ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
																) AS QrySC
												ON QrySC.eid = MPI.Emp_ID
												
												INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = MPI.Emp_ID 
												INNER JOIN (SELECT I.Emp_ID, I.Branch_ID, I.Increment_ID, CTC, I.subBranch_ID, I.Vertical_ID, I.SubVertical_ID, I.Segment_ID ,I.Dept_ID --Added By Gadriwala Muslim 03092013
																FROM T0095_INCREMENT I  WITH (NOLOCK) 
																	INNER JOIN 	(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
																			(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
																			Where Increment_effective_Date <= @to_date And Cmp_ID=@Cmp_Id Group by emp_ID) new_inc
																			on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
																			Where TI.Increment_effective_Date <= @to_date And Cmp_ID=@Cmp_Id group by ti.emp_id) Qry on I.Increment_Id = Qry.Increment_Id											
 
															) INC  
												ON INC.Emp_ID = MPI.Emp_ID Left Outer Join
												T0080_EMP_MASTER EMUser WITH (NOLOCK) on  MPI.User_ID = emUser.Emp_ID  --Added By Gadriwala 28092013
												
											WHERE MPI.Month = @Month AND MPI.Year = @Year and mpi.cmp_id=@Cmp_id
												--AND INC.Branch_ID = ISNULL(@Branch_id,INC.Branch_ID)
												--AND ISNULL(INC.Dept_ID,0 ) = ISNULL(@Dept_Id,ISNULL(INC.Dept_ID,0))		--	Added By Gadriwala Muslim 03092013
												AND ISNULL(INC.Branch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Branch_id,ISNULL(INC.Branch_ID,0)),'#') )  -- Added by nilesh on 04112014 
											    AND ISNULL(INC.Dept_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Dept_Id,ISNULL(INC.Dept_ID,0)),'#') )  -- Added by nilesh on 04112014 
												AND ISNULL(QrySC.SalDate_id,0) =  ISNULL(@Salary_Cycle_id,ISNULL(QrySC.SalDate_id,0))
												--AND ISNULL(INC.subBranch_ID,0) =  ISNULL(@Sub_Branch_Id,ISNULL(INC.subBranch_ID,0))
												--AND ISNULL(INC.Vertical_ID,0) =  ISNULL(@Vertical_Id,ISNULL(INC.Vertical_ID,0)) -- Changed By Gadriwala Muslim 03092013
												--AND ISNULL(INC.SubVertical_ID,0) =  ISNULL(@SVertical_Id,ISNULL(INC.SubVertical_ID,0))
												--AND ISNULL(INC.Segment_ID,0) =  ISNULL(@BSegment_Id,ISNULL(INC.Segment_ID,0))
												AND ISNULL(INC.subBranch_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Sub_Branch_Id,ISNULL(INC.subBranch_ID,0)),'#') )  -- Added by nilesh on 04112014 
												AND ISNULL(INC.Vertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@Vertical_Id,ISNULL(INC.Vertical_ID,0)),'#') )  -- Added by nilesh on 04112014 
												AND ISNULL(INC.SubVertical_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@SVertical_Id,ISNULL(INC.SubVertical_ID,0)),'#') )  -- Added by nilesh on 04112014 
												AND ISNULL(INC.Segment_ID,0) in (SELECT  CAST(DATA  AS Numeric) FROM dbo.Split(ISNULL(@BSegment_Id,ISNULL(INC.Segment_ID,0)),'#') )  -- Added by nilesh on 04112014 	
												AND MPI.Payble_Amount >= 0			--Changed By Gadriwala 08102013		-- Added By Hiral 13 August, 2013
												
					if @pgNo > 0
						begin
					
										select top 15 * from 
										#import_data where srn >= @Records1 AND srn <= @Records2 ORDER BY Month,Year,Alpha_Emp_Code
										 
										
										select count(*),cast(round((count(*)/@pgSize),0) AS NUMERIC(18) ) from 
										#import_data
							end
						else
							begin
							
										 
										select * from #import_data
											ORDER BY Month,Year,Alpha_Emp_Code
										 
										
										select count(*),1 from 
										#import_data
								
							end
					
				End	
		 END
		 
	ELSE IF @Tran_Type = 'D'
		BEGIN	
			IF NOT EXISTS (SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @emp_id AND MONTH(Month_End_Date) = @month AND YEAR(Month_End_Date) = @year)
				BEGIN
					DELETE FROM T0190_MONTHLY_PRESENT_IMPORT
						WHERE     (Tran_ID = @tran_id)
				END
			ELSE
				BEGIN
					RAISERROR('Salary Exists',16,2)
				END
		END
	RETURN


