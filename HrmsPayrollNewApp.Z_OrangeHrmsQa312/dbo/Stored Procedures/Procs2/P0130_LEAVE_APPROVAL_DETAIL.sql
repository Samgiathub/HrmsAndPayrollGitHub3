CREATE PROCEDURE [dbo].[P0130_LEAVE_APPROVAL_DETAIL]    
  @Row_ID   NUMERIC OUTPUT    
 ,@Leave_Approval_ID NUMERIC    
 ,@Cmp_ID   NUMERIC    
 ,@Leave_ID   NUMERIC    
 ,@From_Date   DATETIME    
 ,@To_Date   DATETIME    
 ,@Leave_Period  NUMERIC(18,2)    
 ,@Leave_Assign_As VARCHAR(15)    
 ,@Leave_Reason  NVARCHAR(Max) -- Changed by Gadriwala Muslim 22092015    
 ,@Login_ID   NUMERIC(18,0)       
 ,@System_Date  DATETIME    
 ,@Is_import   INT = 0    
 ,@tran_type   VARCHAR(1)    
 ,@M_Cancel_WO_HO TINYINT = 0    
 ,@Half_Leave_Date DATETIME = NULL    
 ,@User_Id numeric(18,0) = 0     
 ,@IP_Address varchar(30)= ''     
 ,@Leave_Out_Time  Datetime = ''  --Ankit 21022014    
    ,@Leave_In_Time   Datetime = ''  --Ankit 21022014    
    ,@NightHalt   numeric(18,0) = 0    
 ,@strLeaveCompOff_Dates varchar(max) = '' --added by Gadriwala Muslim 01102014    
 ,@Half_Payment tinyint =0 --Hardik 19/12/2014    
 ,@Warning_flag tinyint = 0 -- Added by Gadriwala Muslim 22092015    
 ,@Rules_Violate tinyint = 0 -- Added by Gadriwala Muslim 24092015    
