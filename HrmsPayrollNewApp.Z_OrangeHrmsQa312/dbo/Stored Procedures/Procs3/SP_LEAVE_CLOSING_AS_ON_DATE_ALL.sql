---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LEAVE_CLOSING_AS_ON_DATE_ALL]
	@CMP_ID		NUMERIC ,
	@EMP_ID		NUMERIC ,
	@FOR_DATE	DATETIME = null,
	@Leave_Application numeric(18,0) = 0,  -- Added by Gadriwala Muslim 01102014
	@Leave_Encash_App_ID numeric(18,0) = 0, -- Added by Gadriwala Muslim 01102014
	@Leave_ID	NUMERIC = 0	--Added by Nimesh On 12-Sep-2015 (To get single leave balance)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
	IF @Leave_ID = 0 
		SET @Leave_ID = NULL;
	
	if Isnull(@For_Date,'') = '' 
		select @For_Date = isnull(max(For_Date),Getdate()) From T0140_LEAVE_TRANSACTION WITH (NOLOCK)  where Emp_ID = @Emp_ID
	
			--------------Sid for Comp off seperate calculation 22/01/2014
	declare @comp_off_leave_id  as numeric
	Declare @COPH_leave_id as numeric
	declare @COND_leave_id as numeric --Added Sumit COPH 29092016	
	set @COPH_leave_id = 0
	set @COND_leave_id = 0
	
	select @comp_off_leave_id = leave_id from T0040_LEAVE_MASTER WITH (NOLOCK)
	where Default_Short_Name = 'COMP' and Cmp_ID = @CMP_ID
	
	-- Added by Sumit 29092016
	select @COPH_leave_id = leave_id from T0040_LEAVE_MASTER WITH (NOLOCK)
		where isnull(Default_Short_Name,'') = 'COPH' and Cmp_ID = @CMP_ID
	
	select @COND_leave_id = leave_id from T0040_LEAVE_MASTER WITH (NOLOCK)
		where isnull(Default_Short_Name,'') = 'COND' and Cmp_ID = @CMP_ID
	
	create table #temp_CompOff
	(
		Leave_opening	decimal(18,2),
		Leave_Used		decimal(18,2),
		Leave_Closing	decimal(18,2),
		Leave_Code		varchar(32),
		Leave_Name		varchar(128),
		Leave_ID		numeric,
		CompOff_String  varchar(max) default null -- Added by Gadriwala 18022015
	)
	create table #temp_COPH  -- Sumit 29092016
		(
			Leave_opening	decimal(18,2),
			Leave_Used		decimal(18,2),
			Leave_Closing	decimal(18,2),
			Leave_Code		varchar(max),
			Leave_Name		varchar(max),
			Leave_ID		numeric,
			COPH_String  varchar(max) default null -- 
		)	
	 create table #temp_COND  -- Sumit 29092016
		(
			Leave_opening	decimal(18,2),
			Leave_Used		decimal(18,2),
			Leave_Closing	decimal(18,2),
			Leave_Code		varchar(max),
			Leave_Name		varchar(max),
			Leave_ID		numeric,
			COND_String  varchar(max) default null -- 
		)

	Declare @branch_id as Numeric
	Declare @Is_Compoff as int
	Set @Is_Compoff = 0
	
	select @branch_id = branch_id from T0095_INCREMENT WITH (NOLOCK)
	where Emp_ID = @Emp_ID and Increment_Effective_Date = (select MAX(increment_effective_date) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID = @Emp_ID and Increment_Effective_Date<=@For_Date)

	select @Is_Compoff = Isnull(Is_CompOff,0) from T0040_GENERAL_SETTING WITH (NOLOCK) Where For_Date = (Select Max(For_Date) From T0040_GENERAL_SETTING WITH (NOLOCK) Where Branch_ID = @branch_id) And Branch_ID = @branch_id
	
	--If @Is_Compoff = 1 -- Changed by Gadriwala Muslim 01102014
	--Added by Nimesh on 26-Nov-2015 
	--CompOff leave should be considered only if supplied leave id and comp off leave id is same or Leave Id does not supplied
	
	If @comp_off_leave_id = ISNULL(@Leave_ID, @comp_off_leave_id)
	
		EXEC dbo.GET_COMPOFF_DETAILS @For_Date =@FOR_DATE,@Emp_ID = @emp_id,@Cmp_ID = @cmp_id,@leave_ID = @comp_off_leave_id,@Leave_Application_ID =@Leave_Application,@Leave_Encash_App_ID = @Leave_Encash_App_ID,@Exec_For =2
		--Added by Sumit 29092016----------------------------------------------
	
	exec Get_COPH_Details @For_Date =@FOR_DATE,@Emp_ID = @emp_id,@Cmp_ID = @cmp_id,@leave_ID = @COPH_leave_id,@Leave_Application_ID =@Leave_Application,@Exec_For =2
	
	exec Get_COND_Details @For_Date =@FOR_DATE,@Emp_ID = @emp_id,@Cmp_ID = @cmp_id,@leave_ID = @COND_leave_id,@Leave_Application_ID =@Leave_Application,@Exec_For =2
		--exec [dbo].[GET_Emp_CompOFF_Balance_Get] 
		--@For_Date = @for_date, 
		--@Emp_ID	= @emp_id, 
		--@Cmp_ID = @cmp_id, 
		--@leave_ID = @comp_off_leave_id, 
		--@leave_Type = 6
	

	------------End--------------
	


--return
	DECLARE @DISPLAY_LEAVE_FOR	TINYINT;

	SELECT	@DISPLAY_LEAVE_FOR = CAST(Setting_Value AS tinyint)
	FROM	T0040_SETTING WITH (NOLOCK)
	WHERE	Cmp_ID=@Cmp_ID AND Group_By='Leave Settings' AND 
			Setting_Name = 'Display Leave Detail by Selected Period' AND Setting_Value<>''
			
	IF (@DISPLAY_LEAVE_FOR IS NULL)
		SET @DISPLAY_LEAVE_FOR = 0;
	
	
	
	IF (@DISPLAY_LEAVE_FOR = 0)
		BEGIN
		
			declare @GRD_ID		NUMERIC
			select @GRD_ID = grd_id From T0095_Increment I WITH (NOLOCK) inner join     
						   (select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  WITH (NOLOCK)  
						   where Increment_Effective_date <= @FOR_DATE and Cmp_ID = @Cmp_ID group by emp_ID) Qry on    
						   I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date Where I.Emp_ID = @Emp_ID
	
										
			DECLARE @Leave_Bal_Display_FixOpening AS NUMERIC  /*TMS - For Electrothem requirement  (Email Dated :  Apr 12, 2016) --Ankit 12042016 */
			SELECT @Leave_Bal_Display_FixOpening = Leave_Balance_Display_FixOpening FROM T0010_COMPANY_MASTER WITH (NOLOCK) WHERE Cmp_Id = @cmp_Id
			
			IF @Leave_Bal_Display_FixOpening = 1 AND EXISTS( SELECT 1 FROM T0011_module_detail WITH (NOLOCK) WHERE module_name = 'Payroll' AND Cmp_id = @Cmp_ID AND module_status = 0 )
				BEGIN
				
					DECLARE @For_Date_temp DATETIME
					SET @For_Date_temp = '01-Jan-' + CAST( YEAR(@For_Date) AS VARCHAR(4)) + ''
					
					SELECT DISTINCT
							dbo.f_lower_round(isnull(Q2.Leave_Opening,0),LT.Cmp_ID) AS Leave_Opening, 
							--dbo.f_lower_round(( ISNULL(LT.Leave_Credit,0) + ISNULL(Q1.Leave_Credit,0)),LT.Cmp_ID) AS Leave_Credit, 
							dbo.f_lower_round((ISNULL(Q1.Leave_Credit,0)),LT.Cmp_ID) AS Leave_Credit, 
							dbo.f_lower_round((ISNULL(Q1.Leave_Used,0)),LT.Cmp_ID) AS Leave_Used, 
							dbo.f_lower_round(((ISNULL(Q1.Leave_Credit,0)) - (ISNULL(Q1.Leave_Used,0))),LT.cmp_id) AS Leave_Closing,
							LM.Leave_Code, LM.Leave_Name, LT.Leave_ID,CASE WHEN lm.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type  --Added by Gadriwala Muslim 15062015
							,dbo.f_lower_round(LT.Leave_Closing,lt.Cmp_ID) AS Actual_Leave_Closing	--Ankit 22042016
							
					FROM	T0140_LEAVE_TRANSACTION AS LT WITH (NOLOCK)
					INNER JOIN (SELECT	MAX(For_Date) AS FOR_DATE, Leave_ID, Emp_ID
								FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
								WHERE	(Emp_ID = @EMP_ID) AND (For_Date <= @FOR_DATE) 
									AND (Leave_ID IN ( SELECT Leave_ID FROM V0040_LEAVE_DETAILS WHERE (Grd_ID = @GRD_ID) AND (Display_leave_balance = 1)))
								GROUP BY Emp_ID, Leave_ID
								) AS Q ON LT.Emp_ID = Q.Emp_ID AND LT.Leave_ID = Q.Leave_ID AND LT.For_Date = Q.FOR_DATE
					LEFT OUTER JOIN (SELECT	Leave_ID, Emp_ID,SUM(isnull(Leave_Used,0) + isnull(Leave_Adj_L_Mark,0) ) AS Leave_Used,SUM(Leave_Credit) AS Leave_Credit
								FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
								WHERE	(Emp_ID = @EMP_ID) AND (For_Date < @FOR_DATE) AND YEAR(For_Date) = YEAR(@For_Date)
								AND (Leave_ID IN ( SELECT Leave_ID FROM V0040_LEAVE_DETAILS WHERE (Grd_ID = @GRD_ID) AND (Display_leave_balance = 1)))
								GROUP BY Emp_ID, Leave_ID) AS Q1 ON LT.Emp_ID = Q1.Emp_ID AND LT.Leave_ID = Q1.Leave_ID 
					LEFT OUTER JOIN (SELECT Leave_ID, Emp_ID,isnull(SUM(Leave_Opening),0) AS Leave_Opening
								FROM	T0140_LEAVE_TRANSACTION WITH (NOLOCK)
								WHERE	(Emp_ID = @EMP_ID) AND For_Date = @For_Date_temp
								AND (Leave_ID IN ( SELECT Leave_ID FROM V0040_LEAVE_DETAILS WHERE (Grd_ID = @GRD_ID) AND (Display_leave_balance = 1)))
								GROUP BY Emp_ID, Leave_ID) AS Q2 ON LT.Emp_ID = Q2.Emp_ID AND LT.Leave_ID = Q2.Leave_ID 
					INNER JOIN T0040_LEAVE_MASTER AS LM WITH (NOLOCK) ON LT.Leave_ID = LM.Leave_ID
					WHERE lt.Leave_ID <> isnull(@comp_off_leave_id,0)	 and LT.Leave_ID <> isnull(@COPH_leave_id,0) and LT.Leave_ID <> isnull(@COND_leave_id,0)
					UNION										
					SELECT dbo.f_lower_round(T0040_LEAVE_MASTER.leave_negative_max_limit,T0040_LEAVE_MASTER.Cmp_ID)  AS Leave_opening,0,Leave_used,
						Leave_Closing,#temp_CompOff.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_CompOff.Leave_Name COLLATE SQL_Latin1_General_CP1_CI_AS,#temp_CompOff.Leave_ID,CASE WHEN T0040_LEAVE_MASTER.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type --Added by Gadriwala Muslim 15062015
						,Leave_Closing AS Actual_Leave_Closing
					FROM #temp_CompOff INNER JOIN T0040_LEAVE_MASTER WITH (NOLOCK) ON 	#temp_CompOff.Leave_ID =	T0040_LEAVE_MASTER.Leave_ID 
					WHERE ISNULL(T0040_LEAVE_MASTER.Display_leave_balance ,0)=1 AND cmp_ID = @cmp_ID
					union -- Added by Sumit on 29092016
						SELECT	Cast(Leave_Opening As Numeric(18,2)) As Leave_Opening,Cast(Leave_Used As Numeric(18,2)) As Leave_Used,
						Cast(0 As Numeric(18,2)) as leave_credit,Cast(LEAVE_CLOSING As Numeric(18,2)) AS LEAVE_CLOSING,
						LM.LEAVE_CODE COLLATE SQL_Latin1_General_CP1_CI_AS,LM.LEAVE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS,LM.LEAVE_ID ,Display_leave_balance,CASE WHEN T0040_LEAVE_MASTER.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type
							FROM	#temp_COPH T INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON T.Leave_ID=LM.Leave_ID 
							where	LM.Cmp_ID=@Cmp_ID
					union -- Added by Sumit on 29092016
						SELECT	Cast(Leave_Opening As Numeric(18,2)) As Leave_Opening,Cast(Leave_Used As Numeric(18,2)) As Leave_Used,
								Cast(0 As Numeric(18,2)) as leave_credit,Cast(LEAVE_CLOSING As Numeric(18,2)) AS LEAVE_CLOSING,
								LM.LEAVE_CODE COLLATE SQL_Latin1_General_CP1_CI_AS,LM.LEAVE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS,LM.LEAVE_ID ,Display_leave_balance,CASE WHEN T0040_LEAVE_MASTER.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type
						FROM	#temp_COND T INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON T.Leave_ID=LM.Leave_ID 
						where	LM.Cmp_ID=@Cmp_ID  
				
				END
			ELSE
				BEGIN	
				
					SELECT	distinct Cast(Leave_Opening As Numeric(18,2)) As Leave_Opening,Cast(Leave_Used As Numeric(18,2)) As Leave_Used,
							Cast(dbo.f_lower_round((leave_credit),Lt.cmp_id) As Numeric(18,2)) As leave_credit,  --Change By Jaina 19-07-2016
							Cast(dbo.f_lower_round((LEAVE_CLOSING),Lt.cmp_id) As Numeric(18,2)) as LEAVE_CLOSING,
							Leave_Code,LEAVE_NAME,LT.LEAVE_ID,LM.Display_leave_balance
							,Cast(dbo.f_lower_round((LEAVE_CLOSING),Lt.cmp_id) As Numeric(18,2)) AS Actual_Leave_Closing	--Ankit 22042016
							,CASE WHEN lm.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type
					FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
							right JOIN (
											SELECT	MAX(FOR_dATE) FOR_DATE , LT.LEAVE_ID,EMP_ID 
											FROM	T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
													INNER JOIN (SELECT	Leave_ID 
																FROM	V0040_LEAVE_DETAILS 
																WHERE	Grd_ID=@GRD_ID	AND CAST((CASE WHEN ISNULL(@LEAVE_ID,0) > 0 THEN 1 ELSE Display_leave_balance END) AS BIT) = 1
																) L1 ON LT.LEAVE_ID=L1.LEAVE_ID		--NIMESH: 16-Dec-2016 (Removed following IN Query and added Join to get the leave balance)
											WHERE	EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE --AND LEAVE_ID in (Select Leave_ID from V0040_LEAVE_DETAILS Where Grd_ID=@GRD_ID AND (Display_leave_balance = 0))  --Changed by Gadriwala Muslim 30-09-2016  --Change By Jaina 30-09-2016
											GROUP BY EMP_ID,LT.LEAVE_ID
										) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE 
							INNER JOIN	T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID and (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end ))
					WHERE	lt.Leave_ID <> isnull(@comp_off_leave_id,0) And LT.Leave_ID <> isnull(@COPH_leave_id,0) and LT.Leave_ID <> isnull(@COND_leave_id,0) AND IsNull(LM.Leave_ID, 0) = COALESCE(@Leave_ID, LM.Leave_ID, 0)
					union ---------sid 22/01/2014
					SELECT	Cast(Leave_Opening As Numeric(18,2)) As Leave_Opening,Cast(Leave_Used As Numeric(18,2)) As Leave_Used,
							Cast(0 As Numeric(18,2)) as leave_credit,Cast(LEAVE_CLOSING As Numeric(18,2)) AS LEAVE_CLOSING,
							LM.LEAVE_CODE COLLATE SQL_Latin1_General_CP1_CI_AS,LM.LEAVE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS,LM.LEAVE_ID ,Display_leave_balance
							,Cast(LEAVE_CLOSING As Numeric(18,2)) AS Actual_Leave_Closing
							,CASE WHEN lm.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type
					FROM	#temp_CompOff T INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON T.Leave_ID=LM.Leave_ID ---------sid 22/01/2014
					where	LM.Cmp_ID=@Cmp_ID
					union -- Added by Sumit on 290
					SELECT	Cast(Leave_Opening As Numeric(18,2)) As Leave_Opening,
					Cast(Leave_Used As Numeric(18,2)) As Leave_Used,
					Cast(0 As Numeric(18,2)) as leave_credit,
					Cast(LEAVE_CLOSING As Numeric(18,2)) AS LEAVE_CLOSING,
					LM.LEAVE_CODE COLLATE SQL_Latin1_General_CP1_CI_AS as LEAVE_CODE,
					LM.LEAVE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS as LEAVE_NAME,LM.LEAVE_ID ,Display_leave_balance,
					Cast(LEAVE_CLOSING As Numeric(18,2)) AS Actual_Leave_Closing
					,CASE WHEN lm.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type
					FROM	#temp_COPH T INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON T.Leave_ID=LM.Leave_ID 
							where	LM.Cmp_ID=@Cmp_ID and T.Leave_ID=@Leave_Id   --Change by Jaina 16-05-2017
					union -- Added by Sumit on 29092016
					SELECT	Cast(Leave_Opening As Numeric(18,2)) As Leave_Opening,Cast(Leave_Used As Numeric(18,2)) As Leave_Used,
					Cast(0 As Numeric(18,2)) as leave_credit,Cast(LEAVE_CLOSING As Numeric(18,2)) AS LEAVE_CLOSING,
					LM.LEAVE_CODE COLLATE SQL_Latin1_General_CP1_CI_AS as LEAVE_CODE,LM.LEAVE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS as LEAVE_NAME,
					LM.LEAVE_ID ,Display_leave_balance,					
					Cast(LEAVE_CLOSING As Numeric(18,2)) AS Actual_Leave_Closing
					,CASE WHEN lm.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type
					FROM	#temp_COND T INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON T.Leave_ID=LM.Leave_ID 
					where	LM.Cmp_ID=@Cmp_ID

					
				END
		END
	ELSE
		BEGIN
		
			DECLARE	@FROM_DATE		DATETIME
			DECLARE	@TO_DATE		DATETIME
			
			
			IF @DISPLAY_LEAVE_FOR = 2 
				BEGIN
					SET		@FROM_DATE	=	CAST(YEAR(@FOR_DATE) AS varchar) + '-04-01';
					IF MONTH(@FOR_DATE) < 4 
						SET		@FROM_DATE	=	DATEADD(YYYY,-1, @FROM_DATE)
				END			
			ELSE
				SET		@FROM_DATE	=	CAST(YEAR(@FOR_DATE) AS varchar) + '-01-01';
			
			
			SET	@TO_DATE = @FOR_DATE		
			IF (@LEAVE_ID > 0)
				BEGIN
					DECLARE @MAX_DATE DATETIME
					SELECT @MAX_DATE = MAX(FOR_DATE) FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK) WHERE Emp_ID=@EMP_ID AND Leave_ID=@LEAVE_ID AND For_Date < @TO_DATE GROUP BY Emp_ID 
					IF @MAX_DATE < @TO_DATE		
						SET	@FROM_DATE = @MAX_DATE					
				END
				
			
						
			SELECT	dbo.F_Lower_Round(T.Leave_Opening,LM.Cmp_ID) AS Leave_Opening,
					dbo.F_Lower_Round(T.Leave_Credit,LM.Cmp_ID) AS Leave_Credit,
					dbo.F_Lower_Round(T.Leave_Used,LM.Cmp_ID) AS Leave_Used,
					dbo.F_Lower_Round(T.LEAVE_CLOSING,LM.Cmp_ID) AS LEAVE_CLOSING,
					LM.Leave_Code COLLATE SQL_Latin1_General_CP1_CI_AS AS Leave_Code,
					LM.Leave_Name  COLLATE SQL_Latin1_General_CP1_CI_AS AS Leave_Name,				
					LM.LEAVE_ID,LM.Display_leave_balance
					,dbo.F_Lower_Round(T.LEAVE_CLOSING,LM.Cmp_ID) AS Actual_Leave_Closing	--Ankit 22042016
					,CASE WHEN LM.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type
			FROM	T0040_LEAVE_MASTER LM WITH (NOLOCK) INNER JOIN
					(
						SELECT	L.Cmp_ID,L.Emp_ID,L.LEAVE_ID,
							(SELECT TOP 1 L1.Leave_Opening FROM T0140_LEAVE_TRANSACTION  L1 WITH (NOLOCK)
							WHERE	L1.Cmp_ID=L.Cmp_ID AND L1.Emp_ID=L.Emp_ID AND L1.Leave_ID=L.Leave_ID
									AND (For_Date BETWEEN @FROM_DATE AND @TO_DATE) 
							ORDER BY L1.For_Date ASC) AS Leave_Opening,
							(SELECT TOP 1 L1.Leave_Closing FROM T0140_LEAVE_TRANSACTION  L1 WITH (NOLOCK)
							WHERE	L1.Cmp_ID=L.Cmp_ID AND L1.Emp_ID=L.Emp_ID AND L1.Leave_ID=L.Leave_ID
									AND (For_Date BETWEEN @FROM_DATE AND @TO_DATE)
							ORDER BY L1.For_Date DESC) AS LEAVE_CLOSING,
							(SELECT SUM(L1.Leave_Credit) FROM T0140_LEAVE_TRANSACTION  L1 WITH (NOLOCK)
							WHERE	L1.Cmp_ID=L.Cmp_ID AND L1.Emp_ID=L.Emp_ID AND L1.Leave_ID=L.Leave_ID
									AND (For_Date BETWEEN @FROM_DATE AND @TO_DATE)) AS Leave_Credit,
							(SELECT SUM(L1.Leave_Used) FROM T0140_LEAVE_TRANSACTION  L1 WITH (NOLOCK)
							WHERE	L1.Cmp_ID=L.Cmp_ID AND L1.Emp_ID=L.Emp_ID AND L1.Leave_ID=L.Leave_ID
									AND (For_Date BETWEEN @FROM_DATE AND @TO_DATE)) AS Leave_Used
						FROM T0140_LEAVE_TRANSACTION L WITH (NOLOCK)
						WHERE	L.Cmp_ID=@CMP_ID AND L.Emp_ID=@EMP_ID
									AND (L.For_Date BETWEEN @FROM_DATE AND @TO_DATE)
						GROUP BY L.Leave_ID,L.Cmp_ID,L.Emp_ID
					) T ON T.Cmp_ID=LM.Cmp_ID AND T.Leave_ID=LM.Leave_ID
			WHERE	T.Leave_ID <> isnull(@comp_off_leave_id,0) And T.Leave_ID <> isnull(@COPH_leave_id,0) and T.Leave_ID <> isnull(@COND_leave_id,0) AND IsNull(LM.Leave_ID, 0) = COALESCE(@Leave_ID, LM.Leave_ID, 0)
					AND LM.Display_leave_balance=1 and (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end ))
			UNION
			
			SELECT	
					dbo.F_Lower_Round(Leave_Opening,@Cmp_ID) As Leave_Opening,
					dbo.F_Lower_Round(0,@Cmp_ID) as leave_credit,
					dbo.F_Lower_Round(Leave_Used,@Cmp_ID) As Leave_Used,				
					dbo.F_Lower_Round(LEAVE_CLOSING,@Cmp_ID) AS LEAVE_CLOSING,
					LM.LEAVE_CODE COLLATE SQL_Latin1_General_CP1_CI_AS AS LEAVE_CODE,
					LM.LEAVE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS LEAVE_NAME,
					LM.LEAVE_ID ,LM.Display_leave_balance
					,dbo.F_Lower_Round(LEAVE_CLOSING,@Cmp_ID) AS Actual_Leave_Closing	--Ankit 22042016
					,CASE WHEN LM.Apply_Hourly = 1 THEN 'hour(s)' ELSE 'day(s)'  END AS Leave_Type
			FROM	#temp_CompOff C INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON C.Leave_ID=LM.Leave_ID and (1=(case isnull(leave_Status,0) when 0 then (case when isnull(InActive_Effective_Date,getdate())>getdate() then 1 else 0 end ) else  1 end ))
			WHERE	LM.Cmp_ID=@CMP_ID AND LM.Display_leave_balance=1
		END
	

	RETURN