AS    
  SET NOCOUNT ON   
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
  SET ARITHABORT ON   
     
 ----Advance Leave Restriction --Ankit 03092016----    
 DECLARE @UpToDate VARCHAR(100)    
 DECLARE @UpTo_Days NUMERIC    
 DECLARE @UpTo_Error VARCHAR(500)    
 SET @UpToDate = ''    
 SET @UpTo_Days = 0    
 SET @UpTo_Error = ''    
     
     
 SELECT @UpTo_Days = setting_Value FROM T0040_SETTING WITH (NOLOCK) WHERE cmp_Id = @Cmp_ID AND Setting_Name='Add number of days to apply leave in advance'    
     
 IF @UpTo_Days <> 0 AND @To_Date >= DATEADD(d,@UpTo_Days,@From_Date)    
  BEGIN    
   SET @UpToDate = CONVERT(VARCHAR(15),DATEADD(d,@UpTo_Days,@From_Date),103)    
   SET @UpTo_Error = '@@ You Can Apply Leave Up To ' + @UpToDate + '(' + CAST(@UpTo_Days AS VARCHAR(5)) +') Days. @@'    
   RAISERROR (@UpTo_Error , 16, 2)    
   RETURN;    
  END     
 -------------------------------------    
 DECLARE @empId as numeric(18) = 0  
 SELECT @empId = Emp_ID from T0120_LEAVE_APPROVAL where Leave_Approval_ID = @Leave_Approval_ID and Cmp_ID = @Cmp_ID   
 If ((SELECT count(1) FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN   
        T0095_INCREMENT I WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID AND E.INCREMENT_ID = I.INCREMENT_ID LEFT OUTER JOIN           
        T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I.DEPT_ID = DM.DEPT_ID INNER JOIN         
        T0180_LOCKED_ATTENDANCE SPE WITH (NOLOCK) ON E.EMP_ID = SPE.EMP_ID AND [YEAR] = YEAR(EOMONTH(@From_Date))  
        AND [MONTH] = MONTH(EOMONTH(@From_Date))  
      WHERE E.CMP_ID = @CMP_ID and SPE.Emp_Id = @empId) > 0)  
 BEGIN  
   
  Raiserror('@@ Attendance Lock for this Period. @@',16,2)  
  return -1          
 END  

 --START Deepal Below is for Leave Base on Desgination DT:- 23092024
	If @tran_type in ('I','U')
	BEGIN
			DECLARE  @ID as int = 0
			Select @ID = Cat_ID 
			From T0095_Increment I 
			INNER JOIN
			( SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID 
				FROM T0095_INCREMENT I2 
				INNER JOIN 
				(
					SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
					FROM T0095_INCREMENT I3
					WHERE I3.Increment_effective_Date <= GETDATE() and I3.Cmp_ID = @Cmp_ID and I3.Increment_Type <> 'Transfer' and I3.Increment_Type <> 'Deputation' AND I3.EMP_ID = @empId
					GROUP BY I3.EMP_ID  
				 ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID 
				 WHERE I2.INCREMENT_EFFECTIVE_DATE <= GETDATE() and I2.Cmp_ID = @Cmp_ID and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
				 GROUP BY I2.emp_ID  
			) Qry on    I.Emp_ID = Qry.Emp_ID   and I.Increment_ID = Qry.Increment_ID WHERE I.CMP_ID = @Cmp_ID AND I.EMP_ID = @empId 
	

			if NOT exists(SELECT 1 FROM LEAVEODLIMITDESIGNATIONWISE WHERE LEAVEID = @LEAVE_ID AND Id = @ID)
			BEGIN
					Declare @ODLimit as tinyint = 10 -- increse from 5 to 10 by tejas
					If exists(SELECT 1 FROM V0110_Leave_Application_Detail V Inner join T0040_LEAVE_MASTER LM on V.Leave_ID = LM.Leave_ID and Leave_Code = 'OD'  		
								WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @empId and (Application_Status = 'P' or Application_Status='F') and V.Leave_ID = @Leave_ID 
								AND From_Date >= DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0)  and To_Date <= DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1)
					)	
					BEGIN
						Declare @leaveCountButNotApproved as int = 0
						SELECT @leaveCountButNotApproved = Sum(Leave_Period) 
						FROM V0110_Leave_Application_Detail V WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @empId and (Application_Status = 'P' or Application_Status='F') and Leave_ID = @Leave_ID
						AND From_Date >= DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0)  and To_Date <= DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1) 
						if @ODLimit < (cast(isnull(@leaveCountButNotApproved,0) as int) + cast(isnull(@Leave_Period,0) as int))
						BEGIN
								RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
								RETURN;
						END
					ENd
					if EXISTS(select 1 from T0040_LEAVE_MASTER where Cmp_ID = @Cmp_ID and Leave_ID = @Leave_ID and Leave_Code = 'OD')
					BEGIN
						if @Leave_Period > @ODLimit 
						BEGIN
								RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
								RETURN;
						END
					END

					if EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION WHERE Cmp_ID = @Cmp_ID and Emp_ID = @EmpId and Leave_ID = @Leave_ID 
							  AND FOR_DATE BETWEEN DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0) AND  DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1))
					BEGIN 		
							Declare @LeaveUsed as int =0
							SELECT @LeaveUsed = sum(Leave_Used) 
							FROM T0140_LEAVE_TRANSACTION L Inner join T0040_LEAVE_MASTER LM on L.Leave_ID = LM.Leave_ID and Leave_Code = 'OD' 
							WHERE L.Cmp_ID = @Cmp_ID and Emp_ID = @EmpId and L.Leave_ID = @Leave_ID AND FOR_DATE BETWEEN DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0) AND  DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1) AND Leave_Used = 1

							If @ODLimit < (cast(isnull(@LeaveUsed,0) as int) + cast(isnull(@Leave_Period,0) as int))
							BEGIN
								RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
								RETURN;
							END
					END
			END
		END
	--END Deepal Below is for Leave Base on Desgination DT:- 23092024

 ----START Deepal Below is for Leave Base on Desgination DT:- 23092024
	--DECLARE  @DesigId as int = 0
	--Select @DesigId =  Desig_Id 
	--From T0095_Increment I 
 --   INNER JOIN
 --   ( SELECT MAX(I2.INCREMENT_ID) AS INCREMENT_ID, I2.EMP_ID 
	--	FROM T0095_INCREMENT I2 
 --       INNER JOIN 
 --       (
	--		SELECT MAX(i3.INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
 --           FROM T0095_INCREMENT I3
 --           WHERE I3.Increment_effective_Date <= GETDATE() and I3.Cmp_ID = @Cmp_ID and I3.Increment_Type <> 'Transfer' and I3.Increment_Type <> 'Deputation' AND I3.EMP_ID = @empId
 --           GROUP BY I3.EMP_ID  
 --        ) I3 ON I2.Increment_Effective_Date=I3.Increment_Effective_Date AND I2.EMP_ID=I3.Emp_ID 
 --        WHERE I2.INCREMENT_EFFECTIVE_DATE <= GETDATE() and I2.Cmp_ID = @Cmp_ID and I2.Increment_Type <> 'Transfer' and I2.Increment_Type <> 'Deputation'
 --        GROUP BY I2.emp_ID  
 --   ) Qry on    I.Emp_ID = Qry.Emp_ID   and I.Increment_ID = Qry.Increment_ID WHERE I.CMP_ID = @Cmp_ID AND I.EMP_ID = @empId 
	

	--If exists(SELECT 1 FROM V0110_Leave_Application_Detail V Inner join T0040_LEAVE_MASTER LM on V.Leave_ID = LM.Leave_ID and Leave_Code = 'OD'  		
	--		WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @empId and (Application_Status = 'P' or Application_Status='F') and V.Leave_ID = @Leave_ID 
	--		AND From_Date >= DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0)  and To_Date <= DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1) 
	--		--BETWEEN DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0) AND  DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1)
	--	)
	--BEGIN
	--	Declare @leaveCountButNotApproved as int = 0
	--	SELECT @leaveCountButNotApproved = Sum(Leave_Period) 
	--	FROM V0110_Leave_Application_Detail V WHERE V.Cmp_ID = @Cmp_ID and V.Emp_ID = @empId and (Application_Status = 'P' or Application_Status='F') and Leave_ID = @Leave_ID
	--	AND From_Date >= DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0)  and To_Date <= DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1) 
		
	--	If EXISTS(SELECT 1 FROM LEAVEODLIMITDESIGNATIONWISE WHERE LEAVEID = @LEAVE_ID AND DESIGNATIONID = @DESIGID AND ODLIMIT < (cast(isnull(@leaveCountButNotApproved,0) as int) + cast(isnull(@Leave_Period,0) as int)))	
	--	BEGIN
	--			--print 11
	--			RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
	--			RETURN;
	--	END
	--END

	--if EXISTS(select 1 from LeaveODLimitDesignationWise where LeaveId = @Leave_ID and CmpId = @Cmp_ID)
	--BEGIN 		
	--	if EXISTS(SELECT 1 FROM T0140_LEAVE_TRANSACTION L Inner join T0040_LEAVE_MASTER LM on L.Leave_ID = LM.Leave_ID and Leave_Code = 'OD' 
	--				WHERE L.Cmp_ID = @Cmp_ID and Emp_ID = @empId and L.Leave_ID = @Leave_ID 
	--			   AND FOR_DATE BETWEEN DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0) AND  DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1) 
	--			   AND Leave_Used = 1)
	--	BEGIN 		
	--		Declare @LeaveUsed as int =0
	--		SELECT @LeaveUsed = sum(Leave_Used) 
	--		FROM T0140_LEAVE_TRANSACTION L Inner join T0040_LEAVE_MASTER LM on L.Leave_ID = LM.Leave_ID and Leave_Code = 'OD' 
	--		WHERE L.Cmp_ID = @Cmp_ID and Emp_ID = @empId and L.Leave_ID = @Leave_ID AND FOR_DATE BETWEEN DATEADD(MM,DATEDIFF(MM, 0, @FROM_DATE),0) AND  DATEADD(MM,DATEDIFF(MM, -1, @FROM_DATE),-1) AND Leave_Used = 1

	--		If EXISTS(SELECT 1 FROM LEAVEODLIMITDESIGNATIONWISE WHERE LEAVEID = @LEAVE_ID AND DESIGNATIONID = @DESIGID AND ODLIMIT < (cast(isnull(@LEAVEUSED,0) as int) + cast(isnull(@Leave_Period,0) as int)))	
	--		BEGIN
	--			--print 22
	--			RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
	--			RETURN;
	--		END
	--	END
	--	else
	--	BEGIN
	--		if EXISTS(select 1 from LeaveODLimitDesignationWise where DESIGNATIONID = @DESIGID AND  LeaveId = @Leave_ID and @Leave_Period > ODLimit)
	--		BEGIN
	--		--print 33
	--			--delete from T0100_LEAVE_APPLICATION where Leave_Application_ID = @Leave_Application_ID
	--			RAISERROR ('Leave Is Not Allowed Beyond Monthly Max Limit' , 16, 2)
	--			RETURN;
	--		END
	--	END
	--END		  
 --   --END Deepal Below is for Leave Base on Desgination DT:- 23092024
	
 DECLARE @J AS VARCHAR(10)    
 SET @J= CAST(@Leave_Period AS VARCHAR(10))    
     
 --Alpesh 04-Jul-2012    
 DECLARE @Leave_Max  NUMERIC(18,2)    
     
 Declare @Old_Leave_Approval_ID numeric    
 Declare @Old_Cmp_ID numeric    
 Declare @Old_Leave_ID numeric    
 Declare @Old_From_Date datetime    
 Declare @Old_To_Date datetime    
 Declare @Old_Leave_Period numeric(18,1)    
 Declare @Old_Leave_Assign_As varchar(15)    
 Declare @Old_Leave_Reason varchar(100)    
 Declare @Old_Login_ID numeric(18,0)       
 Declare @Old_System_Date datetime    
 Declare @Old_Is_import int     
 Declare @Old_tran_type varchar(1)    
 Declare @Old_M_Cancel_WO_HO tinyint     
 Declare @Old_Half_Leave_Date datetime     
 Declare @OldNightHalt numeric(18,0)    
 declare @Old_Leave_CompOff_Dates as varchar(max) --added by Gadriwala Muslim 01102014    
 declare @OldValue as varchar(max)    
 --declare @Old_Half_Payment as varchar(1)    
     
 Declare @Total_Cancel_Day as Numeric(18,0) -- Added by rohit on 26072014    
 set @Total_Cancel_Day = 0    
     
 Declare @Old_Emp_Name    nvarchar(60)       
 Declare @Old_Leave_Name    nvarchar(50)     
 Declare @New_Emp_Name    nvarchar(60)       
 Declare @New_Leave_Name    nvarchar(50)    
 Declare @Import_Flag  numeric    
 declare @Old_Rules_Violate as tinyint -- Added by Gadriwala Muslim 24092015    
 declare @Old_Warning_flag as tinyint -- Added by Gadriwala muslim 24092015    
      
 set @Old_Leave_Approval_ID = 0    
 set @Old_Cmp_ID  = 0    
 set @Old_Leave_ID  = 0    
 set @Old_From_Date  = null    
 set @Old_To_Date  = null    
 set @Old_Leave_Period  = 0    
 set @Old_Leave_Assign_As  = ''    
 set @Old_Leave_Reason  = ''    
 set @Old_Login_ID  = 0    
 set @Old_System_Date  = null    
 set @Old_Is_import  = 0    
 set @Old_tran_type  = ''    
 set @Old_M_Cancel_WO_HO  = 0    
 set @Old_Half_Leave_Date  = null    
 set @Old_Leave_CompOff_Dates = '' --added by Gadriwala Muslim 01102014    
 set @OldValue = ''    
 set @New_Emp_Name = ''    
 set @New_Leave_Name = ''    
 Set @Old_Emp_Name    = ''    
 Set @Old_Leave_Name   = ''    
 Set @OldNightHalt = 0    
 --Set @Old_Half_Payment = 0    
 Set @Import_Flag = 0    
 set @Old_Rules_Violate = 0 -- Added by Gadriwala Muslim 24092015    
 set @Old_Warning_flag = 0 -- Added by Gadriwala Muslim 24092015    
 DECLARE @Emp_ID NUMERIC    
 Declare @Approval_Status char    
 Declare @Approval_Comments Varchar(100)--Mukti(28092017)    
 Declare @cut_off_date As Datetime    
 SELECT @Emp_ID = Emp_ID, @Cmp_ID = Cmp_ID,@Approval_Status=Approval_Status,@Approval_Comments=Approval_Comments FROM T0120_LEAVE_APPROVAL WITH (NOLOCK) WHERE Leave_Approval_ID = @Leave_Approval_ID     
 SELECT @Leave_Max = ISNULL(Leave_Max,0) FROM T0040_Leave_Master WITH (NOLOCK) WHERE cmp_id = @Cmp_ID AND Leave_ID = @Leave_ID     
     
 -- Added by Ali 18042014 -- Start    
 -- Overwrite @Leave_Max value     
  Declare @Year as numeric    
  Set @Year = YEAR(GETDATE())    
      
  IF MONTH(GETDATE())> 3    
  BEGIN    
   SET @Year = @Year + 1    
  END    
  Declare @date as varchar(20)      
  Set @date = '31-Mar-'+ convert(varchar(5),@Year)     
      
  Set @Leave_Max = (select     
  case when ISNULL(temp.Max_Leave,0)=0 then lm.Leave_Max else temp.Max_Leave end as Leave_Max      
  from T0040_Leave_MASTER LM WITH (NOLOCK) left join     
  ( Select Max_Leave,Leave_ID from T0050_LEAVE_DETAIL WITH (NOLOCK) where Leave_ID = @Leave_ID     
   and Cmp_ID = @Cmp_ID and Grd_ID in (Select I.Grd_ID from   dbo.T0095_Increment I WITH (NOLOCK) INNER JOIN   --Changed by Hardik 10/09/2014 for Same Date Increment    
   (SELECT MAX(Increment_Id) AS Increment_Id,Emp_ID FROM dbo.T0095_Increment IM WITH (NOLOCK)   
   WHERE Increment_Effective_date <= @date GROUP BY emp_ID ) Qry ON I.Emp_ID = Qry.Emp_ID     
   AND I.Increment_Id = Qry.Increment_Id INNER JOIN    
   dbo.T0080_EMP_MASTER EM WITH (NOLOCK) ON EM.Emp_ID = Qry.Emp_ID     
   where em.Cmp_ID = @Cmp_ID and em.Emp_ID = @Emp_ID)    
  ) as temp on LM.leave_id = temp.leave_id     
  where LM.Leave_ID = @Leave_ID )    
   -- Added by Ali 18042014 -- End    
         
 --set @To_Date = DATEADD(day, @Leave_Period-1, @From_Date)    
 -- below commented by Mitesh on 27/12/2011    
 --If substring(@j,CharIndex('.',@j,1)+1, 2) > 0    
 --Begin    
 -- Set @To_Date = DATEADD(day, @Leave_Period, @From_Date)  --If Decimal Leave 4.5,1.5 etc    
 --End    
 --Else    
 --Begin    
 -- Set @To_Date = DATEADD(day, @Leave_Period-1, @From_Date) --If Not Decimal Leave 1,2,4,5 etc    
 --End     
 --Above Formula Changed By Nikunj at 5-March-2011.Becuase It ALTER Problem.Bug Complianed By CTNT Client      
      
 -- Start Added by mitesh on 14/02/2012 for salary lock     
 DECLARE @Branch_ID AS NUMERIC(18,0)    
 SET @Branch_ID = 0    
 declare @apply_hourly as numeric    
 set @apply_hourly = 0    
    
 Declare @Is_Backdated as tinyint    
 Set @Is_Backdated = 0    
      
 --Select @Is_Backdated = ISNULL(is_backdated_application,0) From T0100_LEAVE_APPLICATION     
 --Where Leave_Application_Id In (Select Leave_Application_ID From T0120_LEAVE_APPROVAL Where Leave_Approval_ID = @Leave_Approval_ID)    
 --Changed by Gadriwala Muslim 19062015 -  For Month Lock Message issue in Leave admin Approval.    
 Select @Is_Backdated = ISNULL(Is_Backdated_App,0) From T0120_LEAVE_APPROVAL WITH (NOLOCK) Where Leave_Approval_ID = @Leave_Approval_ID    
 select @apply_hourly = Apply_hourly from T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Leave_ID = @Leave_ID     
     
  if @apply_hourly = 0 and @Leave_Assign_As = 'Part Day'    
  begin    
    --set @Total_Leave_Days = @Total_Leave_Days * 0.125    
   set @Leave_Period = @Leave_Period --* 0.125    
  end    
     
     
 SELECT  @Branch_ID = Branch_ID     
  FROM T0095_Increment I  WITH (NOLOCK)   
   INNER JOIN (SELECT MAX(Increment_Id) AS Increment_Id, Emp_ID   --Changed by Hardik 10/09/2014 for Same Date Increment    
       FROM T0095_Increment WITH (NOLOCK)     
       WHERE Increment_Effective_date <= @To_Date AND Cmp_ID = @Cmp_ID     
       GROUP BY emp_ID) Qry     
   ON I.Emp_ID = Qry.Emp_ID AND I.Increment_Id = Qry.Increment_Id     
  WHERE I.Emp_ID = @Emp_ID      
     
 --commented by Mukti(start)27092017    
 --IF @Approval_Status <> 'R'  --Mukti(18092017)    
 --begin            
 -- IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WHERE MONTH =  MONTH(@To_Date) AND YEAR =  YEAR(@To_Date) AND Cmp_ID = @CMP_ID AND (Branch_ID = ISNULL(@Branch_ID,0) OR Branch_ID = 0) And @Is_Backdated = 0)    
 --  BEGIN    
 --   Declare @cut_off_date As Datetime    
 --   select  @cut_off_date= isnull(MAX(Cutoff_Date),@To_Date) from T0200_MONTHLY_SALARY where Emp_ID = @Emp_ID      
 --   if @cut_off_date >= @To_Date     
 --   begin    
        
 --    RAISERROR('Month Lock',16,2)    
 --    RETURN -1    
 --   end    
 --  END    
 -- end    
 --commented by Mukti(end)27092017    
     
 --Added by Mukti(15112017)start    
 --IF @Approval_Status = 'A'    
 -- BEGIN    
 --  if (@Approval_Comments in ('Email Approval' ,'Reject All' ,'Approve All'))  --Mukti(18092017)      
  DECLARE @MONTH_ST_DATE DATETIME       
  DECLARE @MONTH_END_DATE DATETIME      
  DECLARE @MONTH_LOCK INTEGER     
  DECLARE @YEAR_LOCK INTEGER     
  DECLARE @Cutoffdate_Salary DATETIME       
      
  DECLARE @CUTOFFDATE AS VARCHAR(15)    
       
  SELECT @Cutoffdate_Salary=isnull(Cutoffdate_Salary,'1900-01-01') FROM DBO.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE CMP_ID =@Cmp_id AND BRANCH_ID = @Branch_id    
  AND FOR_DATE = (SELECT MAX(FOR_DATE) FROM DBO.T0040_GENERAL_SETTING WITH (NOLOCK) WHERE    
  FOR_DATE <=@FROM_DATE AND BRANCH_ID = @Branch_id AND CMP_ID =@Cmp_id)    
       
  ----Added By Jimit 19032019 As restrict Leave Approval in month lock Cut Off case Bug No 8552.    
  SET @CUTOFFDATE = Convert(Varchar(4),DatePart(YYYY,@FROM_DATE)) + '-' + Convert(Varchar(2),MONTH(@FROM_DATE)) + '-' + Convert(Varchar(2),DatePart(D,@Cutoffdate_Salary))    
  ----Ended    
         
  if @Cutoffdate_Salary <> '1900-01-01'    
   BEGIN    
  if @FROM_DATE > @CUTOFFDATE     
   BEGIN  
     SET @MONTH_LOCK =  Month(DateAdd(MONTH,1,@FROM_DATE))    
     SET @YEAR_LOCK=YEAR(DateAdd(YEAR,1,@FROM_DATE))    
   END  
  ELSE    
   BEGIN  
    SET @MONTH_LOCK = Month(@FROM_DATE)    
    SET @YEAR_LOCK=YEAR(@FROM_DATE)    
   END  
 END    
  ELSE    
    BEGIN    
  SELECT @MONTH_ST_DATE= Sal_St_Date,@MONTH_END_DATE = Sal_End_Date     
  FROM F_Get_SalaryDate (@Cmp_id,@Branch_id,MONTH(@FROM_DATE),YEAR(@FROM_DATE))    
        
  If @FROM_DATE >= @MONTH_ST_DATE And @FROM_DATE <= @MONTH_END_DATE    
   BEGIN  
     SET @MONTH_LOCK = Month(@FROM_DATE)    
     SET @YEAR_LOCK=YEAR(@FROM_DATE)    
   END  
  Else    
   BEGIN  
     SET @MONTH_LOCK = Month(DateAdd(MONTH,1,@FROM_DATE))    
     SET @YEAR_LOCK=YEAR(DateAdd(YEAR,1,@FROM_DATE))    
    END    
   END  
       
    
    IF EXISTS(SELECT 1 FROM  T0250_MONTHLY_LOCK_INFORMATION WITH (NOLOCK)   
       WHERE (MONTH =  @MONTH_LOCK and YEAR =  @YEAR_LOCK)     
         and Cmp_ID = @CMP_ID and (Branch_ID = isnull(@Branch_ID,0) or Branch_ID = 0))    
     Begin      
        
        IF EXISTS(select 1 from T0040_SETTING WITH (NOLOCK) where cmp_id=@CMP_ID and setting_name='Restrict User to Apply Leave if Month is Locked' and setting_value = 1)           
       or ((@TRAN_TYPE = 'U' or @TRAN_TYPE = 'D') and @Is_Backdated = 0)    
       BEGIN    
        Raiserror('Month Lock',16,2)    
        return -1            
       END    
     End    
  --Added by Mukti(15112017)end    
      
 --Added by Jaina 11-09-2017    
 IF exists (SELECT 1 FROM T0100_LEFT_EMP WITH (NOLOCK) where Emp_ID=@Emp_ID AND (Left_Date <= @From_Date OR  left_date <= @To_date or left_date = @To_Date) and Cmp_ID= @Cmp_ID)    
 BEGIN    
   RAISERROR('Left Employee Leave Can''t Approved',16,2)    
   RETURN -1    
 END     
       
 --Added by Jaina 30-03-2017     
 IF @Approval_Status = 'A'    
 Begin      
  --For Full Day/ First Half / Second Half Leave Availability  
  --select @Cmp_Id,@Emp_ID,@From_Date,@To_Date,@Half_Leave_Date,@Leave_Assign_As,1  
  exec P_Check_Leave_Availability @Cmp_Id=@Cmp_Id,@Emp_ID=@Emp_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Half_Date=@Half_Leave_Date,@Leave_type=@Leave_Assign_As,@Raise_Error=1    
      
 END    
 --Paternity Leave Validation    
 --Added by Jaina 08-05-2018 Start        
 if exists (select 1 from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_id and Leave_Type = 'Paternity Leave')    
 BEGIN    
  DECLARE @F_date datetime    
  declare @T_date datetime    
  declare @message varchar(200)    
      
  Create table #Paternity_Leave    
  (    
   Leave_Tran_Id numeric(18,0),    
   Emp_id numeric(18,0),    
   For_Date datetime,    
   Leave_Opening numeric(18,2),    
   Leave_Closing numeric(18,2),    
   Laps_Days numeric(18,2),    
   From_Date datetime,    
   To_Date datetime    
  )    
      
   
   
  insert INTO #Paternity_Leave    
  EXEC P_RESET_PATERNITY_LEAVE @CMP_ID = @CMP_ID,@EMP_ID=@EMP_ID    
  
  IF exists (select 1 from #PATERNITY_LEAVE where Emp_id = @Emp_id)    
  BEGIN        
  
   
   IF NOT EXISTS(SELECT 1 FROM #PATERNITY_LEAVE WHERE @FROM_DATE BETWEEN FROM_DATE AND TO_DATE AND    
   @TO_DATE BETWEEN FROM_DATE AND TO_DATE AND Emp_id=@emp_ID)    
   BEGIN    
  
    SELECT @F_date = From_Date, @T_date = To_Date     
    FROM #PATERNITY_LEAVE WHERE Emp_id=@emp_ID    
         
    set @message = '@@ You can apply leave between '+ convert(varchar(11),@F_date,103) + ' To ' + convert(varchar(11),@T_date,103) + '@@'    
  
    RAISERROR(@message ,16,2)    
    return    
   END    
       
   --Added by Jaina 02-07-2018 ( After validity complete can't reject leave)        
   if exists (SELECT 1 FROM #PATERNITY_LEAVE WHERE Emp_id=@emp_ID and To_Date < GETDATE())    
   BEGIN    
     set @message = '@@ Can''t update leave after validity period @@'    
         
     RAISERROR(@message ,16,2)    
     return    
   END    
  END    
      
      
      
 EnD    
 --Added by Jaina 08-05-2018 End    
     
 --Added by Jaina 21-01-2019 Start    
 DECLARE @ExitNoice int = 0     
 SELECT @ExitNoice = Restrict_LeaveAfter_ExitNotice FROM T0040_LEAVE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_Id AND Leave_ID=@Leave_ID    
     
 IF exists (select 1 from T0200_Emp_ExitApplication WITH (NOLOCK) where cmp_id=@Cmp_id and emp_id=@Emp_id AND (status='H' OR status = 'P'))    
    AND @ExitNoice =1    
  BEGIN    
    
    if exists (select 1 from T0200_Emp_ExitApplication WITH (NOLOCK) where cmp_id=@Cmp_id and emp_id=@Emp_id AND (status='H' or status = 'P')    
      and ((@From_date between resignation_date AND last_date) AND (@To_Date BETWEEN resignation_date and last_date)) )    
      BEGIN    
      set @message = '@@You can''t apply this leave after exit application @@'        
      RAISERROR(@message ,16,2)    
      return    
      END     
     IF exists (SELECT 1 FROM T0100_LEFT_EMP WITH (NOLOCK) where Emp_ID=@Emp_ID AND (Left_Date <= @From_Date OR  left_date <= @To_date) and Cmp_ID= @Cmp_ID)    
     BEGIN    
       RAISERROR('Left Employee Can''t Apply Leave',16,2)    
       RETURN -1    
     END      
         
  END                
 ELSE    
  BEGIN                     
    IF exists (SELECT 1 FROM T0100_LEFT_EMP WITH (NOLOCK) where Emp_ID=@Emp_ID AND (Left_Date <= @From_Date OR  left_date <= @To_date) and Cmp_ID= @Cmp_ID)    
     BEGIN               
      RAISERROR('Left Employee Can''t Apply Leave',16,2)          
      return          
     END        
  END    
     
 --Added by Jaina 21-01-2019 End    
     
       
 --For Continuous Leave and Monthly Leave Condition    
 --exec P_Validate_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period,@Leave_Application_ID=0,@Leave_Approval_ID= @Leave_Approval_ID    
     
     
 -- End Added by mitesh on 14/02/2012 for salary lock    
     
 --Alpesh 18-Jun-2012    
 --IF EXISTS(SELECT Sal_tran_Id FROM T0200_MONTHLY_SALARY WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID AND     
 --    ((@From_Date >= Month_St_Date AND @From_Date <= Month_End_Date) OR     
 --     (@To_Date >= Month_St_Date AND  @To_Date <= Month_End_Date) OR     
 --     (Month_St_Date >= @From_Date AND Month_St_Date <= @To_Date) OR    
 --     (Month_End_Date >= @From_Date AND Month_End_Date <= @To_Date)))    
 -- BEGIN    
 --  RAISERROR('@@This Months Salary Exists@@',16,2)    
 --  RETURN -1    
 -- END    
 ---- End ----       
   
 DECLARE @LEAVE_APPLICATION_ID AS NUMERIC    
     
 SELECT @LEAVE_APPLICATION_ID = LA.LEAVE_APPLICATION_ID    
 FROM T0100_LEAVE_APPLICATION LA WITH (NOLOCK) INNER JOIN     
    T0110_LEAVE_APPLICATION_DETAIL LAD WITH (NOLOCK) ON LA.LEAVE_APPLICATION_ID = LAD.LEAVE_APPLICATION_ID    
 WHERE LA.CMP_ID = @CMP_ID AND LA.EMP_ID = @EMP_ID  AND LA.APPLICATION_STATUS <> 'R'    
     AND LAD.FROM_DATE = @FROM_DATE AND LAD.TO_DATE = @TO_DATE        
        
IF @tran_type ='I'     
 BEGIN          
    
  --select @from_date As From_date ,@to_Date As To_date      
      
  IF @Approval_Status <> 'R'    
  Begin    
    
   exec P_Validate_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@LEAVE_APPLICATION_ID,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date    
   --Check Consecutive Leave with Present Days    
   --exec P_Check_Present_Days_On_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@LEAVE_APPLICATION_ID,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date    
  END    
  SELECT @Row_ID = ISNULL(MAX(Row_ID),0) +1   FROM T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)   
      
  select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID    
  select @Old_Leave_Name = Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_ID    
      
  --set @OldValue = ' New Value # Leave Approval : ' + convert(nvarchar(10),@Leave_Approval_ID) + ' # Cmp Id : ' + convert(nvarchar(10),@Cmp_ID ) + ' # Employee Name : ' + @old_Emp_Name + ' # Leave Name : ' + @Old_Leave_Name + ' # Leave Id : ' + convert(nvarchar(10),@Leave_ID) + ' # From Date : '  + convert(nvarchar(21),@From_Date) + ' # To Date : ' + convert(nvarchar(21),@To_Date) + ' # Leave Period : ' + convert(nvarchar(10),@Leave_Period ) + ' # Assign as : ' +  @Leave_Assign_As + ' # Reason : ' + @Leave_Reason + ' # Login id : '  + convert(nvarchar(10),@Login_ID) + ' # Date : ' + convert(nvarchar(21),@System_Date) + ' # Half Date Leave : '  +   convert(nvarchar(21),@Half_Leave_Date) + ' # NightHalt : ' + CAST(@NightHalt as varchar(max)) + ' # Leave_CompOff_Dates : ' + @strLeaveCompOff_Dates  + ' # Half_Payment : ' + cast(@Half_Payment as varchar(1)) + ' # Warning_Flag : ' + cast(@Warning_flag as varchar(1)) + ' # Rules_Violate : ' + cast(@Rules_Violate as varchar(1))    
  --print 4534    
    
  if @Import_Flag = 0     
   Begin    
     
   --SELECT @Leave_Approval_ID,@Cmp_ID,@Leave_ID,@From_Date,@To_Date,@Leave_Period,@Leave_Assign_As,@Leave_Reason,@Row_ID,@Login_ID,@System_Date,@Is_Import,@M_Cancel_WO_HO,@Half_Leave_Date,@Leave_Out_Time,@Leave_In_Time,@NightHalt,@strLeaveCompOff_Dates,@Half_Payment,@Warning_flag,@rules_violate  
   --RETURN  
   
   INSERT INTO T0130_LEAVE_APPROVAL_DETAIL    
    (Leave_Approval_ID, Cmp_ID, Leave_ID, From_Date, To_Date, Leave_Period, Leave_Assign_As, Leave_Reason, Row_ID, Login_ID, System_Date,IS_Import,M_Cancel_WO_HO,Half_Leave_Date,leave_Out_time,leave_In_time,NightHalt,Leave_CompOff_Dates,Half_Payment,Warning_flag,rules_violate)    
    VALUES(@Leave_Approval_ID,@Cmp_ID,@Leave_ID,@From_Date,@To_Date,@Leave_Period,@Leave_Assign_As,@Leave_Reason,@Row_ID,@Login_ID,@System_Date,@Is_Import,@M_Cancel_WO_HO,@Half_Leave_Date,@Leave_Out_Time,@Leave_In_Time,@NightHalt,@strLeaveCompOff_Dates,@Half_Payment,@Warning_flag,@rules_violate) --Changed by Gadriwala Muslim 22092015    
     
   End    
      
 END     
ELSE IF @tran_type ='U'     
 BEGIN    
  IF @Approval_Status <> 'R'    
  BEGIN    
   exec P_Validate_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@LEAVE_APPLICATION_ID,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date    
   --Check Consecutive Leave with Present Days    
   --exec P_Check_Present_Days_On_Leave @Emp_Id=@Emp_Id,@Cmp_ID=@Cmp_ID,@Leave_ID=@Leave_ID,@From_Date=@From_Date,@To_Date=@To_Date,@Leave_Period=@Leave_Period,@Leave_Application_ID=@LEAVE_APPLICATION_ID,@Leave_Assign_As=@Leave_Assign_As,@Half_Leave_Date=@Half_Leave_Date    
  END    
     SELECT @Row_ID = ISNULL(MAX(Row_ID),0) +1   FROM T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK)         
          
  select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID    
  select @Old_Leave_Name = Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @Leave_ID    
      
  set @OldValue = ' New Value # Leave Approval : ' + convert(nvarchar(10),@Leave_Approval_ID) + ' # Cmp Id : ' + convert(nvarchar(10),@Cmp_ID ) + ' # Employee Name : ' + @old_Emp_Name + ' # Leave Name : ' + @Old_Leave_Name + ' # Leave Id : ' + convert(nvarchar(10),@Leave_ID) + ' # From Date : '  + convert(nvarchar(21),@From_Date) + ' # To Date : ' + convert(nvarchar(21),@To_Date) + ' # Leave Period : ' + convert(nvarchar(10),@Leave_Period ) + ' # Assign as : ' +  @Leave_Assign_As + ' # Reason : ' + @Leave_Reason + ' # Login id : '  + convert(nvarchar(10),@Login_ID) + ' # Date : ' + convert(nvarchar(21),@System_Date) + ' # Half Date Leave : '  +   convert(nvarchar(21),@Half_Leave_Date)  + ' # Leave_CompOff_Dates :' + @strLeaveCompOff_Dates  + '# Warning_Flag :' + Cast(@Warning_flag As Varchar(10)) + ' # Rules_Violate :' + Cast(@Rules_Violate As Varchar(10))    
      
      
  if @apply_hourly = 0 and @Leave_Assign_As = 'Part Day'    
  begin    
   --set @Total_Leave_Days = @Total_Leave_Days * 0.125    
   set @Leave_Period  = @Leave_Period  --* 0.125    
  end    
      
  INSERT INTO T0130_LEAVE_APPROVAL_DETAIL    
                        (Leave_Approval_ID, Cmp_ID, Leave_ID, From_Date, To_Date, Leave_Period, Leave_Assign_As, Leave_Reason, Row_ID, Login_ID, System_Date,IS_Import,M_Cancel_WO_HO,Half_Leave_Date,leave_Out_time,leave_In_time,NightHalt,Leave_CompOff_Dates,Half_Payment,Warning_flag,rules_Violate)    
  VALUES     (@Leave_Approval_ID,@Cmp_ID,@Leave_ID,@From_Date,@To_Date,@Leave_Period,@Leave_Assign_As,@Leave_Reason,@Row_ID,@Login_ID,@System_Date,@Is_Import,@M_Cancel_WO_HO,@Half_Leave_Date,@Leave_Out_Time,@Leave_In_Time,@NightHalt,@strLeaveCompOff_Dates
,@Half_Payment,@Warning_flag,@Rules_Violate) -- Changed by gadriwala muslim 22092015    
         
 END    
ELSE IF @tran_type ='D'    
 BEGIN       
        
  SELECT @Emp_ID = Emp_ID  FROM T0120_LEAVE_APPROVAL WITH (NOLOCK) WHERE Leave_Approval_ID = @Leave_Approval_ID    
      
  IF EXISTS(SELECT Sal_tran_Id FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID AND     
    ( (@From_Date >= Month_St_Date AND @From_Date <= Month_End_Date) OR     
      (@To_Date >= Month_St_Date AND  @To_Date <= Month_End_Date) OR     
      (Month_St_Date >= @From_Date AND Month_St_Date <= @To_Date) OR    
      (Month_End_Date >= @From_Date AND Month_End_Date <= @To_Date)))    
   BEGIN    
    RAISERROR('@@This Months Salary Exists@@',16,2)    
    RETURN -1    
   END    
  ELSE IF EXISTS(SELECT 1 FROM T0150_LEAVE_CANCELLATION WITH (NOLOCK) WHERE Leave_Approval_id = @Leave_Approval_ID)    
   BEGIN    
    RAISERROR('@@Leave Cancellation Exists@@',16,2)    
    RETURN -1    
   END    
  ELSE    
   BEGIN      
       
   Select    
     @old_cmp_id = Cmp_ID     
    ,@old_Leave_ID  = Leave_ID     
    ,@Old_From_Date = From_Date    
    ,@Old_To_Date = To_Date     
    ,@Old_Leave_Period = Leave_Period     
    ,@old_Leave_Assign_As  = Leave_Assign_As     
    ,@old_Leave_Reason  = Leave_Reason     
    ,@Old_Login_ID = Login_ID     
    ,@Old_System_Date = System_Date     
    ,@Old_Half_Leave_Date  = Half_Leave_Date     
    ,@OldNightHalt = NightHalt    
    ,@Old_Leave_CompOff_Dates = Leave_CompOFf_Dates  --Added by Gadriwala Muslim 01102014    
    ,@Old_Rules_Violate = rules_Violate --Added by Gadriwala Muslim 24092015    
    ,@Old_Warning_flag = warning_flag --Added by Gadriwala Muslim 24092015    
    from T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK) where  Row_ID = @Row_ID      
       
   select @old_Emp_Name = Alpha_Emp_Code + ' ' + Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID    
   select @Old_Leave_Name = Leave_Name from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID = @old_Leave_ID    
      
       
   set @OldValue = ' old Value # Leave Approval : ' + convert(nvarchar(10),@Leave_Approval_ID) + ' # Cmp Id : ' + convert(nvarchar(10),@old_cmp_id) + ' # Employee Name : ' + @old_Emp_Name + ' # Leave Name : ' + @Old_Leave_Name + ' # Leave Id : ' + convert  (nvarchar(10),@old_Leave_ID ) + ' # From Date : '  + convert(nvarchar(21),@Old_From_Date) + ' # To Date : ' + convert(nvarchar(21),@Old_To_Date) + ' # Leave Period : ' + convert(nvarchar(10),@Old_Leave_Period)  + ' # Assign as : ' +  @Old_Leave_Assign_As   + ' # Reason : ' + @Old_Leave_Reason + ' # Login id : '  + convert(nvarchar(10),@Old_Login_ID) + ' # Date : ' + convert(nvarchar(21),@Old_System_Date) + ' # Half Date Leave : '  +  convert(nvarchar(21),@Old_Half_Leave_Date) + ' # NightHalt : ' + Cast(@OldNightHalt as varchar(max)) + '# Leave_CompOff_Dates :' + @Old_Leave_CompOff_Dates + '# Warning_Flag :' + Cast(@Warning_flag As Varchar(10)) + '# Rules_violate :' + Cast(@Rules_Violate As Varchar(10)) --Changed by Gadriwala Muslim 24092015    
        
         
    DELETE  FROM T0130_LEAVE_APPROVAL_DETAIL WHERE Row_ID = @Row_ID    
    IF NOT EXISTS(SELECT  Row_ID FROM T0130_LEAVE_APPROVAL_DETAIL WITH (NOLOCK) WHERE Leave_Approval_ID = @Leave_Approval_ID)    
     BEGIN    
      DELETE FROM T0120_LEAVE_APPROVAL WHERE Leave_Approval_ID = @Leave_Approval_ID    
     END    
   END    
 END    
      
 -- Added By Ali 03102013 -  Start    
 DECLARE @count as int    
 Set @count = 0    
     
 SET @count = (select ISNULL((select Leave_Application_ID from T0120_LEAVE_APPROVAL WITH (NOLOCK) where Leave_Approval_ID = @Leave_Approval_ID),0))    
     
 IF @count = 0    
 BEGIN    
  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Admin Leave Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1    
 END    
 ELSE    
 BEGIN    
  exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Leave Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1    
 END    
 -- Added By Ali 03102013 -  End    
     
     
    
RETURN    
    