

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
Create  PROCEDURE [dbo].[SP_Get_Email_ToCC_Bkp_Deepali_17012024] 
    -- Add the parameters for the stored procedure here
     @Emp_ID                NUMERIC(18,0)
    ,@Cmp_ID                NUMERIC(18,0)
    ,@Module_Name           NVARCHAR(MAX)
    ,@Flag                  TinyInt = 1     -- Flag will be 0, If Employee will be in CC . 
                                            -- Flag will be 1, If Employee will be in To
                                            -- Flag will be 2, If Employee will not in To not in CC
                                            
    ,@Leave_ID              Numeric(18,0) = 0   -- Added By Hiral On 07 Aug, 2013 -- For Five Level Leave Approval 
    ,@Rpt_Level             TinyInt = 0         -- Added By Hiral On 07 Aug, 2013 -- For Five Level Leave Approval 
    ,@Final_Approval        TinyInt = 1         -- Added By Hiral On 07 Aug, 2013 -- For Five Level Leave Approval    
	
	,@File_status_ID        Numeric(18,0) = 0   -- Added By mansi 11 july,2022--For File_status_Id 
    ,@Forward_Emp_Id        Numeric(18,0) = 0   -- Added By mansi 11 july,2022--For get mail id of forward_emp  
    ,@Submit_Emp_Id         Numeric(18,0) = 0   -- Added By mansi 11 july,2022--For get mail id of Submit_emp                         
	,@Review_Emp_Id         Numeric(18,0) = 0   -- Added By mansi 11 july,2022--For get mail id of review_emp  
	,@Review_by_Emp_Id      Numeric(18,0) = 0   -- Added By mansi 11 july,2022--For get mail id of review_by_emp 
	,@log_Emp_Id      Numeric(18,0) = 0   -- Added By mansi 12 july,2022--For get mail id of log_emp_Id 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    
    CREATE TABLE #Temp_To
        (Output_To Varchar(max))
        
    CREATE TABLE #Temp_CC
        (Output_CC Varchar(max))
        
    CREATE TABLE #Temp_Emp
        (Output_Emp Varchar(Max))
        
    CREATE TABLE #Temp_BCC
        (Output_BCC Varchar(max))

    CREATE TABLE #Rpt_branch_manager
        (Emp_id numeric(18,0))
        
    Declare @EMAIL_NTF_SENT AS Numeric(1,0)
    Declare @To_Manager AS Tinyint
    Declare @To_Hr As Tinyint
    Declare @To_Account As Tinyint
    Declare @Other_Email As Varchar(max)
    Declare @Is_Manager_CC As Tinyint
    Declare @Is_HR_CC As Tinyint
    Declare @Is_Account_CC  As Tinyint
    declare @hremail as int --added on 3 feb 2016 sneha
	Declare @Other_Email_BCC As Varchar(max)  --Added By Jimit 14052019
    set @hremail =0--added on 3 feb 2016 sneha
    
    Select @EMAIL_NTF_SENT = EMAIL_NTF_SENT From T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK) Where CMP_ID = @Cmp_ID 
    And EMAIL_TYPE_NAME = @Module_Name
    
    
    If @EMAIL_NTF_SENT = 1
        Begin
        
        
            Select @To_Manager=To_Manager, @To_Hr=To_Hr, @To_Account=To_Account, @Other_Email=Other_Email, 
                   @Is_Manager_CC=Is_Manager_CC, @Is_HR_CC=Is_HR_CC, @Is_Account_CC=Is_Account_CC,
					@Other_Email_BCC = Other_Email_Bcc
            From T0040_EMAIL_NOTIFICATION_CONFIG WITH (NOLOCK)
			Where CMP_ID = @Cmp_ID And EMAIL_TYPE_NAME = @Module_Name


            --If @To_Manager = 1
            --  Begin
            --      If @Is_Manager_CC = 1
            --          insert into #Temp_CC
            --              Select distinct(Work_Email)  From T0080_EMP_MASTER where Emp_ID IN (
            --                      Select R_Emp_ID from T0090_EMP_REPORTING_DETAIL Where Emp_ID = @Emp_ID Union
            --                      Select Emp_Superior From T0080_EMP_MASTER Where Emp_ID = @Emp_ID) and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()
            --      Else
            --          insert into #Temp_To 
            --              Select distinct(Work_Email) From T0080_EMP_MASTER where Emp_ID IN (
            --                      Select R_Emp_ID from T0090_EMP_REPORTING_DETAIL Where Emp_ID = @Emp_ID Union
            --                      Select Emp_Superior From T0080_EMP_MASTER Where Emp_ID = @Emp_ID) and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()
            --  End
                
            -- =====================================================================
            
            declare @is_Rm as tinyint
            declare @is_Bm as TINYINT
            DECLARE @emp_branch AS NUMERIC
            declare @Is_HOD as tinyint
            declare @Emp_Dept as numeric
            declare @Is_Hr  as tinyint --added by sneha 3 Feb 2016
            Declare @scheme_id as numeric(18,0) -- Added by rohit on 27052016
            Declare @is_PRM as tinyint -- Added by rohit on 05102016
            DECLARE @Is_RMToRm as TINYINT ---Added By Jimit 21/12/2017
            
            --Comment by nilesh patel on 21-Jan-2019 
            --SELECT @emp_branch = inc.branch_id FROM dbo.T0080_EMP_MASTER EM INNER JOIN 
            --dbo.T0095_INCREMENT inc ON inc.increment_id = em.Increment_ID 
            --WHERE em.emp_id = @Emp_ID

            --Comment by nilesh patel on 21-Jan-2019
            --SELECT @Emp_Dept = inc.dept_ID FROM dbo.T0080_EMP_MASTER EM INNER JOIN 
            --dbo.T0095_INCREMENT inc ON inc.increment_id = em.Increment_ID 
            --WHERE em.emp_id = @Emp_ID     --Added by Sumit 24092015   

            --Added Condition by Nilesh Patel on 21-Jan-2019
            Select Top 1 
                    @emp_branch = Isnull(Branch_ID,0),
                    @Emp_Dept = Isnull(Dept_ID,0)
                From T0095_INCREMENT WITH (NOLOCK)
            Where Increment_Effective_date <= GetDate() and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_id
            ORDER By Increment_Effective_date DESC,Increment_ID DESC
			
            
            set @is_Bm = 0
            set @is_Rm = 0
            set @Is_HOD=0 --Added by Sumit 24092015
            set @Is_Hr = 0--added by sneha 3 feb 2016
            set @scheme_id = 0 -- Added by rohit on 27052016
            set @Is_PRM = 0 -- Added by rohit on 05102016
            SET @Is_RMToRm = 0
                    
            If @To_Manager = 1
                Begin   
                                    
                    Declare @App_Emp_ID As Numeric(18,0)
                    Set @App_Emp_ID = 0

                    DECLARE @R_Emp_Id1 as NUMERIC
                    SET @R_Emp_Id1 = 0
                    If (@Module_Name = 'Leave Application' Or @Module_Name = 'Leave Approval') And @Final_Approval = 0
                        Begin
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            --And Scheme_ID = (Select Scheme_ID From T0095_EMP_SCHEME Where Emp_ID = @Emp_ID) 
                                            AND Scheme_Id = (SELECT DISTINCT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                             T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id INNER join
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Leave'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Leave'
                                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM ,@scheme_id = Scheme_Id 
                                            ,@Is_RMToRm = Is_RMToRM  --Added By Jimit 21122017                                  
                                            From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            --And Scheme_ID = (Select Scheme_ID From T0095_EMP_SCHEME Where Emp_ID = @Emp_ID) 
                                            AND Scheme_Id = (SELECT DISTINCT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id INNER join
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Leave'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Leave'
                                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 

                                    if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin                   
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                            where ERD.Emp_ID = @Emp_ID
                                        end
                                    else IF @App_Emp_ID = 0  and @is_Bm =1 --and @Rpt_Level = 0
                                        BEGIN
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                         BEGIN
                                                --insert into #Rpt_branch_manager
                                                
                                                
                                                
                                                SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                where ERD.Emp_ID = @Emp_ID
                                                
                                                
                                                
                                                If @R_Emp_Id1 <> 0
                                                    BEGIN
                                                            INSERT INTO #Rpt_branch_manager
                                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                            where ERD.Emp_ID = @R_Emp_Id1
                                                            
                                                            
                                                            
                                                    END
                                                
                                                
                                                
                                         END
                                End   
								
								
                        End
                    
                    If @Is_Manager_CC = 1
                        Begin
                            If (@Module_Name = 'Leave Application' Or @Module_Name = 'Leave Approval') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)

										
                                End
							
                            --Else If @Module_Name <> 'Leave Application' Or @Module_Name <> 'Leave Approval' Or @Module_Name <> 'Loan Application' Or @Module_Name <> 'Loan Approval' 
                            Else If @Module_Name <> 'Leave Application' And @Module_Name <> 'Leave Approval' And @Module_Name <> 'Loan Application' And @Module_Name <> 'Loan Approval' 
                                    And @Module_Name <> 'Attendance Regularization' And @Module_Name <> 'Attendance Regularization Approve' And @Module_Name <> 'Travel Application' 
                                    And @Module_Name <> 'Reimbursement\Claim Application' And @Module_Name <> 'Reimbursement\Claim Approval' And @Module_Name <> 'Claim Application'
                                    and @Module_Name <> 'Pre-CompOff Application' and @Module_Name <> 'Pre-CompOff Approval' 
                                    and @Module_Name <> 'Employee Probation' and @Module_Name <> 'Employee Training'
                                    and @Module_Name <> 'Exit Approval' and @Module_Name <> 'Clearance Approval'  --Added By Jaina 06-06-2016
                                    and @Module_Name <> 'GatePass' 
                                    and @Module_Name <> 'Employee Increment Application' and @Module_Name <> 'Employee Increment Approval' --adde by jimit 14112016
                                    and @Module_Name <> 'Recruitment Request'   --Added By Jaina 10-11-2016
                                    and @Module_Name <> 'Optional Holiday Application' --Added by sumit on 05122016
                                    and @Module_Name <> 'Optional Holiday Approval' --Added by sumit on 21122016
                                    and @Module_Name <> 'Employee Warning'  --Added by Jaina 07-07-2018                                 
									and @Module_Name <> 'Claim Approval'  --Added by Jaina 07-07-2018                 
									and @Module_Name <> 'Vehicle Application'
									and @Module_Name <> 'File Application' --added by mansi file app
									And @Module_Name <> 'File Approval'  --added by mansi file
                                Begin
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID IN (
                                                --Select R_Emp_ID from T0090_EMP_REPORTING_DETAIL Where Emp_ID = @Emp_ID 
                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID
                                                Union
                                                Select Emp_Superior From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID) and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()
                                End
								
								
								         
                        End             
                    Else
                        Begin
                        --SELECT * FROM #Temp_To
                            If (@Module_Name = 'Leave Application' Or @Module_Name = 'Leave Approval') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                            --Else If @Module_Name <> 'Leave Application' Or @Module_Name <> 'Leave Approval' 
                            Else If @Module_Name <> 'Leave Application' And @Module_Name <> 'Leave Approval' 
                                    And @Module_Name <> 'Loan Application' And @Module_Name <> 'Loan Approval' 
                                    And @Module_Name <> 'Attendance Regularization' And @Module_Name <> 'Attendance Regularization Approve' 
                                    And @Module_Name <> 'Travel Application' 
                                    And @Module_Name <> 'Reimbursement\Claim Application' And @Module_Name <> 'Reimbursement\Claim Approval'
                                    And @Module_Name <> 'Travel Settlement Application'
                                    And @Module_Name <> 'Claim Application'
                                    And @Module_Name <> 'Change Request Application' AND @Module_Name <> 'Change Request Approval'
                                    and @Module_Name <> 'Pre-CompOff Application' and @Module_Name <> 'Pre-CompOff Approval' 
                                    and @Module_Name <> 'Employee Probation' and @Module_Name <> 'Employee Training'
                                    and @Module_Name <> 'Exit Approval' and @Module_Name <> 'Clearance Approval'  --Added By Jaina 06-06-2016
                                    and @Module_Name <> 'GatePass'
                                    and @Module_Name <> 'Recruitment Request'   --Added By Jaina 10-11-2016
                                    and @Module_Name <> 'Employee Increment Application' and @Module_Name <> 'Employee Increment Approval' --adde by jimit 14112016
                                    and @Module_Name <> 'Optional Holiday Application' --Added by sumit on 05122016
                                    and @Module_Name <> 'Optional Holiday Approval' --Added by sumit on 21122016
                                    and @Module_Name <> 'Pass Responsibility'   --Added by Jaina 11-04-2017
                                    and @Module_Name <> 'Employee Warning' --Added by Jaina 07-07-2018
									 and @Module_Name <> 'Claim Approval'  and @Module_Name <> 'Vehicle Application'
									   And @Module_Name <> 'File Application'  --added by mansi file app 
								    And @Module_Name <> 'File Approval'  --added by mansi file
                                Begin
							
                                    insert into #Temp_To 
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID IN (
                                                --Select R_Emp_ID from T0090_EMP_REPORTING_DETAIL Where Emp_ID = @Emp_ID 
                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID)
                                                --Union
                                                --Select Emp_Superior From T0080_EMP_MASTER Where Emp_ID = @Emp_ID) 
                                                and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()   
												
                                End

                        End
                    
					If (@Module_Name = 'Loan Application' Or @Module_Name = 'Loan Approval') And @Final_Approval = 0
                        Begin
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT DISTINCT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id INNER join -- Added by nilesh on 09102015 for multiple Scheme Provision
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Loan'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Loan'
                                                            where @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(T1.Leave, '#')))
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                            ,@Is_RMToRm = Is_RMToRM  --Added By Jimit 21122017
                                        From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT DISTINCT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id INNER join  -- Added by nilesh on 09102015 for multiple Scheme Provision
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Loan'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Loan'
                                                            where @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(T1.Leave, '#')))
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                                            
                                    if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin                                               
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID
                                            --SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL where Emp_ID = @Emp_ID
                                        end
                                    else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK)
                                                    WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                         BEGIN                                                  
                                                SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                where ERD.Emp_ID = @Emp_ID
                                                
                                                
                                                If @R_Emp_Id1 <> 0
                                                    BEGIN
                                                            INSERT INTO #Rpt_branch_manager
                                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                            where ERD.Emp_ID = @R_Emp_Id1
                                                    END
                                                
                                                
                                                
                                         END
                                End                     
                        End
                        
                    If @Is_Manager_CC = 1
                        Begin
                            If (@Module_Name = 'Loan Application' Or @Module_Name = 'Loan Approval') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                        End             
                    Else
                        Begin
                            If (@Module_Name = 'Loan Application' Or @Module_Name = 'Loan Approval') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                        End
                        
                    If (@Module_Name = 'Attendance Regularization' Or @Module_Name = 'Attendance Regularization Approve') And @Final_Approval = 0
                        Begin
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Attendance Regularization'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Attendance Regularization')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                            ,@Is_RMToRm = Is_RMToRM     --Added By Jimit 21122017
											,@Is_HOD=Is_HOD   --Added by Jaina 15-05-2020
                                            From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Attendance Regularization'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Attendance Regularization')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                                            
                                    If @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        Begin                                               
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID
                                        End
                                    Else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
									Else if @App_Emp_ID = 0  and @Is_HOD =1	--Added by Jaina 15-05-2020
										Begin											
										insert into #Rpt_branch_manager
											SELECT Emp_id FROM T0095_Department_Manager WITH (NOLOCK)
											WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_Department_Manager WITH (NOLOCK) WHERE Dept_ID = @Emp_Dept AND Effective_Date <= GETDATE()) AND dbo.T0095_Department_Manager.Dept_Id = @Emp_Dept
										
										End
                                        ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                            END
                                                
                                End
                                                            
                        End
                        
                    If @Is_Manager_CC = 1
                        Begin
                            If (@Module_Name = 'Attendance Regularization' Or @Module_Name = 'Attendance Regularization Approve') And @Final_Approval = 0
                                Begin
                                    
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)                          
                                End
                        End             
                    Else
                        Begin
                            If (@Module_Name = 'Attendance Regularization' Or @Module_Name = 'Attendance Regularization Approve') And @Final_Approval = 0
                                Begin
                                    
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                            End
							
                   If @Module_Name = 'Travel Application' And @Final_Approval = 0
                        Begin    
						--======================Code Commented by Yogesh on 29032023========================================================
                            --If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                            --                AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                            --                                (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                            --                                where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Travel'
                            --                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Travel')
                            --                And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
											--return
											--======================Code Commented by Yogesh on 29032023========================================================
											--======================Code Updated by Yogesh on 29032023========================================================
											SELECT QES.Scheme_ID into #Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Travel'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Travel'

															
							Select distinct App_Emp_ID into #App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id in (Select Scheme_Id from #Scheme_ID)
                                           -- And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#'))
											--======================Code Updated by Yogesh on 29032023========================================================
										
							If Exists (select App_Emp_ID from #App_Emp_ID)


                                Begin
								--======================Code Commented by Yogesh on 29032023========================================================
                                    --Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                    --,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                    --From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                    --        AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                    --                        (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                    --                        where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Travel'
                                    --                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Travel')
									--                      And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
									--======================Code Commented by Yogesh on 29032023========================================================
									--======================Code Updated by Yogesh on 29032023========================================================

									
									

									  Select distinct @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                    ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                    From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id in (Select  Scheme_Id from #Scheme_ID)
                                         --  And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
										   --select @Leave_ID

										 --  select @App_Emp_ID
                                     --======================Code Updated by Yogesh on 29032023========================================================      
									 --select @App_Emp_ID
                                    If @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        Begin       
										
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID
                                        End
                                    Else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end
										
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END 
                                End                     
                        End
                    
                    If @Module_Name = 'Travel Settlement Application' And @Final_Approval = 0
                        Begin       
                                        
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                            
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Travel Settlement'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Travel Settlement')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM,@Is_HOD=Is_HOD 
                                            ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                        From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Travel Settlement'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Travel Settlement')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                                
                                    If @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        Begin   
                                                                                    
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) 
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID
                                            --SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL where Emp_ID = @Emp_ID   
                                                                                    
                                        End
                                    Else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN   
                                            
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                    Else if @App_Emp_ID = 0  and @Is_HOD =1 --Added by Sumit 24092015
                                        Begin
                                        insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_Department_Manager WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_Department_Manager WITH (NOLOCK) WHERE Dept_ID = @Emp_Dept AND Effective_Date <= GETDATE()) AND dbo.T0095_Department_Manager.Dept_Id = @Emp_Dept
                                        
                                        End
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1  WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                            
                                End
                                                            
                        End
                        
                    
					
                    If (@Module_Name = 'Claim Application' Or @Module_Name = 'Claim Approval')  And @Final_Approval = 0 
                        BEGIN          
							print 'Claim Application and Claim Approval'
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                            
                                            AND Scheme_Id in (SELECT QES.Scheme_ID 
															 from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
																	(select max(effective_date) as effective_date,emp_id 
																	 from T0095_EMP_SCHEME IES WITH (NOLOCK)
																	 where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Claim'
																	 GROUP by emp_id 
																	 ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Claim'))
                                            
                                Begin
                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                    ,@Is_RMToRm = Is_RMToRM
                                    From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id in (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Claim'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID 
															AND Tbl1.effective_date = QES.Effective_Date And Type = 'Claim')
                                            
                                          
									print @App_Emp_ID
									print @is_Rm
									--print @is_Bm
									--print @Is_RMToRm
									--print @RPT_LEVEL
                                    If @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        Begin        
											
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID
                                            --SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL where Emp_ID = @Emp_ID                                       
											
                                        End
                                    Else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                                
                                End
                                                            
                        End
                    
                    If @Is_Manager_CC = 1
                        Begin
						
                            If @Module_Name = 'Travel Application' And @Final_Approval = 0 or @Module_Name = 'Claim Application' And @Final_Approval = 0 or @Module_Name = 'Claim Approval' or @Module_Name = 'Vehicle Application' And @Final_Approval = 0 or @Module_Name = 'Travel Settlement Application' And @Final_Approval = 0
                                Begin
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                        End 
                    else if @To_Manager=1 
                        begin       
                           
                            If @Module_Name = 'Travel Application' And @Final_Approval = 0 or @Module_Name = 'Claim Application' And @Final_Approval = 0 or @Module_Name = 'Claim Approval' or @Module_Name = 'Vehicle Application' And @Final_Approval = 0 or @Module_Name = 'Travel Settlement Application' And @Final_Approval = 0
                                Begin
									--TEST
									
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                    
                                End
                        end -- Added by sumit 26/09/2014            
                    Else
                        Begin
                            If @Module_Name = 'Travel Application' And @Final_Approval = 0 or @Module_Name = 'Claim Application' And @Final_Approval = 0 or @Module_Name = 'Claim Approval' And @Final_Approval = 0 or @Module_Name = 'Travel Settlement Application' And @Final_Approval = 0
                                Begin
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                    
                                End
                            End
                    --''End - Travel Module ''--Ankit 24062014
                    
                    --''Start - Change Request Application Module ''--Nilesh 05012015
                               
                    If (@Module_Name = 'Change Request Application' Or @Module_Name = 'Change Request Approval') And @Final_Approval = 0
                        Begin
                          
                            
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
																(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK) inner join T0050_Scheme_Detail sd WITH (NOLOCK) on ies.Scheme_ID=sd.Scheme_Id
																where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Change Request' And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#'))
																GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Change Request' )
															--inner join T0050_Scheme_Detail sd on QES.Scheme_ID=sd.Scheme_Id   --Comment by Jaina 20-11-2020
															--Where  @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                        ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                        From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
																	(select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK) inner join T0050_Scheme_Detail sd WITH (NOLOCK) on ies.Scheme_ID=sd.Scheme_Id
																	where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Change Request' And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#'))
																	GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Change Request'  )
															--inner join T0050_Scheme_Detail sd on QES.Scheme_ID=sd.Scheme_Id   --Comment by Jaina 20-11-2020
															--Where  @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                                    
                                    if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin                                               
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID
                                            --SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL where Emp_ID = @Emp_ID
                                        end
                                    else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS  WITH (NOLOCK) 
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end     
                                    
                                    
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                            
                                End
                                                            
                        End
                        
                        If @Is_Manager_CC = 1
                            Begin
                                If (@Module_Name = 'Change Request Application' Or @Module_Name = 'Change Request Approval') And @Final_Approval = 0
                                    Begin
                                        insert into #Temp_CC
                                            Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                    End
                            End             
                        Else
                            Begin
                                If (@Module_Name = 'Change Request Application' Or @Module_Name = 'Change Request Approval') And @Final_Approval = 0
                                    Begin                                   
                                        insert into #Temp_To
                                            Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                    End

                            End
                            
                    --''End - Change Request Application Module ''--Nilesh 05012015
                    
                    --''Start - Reimbursement\Claim ''--Ankit 19052014
            
                    If (@Module_Name = 'Reimbursement\Claim Application' Or @Module_Name = 'Reimbursement\Claim Approval') And @Final_Approval = 0
                        Begin
                        
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Reimbursement'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Reimbursement')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                        ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                        From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Reimbursement'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Reimbursement')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                
                                                                    
                                    If @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        Begin   
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID
                                            --SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL where Emp_ID = @Emp_ID
                                        End
                                    Else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                End
                                                            
                        End
                        
                    If @Is_Manager_CC = 1
                        Begin
                            If (@Module_Name = 'Reimbursement\Claim Application' Or @Module_Name = 'Reimbursement\Claim Approval') And @Final_Approval = 0
                                Begin
                                
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                        End             
                    Else
                        Begin
                            If (@Module_Name = 'Reimbursement\Claim Application' Or @Module_Name = 'Reimbursement\Claim Approval') And @Final_Approval = 0
                                Begin
                                
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                            End
                    --''End - Reimbursement\Claim ''--Ankit 26062014
                    --''Start - KPI Manager Approved objective Module ''--sneha 30032015
                                
                    If (@Module_Name = 'KPI Manager Approved' Or @Module_Name = 'KPI Manager Approved') And @Final_Approval = 0
                        Begin
                            
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'KPI Manager Approved'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'KPI Manager Approved')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                    ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                            From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'KPI Manager Approved'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'KPI Manager Approved')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                                            
                                    if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin                                               
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID
                                        end
                                    else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                        ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                         BEGIN                                                  
                                                SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                where ERD.Emp_ID = @Emp_ID
                                                
                                                If @R_Emp_Id1 <> 0
                                                    BEGIN
                                                            INSERT INTO #Rpt_branch_manager
                                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                            where ERD.Emp_ID = @R_Emp_Id1
                                                    END
                                         END
                                                
                                End
                                                            
                        End
                        
                    If @Is_Manager_CC = 1
                        Begin
                            If (@Module_Name = 'KPI Manager Approved' Or @Module_Name = 'KPI Manager Approved') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                        End             
                    Else
                        Begin
                            If (@Module_Name = 'KPI Manager Approved' Or @Module_Name = 'KPI Manager Approved') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End

                        End
                    --''End -  KPI Manager Approved objective Module ''--sneha 30032015
                    
                    
                    --''Start - KPIRating Manager Approved objective Module ''--sneha 30032015
                                
                    If (@Module_Name = 'KPIRating Manager Approved' Or @Module_Name = 'KPIRating Manager Approved') And @Final_Approval = 0
                        Begin
                            
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'KPIRating Manager Approved'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'KPIRating Manager Approved')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                            ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                        From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'KPIRating Manager Approved'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'KPIRating Manager Approved')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                                            
                                    if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin                                               
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID
                                        end
                                    else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                End
                                                            
                        End
                        
                    If @Is_Manager_CC = 1
                        Begin
                            If (@Module_Name = 'KPIRating Manager Approved' Or @Module_Name = 'KPIRating Manager Approved') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                        End             
                    Else
                        Begin
                            If (@Module_Name = 'KPIRating Manager Approved' Or @Module_Name = 'KPIRating Manager Approved') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End

                        End
                    --''End -  KPIRating Manager Approved objective Module ''--sneha 30032015
                    
                    --''Start - recruitment Request Application Module ''--sneha 30032015
                   
                    If (@Module_Name = 'Recruitment Request' Or @Module_Name = 'Recruitment Request') And @Final_Approval = 0
                        Begin
                            print 1
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Recruitment Request'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Recruitment Request')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    
                                    --Select  App_Emp_ID , Is_RM , Is_BM , Is_HOD,Is_HR , Is_RMToRM
                                    --From T0050_Scheme_Detail Where Rpt_Level = (@Rpt_Level + 1)
                                    --        AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES INNER join 
                                    --                        (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES
                                    --                        where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Recruitment Request'
                                    --                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Recruitment Request')
                                                            
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM ,@Is_HOD = Is_HOD,@Is_Hr=Is_HR 
                                        ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                    From T0050_Scheme_Detail WITH (NOLOCK)  Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Recruitment Request'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Recruitment Request')
                                            --And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                      
                                    if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin                                               
                                            --insert into #Rpt_branch_manager
                                            --SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL where Emp_ID = @Emp_ID

											 insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                            where ERD.Emp_ID = @Emp_ID
                                        end
                                    else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                    Else if @App_Emp_ID = 0  and @Is_HOD =1 --added by sneha 3 feb 2016
                                        Begin 
                                        insert into #Rpt_branch_manager                                                                             
                                            SELECT Emp_id FROM T0095_Department_Manager  WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_Department_Manager WITH (NOLOCK)WHERE Dept_ID = @Emp_Dept AND Effective_Date <= GETDATE()) AND dbo.T0095_Department_Manager.Dept_Id = @Emp_Dept                                        
                                        End 
                                    Else if @App_Emp_ID = 0  and @Is_HR =1  --added by sneha 3 feb 2016
                                        Begin 
											  IF EXISTS(SELECT Emp_id FROM T0011_LOGIN WITH (NOLOCK) WHERE  Is_Active =1 and Is_HR=1 and cast(@emp_branch as varchar(18))  in (case Branch_id_multi when '0' then Branch_id_multi else (select data from dbo.Split(Branch_id_multi,'#')) end))                                     
													BEGIN
														INSERT INTO #Rpt_branch_manager
														SELECT Emp_id FROM T0011_LOGIN WITH (NOLOCK)
														WHERE  Is_Active =1 and Is_HR=1 and cast(@emp_branch as varchar(18))  in (case Branch_id_multi when '0' then Branch_id_multi
														ELSE (SELECT data from dbo.Split(Branch_id_multi,'#')) end) 	
													END
											  ELSE
													BEGIN
														INSERT INTO #Rpt_branch_manager
														SELECT Emp_id FROM T0011_LOGIN WITH (NOLOCK)
														WHERE  Is_Active =1 and Is_HR=1 and Cmp_ID=@cmp_id	
													END
											
                                            set @hremail = 1                                            
                                        End             
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                End             
                                                            
                        End
                        
                    If @Is_Manager_CC = 1
                        Begin 
                            
                            if @hremail = 1 --added on 2 Feb 2016 sneha
                                BEGIN                               
                                If (@Module_Name = 'Recruitment Request' Or @Module_Name = 'Recruitment Request') And @Final_Approval = 0
                                    Begin
                                        insert into #Temp_CC
                                            Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                            
                                        insert into #Temp_CC
                                            Select distinct(Email_ID) From T0011_LOGIN WITH (NOLOCK) where  Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                    End
                                END
                            ELSE                                
                                BEGIN                               
                                    If (@Module_Name = 'Recruitment Request' Or @Module_Name = 'Recruitment Request') And @Final_Approval = 0
                                        Begin
                                            insert into #Temp_CC
                                                Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                            
                                        End
                                END
                        End             
                    Else
                        Begin 
                            if @hremail = 1
                                begin
                                    If (@Module_Name = 'Recruitment Request' Or @Module_Name = 'Recruitment Request') And @Final_Approval = 0
                                        Begin
                                            
                                            insert into #Temp_To
                                                Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                            insert into #Temp_CC
                                            Select distinct(Email_ID) From T0011_LOGIN WITH (NOLOCK) where  Emp_ID in (SELECT emp_id from #Rpt_branch_manager) 
                                            

                                            
                                        End
                                END
                            else
                                begin
                                If (@Module_Name = 'Recruitment Request' Or @Module_Name = 'Recruitment Request') And @Final_Approval = 0
                                    Begin
                                        insert into #Temp_To
                                            Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                        
                                        
                                    End
                                END

                        End
                        
                        
                    --''End - recruitment Request Application Module ''--sneha 30032015
                    
                    --''Start - candidate Application Module ''--sneha 30032015
                                
                    If (@Module_Name = 'Candidate Approval Level' Or @Module_Name = 'Candidate Approval Level') And @Final_Approval = 0
                        Begin
                            
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Candidate Approval'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Candidate Approval')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    print @Emp_Dept
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM,@is_hod= Is_HOD,@is_hr=Is_HR 
                                            ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                    From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Candidate Approval'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Candidate Approval')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                                            
                                    if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin                                               
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID
                                        end
                                    else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                    Else if @App_Emp_ID = 0  and @Is_HOD =1 --added by sneha 3 FEB 2016
                                        Begin 
                                        insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_Department_Manager WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_Department_Manager WITH (NOLOCK) WHERE Dept_ID = @Emp_Dept AND Effective_Date <= GETDATE()) AND dbo.T0095_Department_Manager.Dept_Id = @Emp_Dept                                        
                                            --SELECT DM.Emp_id FROM T0095_Department_Manager  DM
                                            --  inner join  
                                            --  (select max(effective_date) as max_date,Dept_Id  from T0095_Department_Manager where Effective_Date <= GETDATE() and T0095_Department_Manager.Dept_Id =@Emp_Dept  group by dept_id)MDM
                                            --  on MDM.max_date = DM.Effective_Date and DM.Dept_Id=MDM.Dept_Id
                                            
                                        End 
                                    Else if @App_Emp_ID = 0  and @Is_HR =1  --added by sneha 3 FEB 2016
                                        Begin
                                        insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0011_LOGIN WITH (NOLOCK)
                                            WHERE Is_Active =1 and cast(@emp_branch as varchar(18))  in (case Branch_id_multi when '0' then Branch_id_multi
                                                        else (select data from dbo.Split(Branch_id_multi,'#')) end)     
                                            set @hremail =1
                                        End         
                                        ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                End
                                                            
                        End
                        
                    If @Is_Manager_CC = 1
                        Begin
                            if @hremail = 1
                                BEGIN
                                    If (@Module_Name = 'Candidate Approval Level' Or @Module_Name = 'Candidate Approval Level') And @Final_Approval = 0
                                        Begin
                                            insert into #Temp_CC
                                                Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                            insert into #Temp_CC
                                            Select distinct(Email_ID) From T0011_LOGIN WITH (NOLOCK) where  Emp_ID in (SELECT emp_id from #Rpt_branch_manager) 
                                        End
                                END 
                            else
                                BEGIN
                                    If (@Module_Name = 'Candidate Approval Level' Or @Module_Name = 'Candidate Approval Level') And @Final_Approval = 0
                                        Begin
                                            insert into #Temp_CC
                                                Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                        End
                                End
                        End                 
                    Else
                        Begin
                            if @hremail = 1
                                BEGIN
                                    If (@Module_Name = 'Candidate Approval Level' Or @Module_Name = 'Candidate Approval Level') And @Final_Approval = 0
                                    Begin
                                        insert into #Temp_To
                                            Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                        insert into #Temp_CC
                                            Select distinct(Email_ID) From T0011_LOGIN WITH (NOLOCK) where  Emp_ID in (SELECT emp_id from #Rpt_branch_manager) 
                                    End
                                END
                            Else
                                BEGIN
                                    If (@Module_Name = 'Candidate Approval Level' Or @Module_Name = 'Candidate Approval Level') And @Final_Approval = 0
                                    Begin
                                        insert into #Temp_To
                                            Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                    End
                                END                 

                        End
                    --''End - candidate Application Module ''--sneha 30032015
                End
            
            -- =====================================================================
              -- Added by Gadriwala Muslim 15062015 - Start
                If (@Module_Name = 'Pre-CompOff Application' Or @Module_Name = 'Pre-CompOff Approval') And @Final_Approval = 0
                        Begin
                
                    
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Pre-CompOff'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Pre-CompOff')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                        ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                    From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Pre-CompOff'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Pre-CompOff')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                    
                                            
                                    if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin                                               
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                            where ERD.Emp_ID = @Emp_ID
                                            --
                                        end
                                    else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                   
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                                                            
                                End
                                                            
                        End
                        
                    If @Is_Manager_CC = 1
                        Begin
                            If (@Module_Name = 'Pre-CompOff Application' Or @Module_Name = 'Pre-CompOff Approval') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                        End             
                    Else
                        Begin
                            If (@Module_Name = 'Pre-CompOff Application' Or @Module_Name = 'Pre-CompOff Approval') And @Final_Approval = 0
                                Begin
                                        
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                        
                                
                                End

                        End
            
            -- Added by Gadriwala Muslim 15062015 - End
            
            
                --Added By Jaina 06-06-2016 Start
                    
                    If (@Module_Name = 'Exit Application' or @Module_Name = 'Exit Approval') And @Final_Approval = 0
                        Begin
                
                            
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Exit'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Exit'))
                                            
                                Begin
                                        
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                        From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                                (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK) 
                                                                where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Exit'
                                                                GROUP by emp_id 
                                                            ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Exit')
                                            
                                                    
                                        
                                    if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin                                               
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                            where ERD.Emp_ID = @Emp_ID
                                            --
                                        end
                                    else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                   
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                    
                                        
                                End
                                                            
                        End
                        
                        If @Is_Manager_CC = 1
                        Begin
                            If (@Module_Name = 'Exit Application' or @Module_Name = 'Exit Approval') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                        End             
                    Else
                        Begin
                            If ( @Module_Name = 'Exit Application' or @Module_Name = 'Exit Approval') And @Final_Approval = 0
                                Begin
                                        
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                
                                End

                        End
                        

            --Added By Jaina 06-06-2016 End 
                    
            --''Start - Employee Probation ''--Ankit 06042016
                        
                    IF (@Module_Name = 'Employee Probation' OR @Module_Name = 'Employee Training') AND @Final_Approval = 0
                        BEGIN
                            DECLARE @Probation_Type VARCHAR(50)
                            SET @Probation_Type = ''
                            
                            IF @Module_Name = 'Employee Probation' 
                                SET @Probation_Type  = 'Probation'
                            ELSE
                                SET @Probation_Type  = 'Trainee'
                            
                            IF EXISTS ( SELECT App_Emp_ID FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = ( SELECT QES.Scheme_ID FROM T0095_EMP_SCHEME QES WITH (NOLOCK) INNER JOIN 
                                                                ( SELECT MAX(effective_date) AS effective_date,emp_id FROM T0095_EMP_SCHEME IES  WITH (NOLOCK)
                                                                    WHERE IES.effective_date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = @Probation_Type GROUP BY emp_id 
                                                                ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND TYPE = @Probation_Type) )
                                BEGIN
                                    
                                    SELECT @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM,@IS_PRM=IS_PRM 
                                        ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                        FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = ( SELECT QES.Scheme_ID FROM T0095_EMP_SCHEME QES WITH (NOLOCK) INNER JOIN 
                                                                ( SELECT MAX(effective_date) AS effective_date,emp_id FROM T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                                    WHERE IES.effective_date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = @Probation_Type GROUP BY emp_id 
                                                                ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND TYPE = @Probation_Type)
                                    
                                    IF @App_Emp_ID = 0  AND @is_Rm =1 AND @Rpt_Level = 0
                                        BEGIN                                               
                                            INSERT INTO #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (SELECT MAX(Effect_Date) AS Effect_Date,emp_id FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
                                                GROUP BY emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID
                                            
                                        END
                                    ELSE IF @App_Emp_ID = 0  AND @is_Bm =1 
                                        BEGIN                           
                                            INSERT INTO #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        END 
                                    ELSE IF @App_Emp_ID = 0  AND @IS_PRM = 1 
                                        BEGIN                           
                                            INSERT INTO #Rpt_branch_manager
                                            SELECT manager_probation FROM t0080_emp_master WITH (NOLOCK)
                                            WHERE emp_id =@Emp_ID
                                        END     
                                        ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                                
                                END
                                
                                IF @Is_Manager_CC = 1
                                    BEGIN
                                        INSERT INTO #Temp_CC
                                        SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @App_Emp_ID OR Emp_ID IN (SELECT emp_id FROM #Rpt_branch_manager)                          
                                    END             
                                ELSE
                                    BEGIN
                                        INSERT INTO #Temp_To
                                            SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @App_Emp_ID OR Emp_ID IN (SELECT emp_id FROM #Rpt_branch_manager)
                                    END                         
                        END
                        
                
                    --''End - Employee Probation ''--Ankit 06042016
                     If (@Module_Name = 'Vehicle Application') And @Final_Approval = 0
                        Begin
                        
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Own Vehicle'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Own Vehicle'))
                                           -- And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                        ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                        From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Own Vehicle'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Own Vehicle')
                                           -- And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                
                                                                    
                                    If @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        Begin   
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID
                                            --SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL where Emp_ID = @Emp_ID
                                        End
                                    Else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                End
                                                            
                        End
                        
                    If @Is_Manager_CC = 1
                        Begin
                            If (@Module_Name = 'Vehicle Application') And @Final_Approval = 0
                                Begin
                                
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                        End             
                    Else
                        Begin
                            If (@Module_Name = 'Vehicle Application') And @Final_Approval = 0
                                Begin
                                
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                            End

                    IF (@Module_Name = 'GatePass') AND @Final_Approval = 0
                        BEGIN
                            IF EXISTS ( SELECT 1 FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = ( SELECT QES.Scheme_ID FROM T0095_EMP_SCHEME QES INNER JOIN 
                                                                ( SELECT MAX(effective_date) AS effective_date,emp_id FROM T0095_EMP_SCHEME IES WITH (NOLOCK) WHERE IES.effective_date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = 'GatePass'
                                                                    GROUP BY emp_id 
                                                                ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND TYPE = 'GatePass')
                                       )
                                BEGIN
                                
                                
                                    SELECT @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                        ,@Scheme_Id = scheme_id
                                            ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                        FROM T0050_Scheme_Detail WITH (NOLOCK)
                                    WHERE Rpt_Level = (@Rpt_Level + 1) AND 
                                        Scheme_Id = (SELECT QES.Scheme_ID FROM T0095_EMP_SCHEME QES WITH (NOLOCK) INNER JOIN 
                                                        ( SELECT MAX(effective_date) AS effective_date,emp_id FROM T0095_EMP_SCHEME IES WITH (NOLOCK) WHERE IES.effective_date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = 'GatePass'
                                                          GROUP BY emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND TYPE = 'GatePass' )
                                                            
                                    IF @App_Emp_ID = 0  AND @is_Rm =1 AND @Rpt_Level = 0
                                        BEGIN                                               
                                            INSERT INTO #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (SELECT MAX(Effect_Date) AS Effect_Date,emp_id FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
                                                GROUP BY emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                            WHERE ERD.Emp_ID = @Emp_ID
                                        
                                        END
                                    ELSE IF @App_Emp_ID = 0  AND @is_Bm =1 
                                        BEGIN                   
                                            INSERT INTO #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        END 
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1                               
                                                                
                                                                
                                                        END
                                             END
                                    END
                            
                            
                            IF @Is_Manager_CC = 1
                                BEGIN
                                    INSERT INTO #Temp_CC
                                    SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @App_Emp_ID OR Emp_ID IN (SELECT emp_id FROM #Rpt_branch_manager)
                                END             
                            ELSE
                                BEGIN
                                    INSERT INTO #Temp_To
                                    SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @App_Emp_ID OR Emp_ID IN (SELECT emp_id FROM #Rpt_branch_manager)
                                    
                                END
                                
                                                                            
                        END
                        
                    
                    --''End - Gate Pass ''--Ankit 06042016
                    --Added by Sumit on 05122016 for Optional Holiday----
                    If (@Module_Name = 'Optional Holiday Application' or @Module_Name = 'Optional Holiday Approval') And @Final_Approval = 0
                        Begin                            
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                            where ERD.Emp_ID = @Emp_ID
                        End                     
                        If (@Is_Manager_CC = 1 or  @To_Manager=1)
                        Begin
                            If (@Module_Name = 'Optional Holiday Application' or @Module_Name = 'Optional Holiday Approval') And @Final_Approval = 0
                                Begin                               
                                    insert into #Temp_CC
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
                        End             
                    --Else if @To_Manager=1
                    --  Begin
                    --      If (@Module_Name = 'Optional Holiday Application' or @Module_Name = 'Optional Holiday Approval') And @Final_Approval = 0
                    --          Begin
                                    
                    --              insert into #Temp_To
                    --                  Select distinct(Work_Email) From T0080_EMP_MASTER where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                    --          End
                    --  End -- Added by Sumit on 0512016

                    ---added by jimit 14112016
					
					   --If (@Module_Name = 'Claim Approval') And @Final_Approval = 0
        --                Begin
        --                    IF EXISTS ( SELECT 1 FROM T0050_Scheme_Detail WHERE Rpt_Level = (@Rpt_Level + 1)
        --                                    AND Scheme_Id = ( SELECT QES.Scheme_ID FROM T0095_EMP_SCHEME QES INNER JOIN 
        --                                                        ( SELECT MAX(effective_date) AS effective_date,emp_id FROM T0095_EMP_SCHEME IES 
								--								WHERE IES.effective_date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = 'Claim'
        --                                                            GROUP BY emp_id 
        --                                                        ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND TYPE = 'Claim')
        --                               )
        --                        BEGIN
                                
									
        --                            SELECT @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
        --                            ,@Is_RMToRm = Is_RMToRM ,@Rpt_Level = Rpt_Level
        --                            FROM T0050_Scheme_Detail 
        --                            WHERE Rpt_Level = (@Rpt_Level + 1) AND 
								--	--WHERE Rpt_Level = @Rpt_Level AND 
        --                                Scheme_Id = (SELECT QES.Scheme_ID FROM T0095_EMP_SCHEME QES INNER JOIN 
        --                                                ( SELECT MAX(effective_date) AS effective_date,emp_id FROM T0095_EMP_SCHEME IES WHERE IES.effective_date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = 'Claim'
        --                                                  GROUP BY emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND TYPE = 'Claim' )
									
        --                            IF @App_Emp_ID = 0  AND @is_Rm = 1 AND @Rpt_Level = 0
        --                                BEGIN      
								--			print 1
        --                                    INSERT INTO #Rpt_branch_manager
        --                                    SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD INNER JOIN 
        --                                        (SELECT MAX(Effect_Date) AS Effect_Date,emp_id FROM T0090_EMP_REPORTING_DETAIL ERD1
        --                                            WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
        --                                        GROUP BY emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
        --                                    WHERE ERD.Emp_ID = @Emp_ID
                                        
        --                                END
        --                            ELSE IF @App_Emp_ID = 0  AND @is_Bm =1 
        --                                BEGIN      
								--			print 2
        --                                    INSERT INTO #Rpt_branch_manager
        --                                    SELECT Emp_id FROM T0095_MANAGERS 
        --                                    WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
        --                                END 
        --                            ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
        --                                     BEGIN                                                  
        --                                            SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD INNER JOIN 
        --                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1
        --                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
        --                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
        --                                            where ERD.Emp_ID = @Emp_ID
                                                    
        --                                            If @R_Emp_Id1 <> 0
        --                                                BEGIN
								--						print 3
        --                                                        INSERT INTO #Rpt_branch_manager
        --                                                        SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD INNER JOIN 
        --                                                            (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1
        --                                                                where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
        --                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
        --                                                        where ERD.Emp_ID = @R_Emp_Id1
        --                                                END
        --                                     END
        --                            END
									
        --                    IF @Is_Manager_CC = 1
        --                        BEGIN
                                
        --                            INSERT INTO #Temp_CC
        --                            SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WHERE Emp_ID = @App_Emp_ID OR Emp_ID IN (SELECT emp_id FROM #Rpt_branch_manager)
        --                        END             
        --                    ELSE
        --                        BEGIN
                                
        --                            INSERT INTO #Temp_To
        --                            SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WHERE Emp_ID = @App_Emp_ID OR Emp_ID IN (SELECT emp_id FROM #Rpt_branch_manager)
                                    
        --                        END
                                
                                                                            
        --                END   
            If (@Module_Name = 'Employee Increment Application' or @Module_Name = 'Employee Increment Approval') And @Final_Approval = 0
                        Begin
                            
                            
                            IF EXISTS ( SELECT 1 FROM T0050_Scheme_Detail WITH (NOLOCK) WHERE Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = ( SELECT QES.Scheme_ID FROM T0095_EMP_SCHEME QES WITH (NOLOCK) INNER JOIN 
                                                                ( SELECT MAX(effective_date) AS effective_date,emp_id FROM T0095_EMP_SCHEME IES WITH (NOLOCK) WHERE IES.effective_date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = 'Increment'
                                                                    GROUP BY emp_id 
                                                                ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND TYPE = 'Increment')
                                       )
                                BEGIN
                                
                                
                                    SELECT @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                    ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                    FROM T0050_Scheme_Detail WITH (NOLOCK)
                                    WHERE Rpt_Level = (@Rpt_Level + 1) AND 
                                        Scheme_Id = (SELECT QES.Scheme_ID FROM T0095_EMP_SCHEME QES WITH (NOLOCK) INNER JOIN 
                                                        ( SELECT MAX(effective_date) AS effective_date,emp_id FROM T0095_EMP_SCHEME IES WITH (NOLOCK) WHERE IES.effective_date <= GETDATE() AND Emp_ID = @Emp_ID AND TYPE = 'Increment'
                                                          GROUP BY emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date AND TYPE = 'Increment' )
                                                            
                                    IF @App_Emp_ID = 0  AND @is_Rm =1 AND @Rpt_Level = 0
                                        BEGIN                                               
                                            INSERT INTO #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (SELECT MAX(Effect_Date) AS Effect_Date,emp_id FROM T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    WHERE ERD1.Effect_Date <= GETDATE() AND Emp_ID = @Emp_ID
                                                GROUP BY emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                            WHERE ERD.Emp_ID = @Emp_ID
                                        
                                        END
                                    ELSE IF @App_Emp_ID = 0  AND @is_Bm =1 
                                        BEGIN                   
                                            INSERT INTO #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        END 
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
                                    END
                            IF @Is_Manager_CC = 1
                                BEGIN
                                
                                    INSERT INTO #Temp_CC
                                    SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @App_Emp_ID OR Emp_ID IN (SELECT emp_id FROM #Rpt_branch_manager)
                                END             
                            ELSE
                                BEGIN
                                
                                    INSERT INTO #Temp_To
                                    SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @App_Emp_ID OR Emp_ID IN (SELECT emp_id FROM #Rpt_branch_manager)
                                    
                                END
                                
                                                                            
                        END
            
            
            -------ended------
                                 --added by mansi for file app start
					If (@Module_Name = 'File Application' ) And @Final_Approval = 0
                        Begin
						--print 11--27-06-22
						
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT DISTINCT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id INNER join -- Added by nilesh on 09102015 for multiple Scheme Provision
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'File Management'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'File Management'
                                                            where @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(T1.Leave, '#')))
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
								--print 22--27-06-22
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                            ,@Is_RMToRm = Is_RMToRM  --Added By Jimit 21122017
                                        From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT DISTINCT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id INNER join  -- Added by nilesh on 09102015 for multiple Scheme Provision
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'File Management'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'File Management'
                                                            where @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(T1.Leave, '#')))
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                                            
                                        if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin 
										--print 33--27-06-22
                                            insert into #Temp_To
											Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=
                                            (SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID)
                                            --SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL where Emp_ID = @Emp_ID
                                        end
										else if @App_Emp_ID<>0
										begin
										    insert into #Temp_To
                                           Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID 
										end                               
                                End                     
                        End
					 
                       If @Is_Manager_CC = 1
                        Begin
                           If (@Module_Name = 'File Application') And @Final_Approval = 0--Or @Module_Name = 'Loan Approval') And @Final_Approval = 0
                                Begin
								print @App_Emp_ID
								
                                    insert into #Temp_CC
									 Select distinct(Work_Email)From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID IN (
                                                --Select R_Emp_ID from T0090_EMP_REPORTING_DETAIL Where Emp_ID = @Emp_ID 
                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                WHERE ERD.Emp_ID = @Emp_ID)
                                                 and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()
										 
												
                                        --Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
								
                        End             
                    Else
                        Begin
                            If (@Module_Name = 'File Application') And @Final_Approval = 0-- Or @Module_Name = 'Loan Approval') And @Final_Approval = 0
                                Begin
                                    insert into #Temp_To
                                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                                End
								
                        End
					--added by mansi for file app end 

					--added by mansi file_approve start
					If (@Module_Name = 'File Approval' ) And @Final_Approval = 0
                        Begin
                            
                            If Exists (Select App_Emp_ID From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'File Management'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'File Management')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')))
                                Begin
                                    
                                    Select @App_Emp_ID = App_Emp_ID , @is_Rm = Is_RM ,@is_Bm = Is_BM 
                                            ,@Is_RMToRm = Is_RMToRM --Added By Jimit 2112017
                                        From T0050_Scheme_Detail WITH (NOLOCK) Where Rpt_Level = (@Rpt_Level + 1)
                                            AND Scheme_Id = (SELECT QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                                                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                                                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'File Management'
                                                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'File Management')
                                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#')) 
                                                                            
                                    if @App_Emp_ID = 0  and @is_Rm =1 and @Rpt_Level = 0
                                        begin                                               
                                            insert into #Rpt_branch_manager
                                            SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID
                                        end
                                    else IF @App_Emp_ID = 0  and @is_Bm =1 
                                        BEGIN                           
                                            insert into #Rpt_branch_manager
                                            SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
                                            WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) AND dbo.T0095_MANAGERS.branch_id = @emp_branch
                                        end 
                                    ELSE IF @APP_EMP_ID = 0  AND @IS_RMTORM = 1 AND @RPT_LEVEL = 1 --Added By Jimit 21122017
                                             BEGIN                                                  
                                                    SELECT @R_Emp_Id1 = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                        GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                    where ERD.Emp_ID = @Emp_ID
                                                    
                                                    If @R_Emp_Id1 <> 0
                                                        BEGIN
                                                                INSERT INTO #Rpt_branch_manager
                                                                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                    (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                        where ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                    GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where ERD.Emp_ID = @R_Emp_Id1
                                                        END
                                             END
								   else if @App_Emp_ID<>0 
								   begin
								     if(@File_status_ID=4)
									 begin
										 INSERT INTO #Temp_To
										SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @App_Emp_ID 
								     end
 								   end
                                End
								
								if(@File_status_ID=3)
                                 begin 
								   INSERT INTO #Temp_To
                                    SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Forward_Emp_Id 
                                    
									if(@Submit_Emp_Id<>0)
									begin
								      INSERT INTO #Temp_To
                                    SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Submit_Emp_Id 
								  end 
								  --  if(@log_Emp_Id=0)
								  --begin
								  --   INSERT INTO #Temp_To
										--SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @log_Emp_Id 
								  --end
							  end
							    else if(@File_status_ID=5)
                                 begin 
								   INSERT INTO #Temp_To
                                    SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Review_Emp_Id 
                                    
									if(@Review_by_Emp_Id<>0)
									begin
								      INSERT INTO #Temp_To
                                    SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Review_by_Emp_Id 
								  end 
								  --if(@log_Emp_Id=0)
								  --begin
								  --   INSERT INTO #Temp_To
										--SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @log_Emp_Id 
								  --end
							  end
							   else if(@File_status_ID=2)
							    begin
										 INSERT INTO #Temp_To
										SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @log_Emp_Id 
							    end

                        End
                      --added by mansi file_approve end 
                    --Added By Jaina 21-09-2016 Start
                    IF (@Module_Name = 'Weekoff Request Application') 
                    Begin 
                            IF @Is_Manager_CC = 1
                                BEGIN
                                    INSERT INTO #Temp_CC
                                    SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @App_Emp_ID 
                                END             
                            ELSE
                                BEGIN
                                    INSERT INTO #Temp_To
                                    SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @App_Emp_ID 
                                END
                    End
                    --Added By Jaina 21-09-2016 End
            
                CREATE TABLE #Email_Branch
                (
                    Login_ID numeric(18,0),
                    Branch_Id numeric(18,0)
                 )
                Declare @Branch_ID_Multi nvarchar(max)
                set @Branch_ID_Multi = ''
                Declare @Login_Id numeric(18,0)
                set @Login_Id = 0
            If @Rpt_Level = 0 OR @Final_Approval = 1
                Begin   
                
                
                    If @To_Hr = 1
                        Begin
                            Declare CurEmailHr cursor for 
                                Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN  WITH (NOLOCK)
                                Where Cmp_ID = @Cmp_ID And Is_HR = 1 and Is_Active =1
                                
                            Open CurEmailHr
                                fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
                             while @@fetch_status = 0
                                begin   
                                        Insert into #Email_Branch
                                         select @Login_ID,data
                                         from dbo.Split(@Branch_ID_Multi,',')
                                         where (data = @emp_branch or data = 0) 
                                           
                                    fetch next from CurEmailHr into @Branch_ID_Multi,@Login_Id
                                end
                            close CurEmailHr
                            deallocate CurEmailHr
                        
                            If @Is_HR_CC = 1
                                Insert into #Temp_CC
                                    Select (ISNULL(Email_ID,'')) From  T0011_LOGIN L WITH (NOLOCK) inner join
                                    #Email_Branch EB on EB.Login_ID = L.Login_ID 
                                     Where Cmp_ID = @Cmp_ID And Is_HR = 1 and Is_Active =1 
                                     and (EB.Branch_ID = @emp_branch or EB.Branch_ID = 0) 
                            Else                            
                                Insert into #Temp_To
                                    Select (ISNULL(Email_ID,'')) From  T0011_LOGIN L WITH (NOLOCK) inner join
                                    #Email_Branch EB on EB.Login_ID = L.Login_ID 
                                    Where Cmp_ID = @Cmp_ID And Is_HR = 1 and Is_Active =1
                                    and (EB.Branch_ID = @emp_branch or EB.Branch_ID = 0) 
                                    
                        End
                    set @Branch_ID_Multi = ''
                    delete from #Email_Branch

                    If @To_Account = 1  
                        Begin
                                
                            Declare CurEmailAcc cursor for 
                                Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN WITH (NOLOCK)
                                Where Cmp_ID = @Cmp_ID And Is_Accou = 1 and Is_Active =1
                                
                            Open CurEmailAcc
                                fetch next from CurEmailAcc into @Branch_ID_Multi,@Login_Id
                             while @@fetch_status = 0
                                begin   
                                        
                                        Insert into #Email_Branch
                                         select @Login_ID,data
                                         from dbo.Split(@Branch_ID_Multi,',')
                                         where (data = @emp_branch or data = 0) 
                                           
                                    fetch next from CurEmailAcc into @Branch_ID_Multi,@Login_Id
                                end
                            close CurEmailAcc
                            deallocate CurEmailAcc
                            
                            If @Is_Account_CC = 1
                                Insert into #Temp_CC
                                    Select Distinct(ISNULL(Email_ID_accou,'')) From T0011_LOGIN L WITH (NOLOCK)
                                    inner join
                                    #Email_Branch EB on EB.Login_ID = L.Login_ID 
                                    Where Cmp_ID = @Cmp_ID And Is_Accou = 1 and Is_Active=1
                                    and (EB.Branch_ID = @emp_branch or EB.Branch_ID = 0) 
                            Else
                                Insert into #Temp_To
                                    Select Distinct(ISNULL(Email_ID_accou,'')) From T0011_LOGIN L WITH (NOLOCK)
                                    inner join
                                    #Email_Branch EB on EB.Login_ID = L.Login_ID 
                                    Where Cmp_ID = @Cmp_ID And Is_Accou = 1 and Is_Active=1
                                    and (EB.Branch_ID = @emp_branch or EB.Branch_ID = 0) 
                        End
                        
                        set @Branch_ID_Multi = ''
                        delete from #Email_Branch
                        
                        Declare CurEmailHelpDesk cursor for 
                                Select isnull(Branch_ID_multi,0) as Branch_ID_multi,Login_Id From T0011_LOGIN WITH (NOLOCK)
                                Where Cmp_ID = @Cmp_ID And Travel_Help_Desk = 1 and Is_Active =1
                                
                        Open CurEmailHelpDesk
                                fetch next from CurEmailHelpDesk into @Branch_ID_Multi,@Login_Id
                             while @@fetch_status = 0
                                begin   
                                        
                                        Insert into #Email_Branch
                                         select @Login_ID,data
                                         from dbo.Split(@Branch_ID_Multi,',')
                                         where (data = @emp_branch or data = 0) 
                                           
                                    fetch next from CurEmailHelpDesk into @Branch_ID_Multi,@Login_Id
                                end
                            close CurEmailHelpDesk
                            deallocate CurEmailHelpDesk
                            
                        Insert into #Temp_CC
                                    Select Distinct(ISNULL(Email_ID,'')) From T0011_LOGIN L WITH (NOLOCK)
                                    inner join
                                    #Email_Branch EB on EB.Login_ID = L.Login_ID 
                                    Where Cmp_ID = @Cmp_ID And Travel_Help_Desk = 1 and Is_Active=1
                                    and (EB.Branch_ID = @emp_branch or EB.Branch_ID = 0) 
                End
                
				

            If @Other_Email <> ''
                Begin
                    -- Added By Nilesh For BMA Send Email Notification in HOD 
                    if CHARINDEX('#HOD#',@Other_Email) > 1 
                        Begin
                            insert into #Rpt_branch_manager
                            SELECT Emp_id FROM T0095_Department_Manager WITH (NOLOCK)
                            WHERE Effective_Date = (
                                                        SELECT MAX(Effective_Date) FROM dbo.T0095_Department_Manager WITH (NOLOCK)
                                                        WHERE Dept_ID = @Emp_Dept AND Effective_Date <= GETDATE() 
                                                    ) AND dbo.T0095_Department_Manager.Dept_Id = @Emp_Dept
                            Set @Other_Email = REPLACE(@Other_Email,'#HOD#','')                     
                            insert into #Temp_CC Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                        END
						
                    -- Added By Nilesh Patel on 21-Jan-2019 -- For Cliantha -- Send Notification Branch Managare
                    if CHARINDEX('#BM#',@Other_Email) > 1
                        Begin
                            insert into #Temp_CC
                                Select distinct(Work_Email) 
                                    From T0080_EMP_MASTER EM WITH (NOLOCK)
                                Inner Join( 
                                                SELECT Emp_id 
                                                    FROM T0095_MANAGERS BM WITH (NOLOCK)
                                                Inner Join
                                                (   SELECT MAX(Effective_Date) as Effe_Date,branch_id
                                                        FROM dbo.T0095_MANAGERS WITH (NOLOCK)
                                                    WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
                                                    GRoup by branch_id
                                                ) as Qry ON BM.Effective_Date = Qry.Effe_Date  AND BM.branch_id = Qry.branch_id
                                          ) as Qry_1 ON EM.Emp_ID = Qry_1.Emp_ID
                            Set @Other_Email = REPLACE(@Other_Email,'#BM#','')  
                        End

                    --Added BCC Logic by nilesh for Send mail To Bcc 05012018
                    if CHARINDEX('#BCC#',@Other_Email) > 1  
                        Begin
                            -- For Email To CC
                            INSERT INTO #Temp_CC
                            SELECT REPLACE(Data,'BCC#','') From dbo.Split(@Other_Email,'#BCC#') Where ID = 1
                            
							

                            -- For Email To BCC
                            INSERT INTO #Temp_BCC
                            SELECT REPLACE(Data,'BCC#','') From dbo.Split(@Other_Email,'#BCC#') Where ID = 2
                        End
                    Else
                        Begin
                                Insert into #Temp_CC
                                Select @Other_Email

								
                        End
                End
                    
			 --Added By Jimit 14052019
				 IF @Other_Email_BCC <> ''
				   BEGIN
						INSERT INTO #Temp_BCC
						SELECT @Other_Email_BCC
				   END
				--Ended
                -- Added by rohit for Send intimation to not mendatory employee in scheme on 27052016   
              If (@Module_Name = 'Leave Application' or @Module_Name = 'Leave Approval'  )
                   begin
                    SELECT @scheme_id = QES.Scheme_ID from T0095_EMP_SCHEME QES WITH (NOLOCK) INNER join 
                            T0050_Scheme_Detail T1 WITH (NOLOCK) ON QES.Scheme_ID = T1.Scheme_Id INNER join
                            (select max(effective_date) as effective_date,emp_id from T0095_EMP_SCHEME IES WITH (NOLOCK)
                            where IES.effective_date <= getdate() AND Emp_ID = @Emp_ID And Type = 'Leave'
                            GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = QES.Emp_ID AND Tbl1.effective_date = QES.Effective_Date And Type = 'Leave'
                            And @Leave_ID In (SELECT Cast(data AS Numeric(18, 0)) FROM dbo.Split(Leave, '#'))
                        
						

                    end     
            
			                        
            If @Final_Approval = 1  -- Condition Added By Hiral 07 Aug, 2013 For Five Level Leave Approval 
                BEGIN
                    If @Flag = 1
						begin
                    if @Module_Name='Travel Application' And @Flag=1
                        begin   
                            Insert into #Temp_CC Select (ISNULL(Email_ID,'')) From  T0011_LOGIN WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Travel_Help_Desk = 1 and Is_Active =1 
                        end --Added by sumit 23/09/2014
                    
                    if @Module_Name='Change Request Approval' And @Flag=1 And @Leave_ID = 18 --Added by nilesh for Absconding Email 
                            BEGIN
                                Insert into #Temp_To
                                Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID  
                                union all
                                SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE  Emp_ID IN (select app_emp_id from T0050_Scheme_Detail WITH (NOLOCK) where Scheme_Id= @scheme_id and not_mandatory = 1)
                            End
                        Insert into #Temp_To
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID  and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() --And Cmp_ID = @Cmp_ID
                                union all
                            SELECT DISTINCT(Work_Email) 
                            FROM T0080_EMP_MASTER WITH (NOLOCK)
                            WHERE  Emp_ID IN (select app_emp_id 
                            from T0050_Scheme_Detail  WITH (NOLOCK)  
                            where Scheme_Id=    @scheme_id and not_mandatory = 1)   and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- Change by rohit on 27052016
                    end
                    Else If @Flag = 0      
                            Insert into #Temp_CC
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() --And Cmp_ID = @Cmp_ID 
                    Else If @Flag = 2                   
                        Insert into #Temp_Emp
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
    --------Added By Jimit 12122017---------------
                            --for getting Latest scheme assign to Employee
							
							
							  
                            SELECT  @SCHEME_ID = QES.SCHEME_ID 
                            FROM    T0095_EMP_SCHEME QES WITH (NOLOCK) INNER JOIN 
                                    T0050_SCHEME_DETAIL T1 WITH (NOLOCK) ON QES.SCHEME_ID = T1.SCHEME_ID INNER JOIN
                                    (
                                        SELECT  MAX(EFFECTIVE_DATE) AS EFFECTIVE_DATE,EMP_ID 
                                        FROM    T0095_EMP_SCHEME IES WITH (NOLOCK)
                                        WHERE   IES.EFFECTIVE_DATE <= GETDATE() AND EMP_ID = @EMP_ID AND TYPE = @MODULE_NAME
                                        GROUP BY EMP_ID 
                                     ) TBL1 ON TBL1.EMP_ID = QES.EMP_ID AND TBL1.EFFECTIVE_DATE = QES.EFFECTIVE_DATE AND TYPE = @MODULE_NAME
                                    AND @LEAVE_ID IN 
                                                    (
                                                        SELECT CAST(DATA AS NUMERIC(18, 0)) 
                                                        FROM DBO.SPLIT(LEAVE, '#')
                                                    )
                        
                            
                            
                            DECLARE @QRY AS VARCHAR(MAX)
                            IF EXISTS (SELECT 1 FROM T0050_SCHEME_DETAIL WITH (NOLOCK)
                                       WHERE SCHEME_ID = @SCHEME_ID AND RPT_LEVEL > @RPT_LEVEL  AND NOT_MANDATORY = 1)      
                                            BEGIN
                                                    SELECT  @IS_BM = IS_BM,@IS_RM = IS_RM
                                                            ,@Is_RMToRm = Is_RMToRM                                                         
                                                    FROM    T0050_SCHEME_DETAIL WITH (NOLOCK)
                                                    WHERE   SCHEME_ID = @SCHEME_ID AND RPT_LEVEL = @RPT_LEVEL + 1 AND NOT_MANDATORY = 1         
                                                    
                                                    
                                                    
                                                    --if @Is_BM = 1 
                                                    --  BEGIN
                                                    --      insert into #Rpt_branch_manager
                                                    --      SELECT Emp_id FROM T0095_MANAGERS 
                                                    --      WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS 
                                                    --                              WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()) 
                                                    --            AND dbo.T0095_MANAGERS.branch_id = @emp_branch    
                                                    --  END 
                                                    
                                                    
                                                    IF @IS_BM = 1 
                                                        BEGIN
                                                                SET @QRY = 
                                                                           'INSERT  INTO #TEMP_TO
                                                                            SELECT  DISTINCT(WORK_EMAIL) 
                                                                            FROM    T0080_EMP_MASTER WITH (NOLOCK)
                                                                            WHERE   EMP_ID = ' + CONVERT(VARCHAR(5),@APP_EMP_ID) + ' OR 
                                                                                    EMP_ID IN (
                                                                                                SELECT  COALESCE(CONVERT(VARCHAR(5),EMP_ID),'''') 
                                                                                                FROM    T0095_MANAGERS WITH (NOLOCK)
                                                                                                WHERE   EFFECTIVE_DATE = (
                                                                                                                            SELECT  MAX(EFFECTIVE_DATE) 
                                                                                                                            FROM    DBO.T0095_MANAGERS WITH (NOLOCK)
                                                                                                                            WHERE   BRANCH_ID = ' + CONVERT(VARCHAR(5),@EMP_BRANCH) + '
                                                                                                                                    AND EFFECTIVE_DATE <= GETDATE()) 
                                                                                                        AND DBO.T0095_MANAGERS.BRANCH_ID = '+ CONVERT(VARCHAR(5),@EMP_BRANCH) + ')'
                                                            
                                                                
                                                              EXEC(@QRY)    
                                                                                                  
                                                        END 
                                                    ELSE IF @IS_RMTORM = 1  --Added By Jimit 26122017
                                                         BEGIN                                                  
                                                                SELECT  @R_Emp_Id1 = R_Emp_ID 
                                                                FROM    T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                        (
                                                                            select  max(Effect_Date) as Effect_Date,emp_id 
                                                                            from    T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                            where   ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                                            GROUP by emp_id 
                                                                            
                                                                         ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                where   ERD.Emp_ID = @Emp_ID
                                                                
                                                            If @R_Emp_Id1 <> 0
                                                                BEGIN
                                                                    INSERT INTO #TEMP_TO
                                                                    SELECT WORK_EMAIL FROM T0080_EMP_MASTER WITH (NOLOCK)
                                                                    WHERE   EMP_ID IN (
                                                                                        select  R_Emp_ID 
                                                                                        from    T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                                                                (
                                                                                                    select  max(Effect_Date) as Effect_Date,emp_id 
                                                                                                    from    T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                                                                    where   ERD1.Effect_Date <= getdate() AND Emp_ID = @R_Emp_Id1
                                                                                                    GROUP by emp_id
                                                                                                 ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                                                                        where ERD.Emp_ID = @R_Emp_Id1
                                                                                       )
                                                                    END
                                                         END                                                
                                            END
                                            
                            -----------------ended---------------------

						If (@Module_Name = 'Leave Approval') 
								BEGIN
										
										
										
										 SELECT @App_Emp_ID  = R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                                                (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                                                    where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                                                GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                                            where ERD.Emp_ID = @Emp_ID

											

										INSERT INTO #TEMP_CC
										Select	distinct(Work_Email)
										From	T0080_EMP_MASTER WITH (NOLOCK)
										where	Emp_ID = @App_Emp_ID --Emp_ID in (select app_emp_id from T0050_Scheme_Detail where Scheme_Id=  @scheme_id and not_mandatory = 1)
										
										--SELECT	DISTINCT(Work_Email) 
										--FROM	T0080_EMP_MASTER 
										--WHERE   Emp_ID IN (select app_emp_id from T0050_Scheme_Detail where Scheme_Id=  @scheme_id and not_mandatory = 1)   
										--		and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()

										
									
								END
                    
                End
            Else If (@Module_Name = 'Leave Application' And @Flag = 2)
                Begin
                
                    Insert into #Temp_Emp
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                            --union all
                            --SELECT DISTINCT(Work_Email) FROM T0080_EMP_MASTER WHERE  
                            --    Emp_ID IN (select app_emp_id from T0050_Scheme_Detail where Scheme_Id=  @scheme_id and not_mandatory = 1)   
                            --and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- Change by rohit on 27052016
                        
						

                End
			
            Else If (@Module_Name = 'Loan Application' And @Flag = 2)   --Ankit 19052014
                Begin
                Insert into #Temp_To
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                End
            Else If (@Module_Name = 'Attendance Regularization' And @Flag = 2)  --Ankit 16062014
                Begin
                Insert into #Temp_Emp
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                            
                End
            Else If (@Module_Name = 'Reimbursement\Claim Application' And @Flag = 2)    --Ankit 16062014
                Begin
            
                    Insert into #Temp_To
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                End
            --Else If (@Module_Name = 'Travel Application' And @Flag = 2)   --Ankit 24062014
            --  Begin
            --      Insert into #Temp_To
            --              Select Work_Email From T0080_EMP_MASTER Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
            --  End
            Else If (@Module_Name = 'Travel Application' And @Flag=1 or @Flag=0) --@Flag=2 )--And @Flag = 2)    --Ankit 24062014 Modified by sumit 24/09/2014
                Begin
                
                    Insert into #Temp_To
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                                
                End
            Else If (@Module_Name = 'Change Request Application' And @Flag=2 or @flag=0 )
                Begin
            
                    Insert into #Temp_Emp
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                
                End
            Else If (@Module_Name = 'Claim Application' And @Flag=1 or @flag=0 )--And @Flag = 2)    --Ankit 24062014 Modified by sumit 24/09/2014
                Begin
                --select * from #Temp_To
                --Select Work_Email From T0080_EMP_MASTER Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                    --return
                    Insert into #Temp_To
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                                
                End 
            Else If (@Module_Name = 'Travel Settlement Application' And @Flag=1 or @flag=0 )--And @Flag = 2)    --Ankit 24062014 Modified by sumit 24/09/2014
                Begin
                
                    Insert into #Temp_To
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                
                                
                End     
            Else If (@Module_Name = 'KPI Manager Approved' And @Flag=2 or @flag=0 )--added by sneha 31 mar 2015
                Begin
                    Insert into #Temp_Emp
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                                
                End
            Else If (@Module_Name = 'KPIRating Manager Approved' And @Flag=2 or @flag=0 )--added by sneha 31 mar 2015
                Begin
                    Insert into #Temp_Emp
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                                
                End
            Else If (@Module_Name = 'Recruitment Request' And @Flag=2 or @flag=0 )--added by sneha 30 mar 2015
                Begin
                    Insert into #Temp_Emp
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                                
                End
            Else If (@Module_Name = 'Candidate Approval Level' And @Flag=2 or @flag=0 )--added by sneha 30 mar 2015
                Begin
                    Insert into #Temp_Emp
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                                
                End 
            Else If (@Module_Name = 'Pre-CompOff Application' Or @Module_Name = 'Pre-CompOff Approval' And @Flag=2 or @flag=0 )--added by Gadriwala Muslim 01-jun-2015
                Begin
                    Insert into #Temp_Emp
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                                
                End 
        
            --Else If (@Module_Name = 'Attendance Regularization Approve' Or @Module_Name = 'Attendance Regularization Approve' And @Flag=2 or @flag=0 )  --Added By Jaina 02-02-2016
            --Begin
            --      Insert into #Temp_Emp
            --              Select Work_Email From T0080_EMP_MASTER Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID        
            --End
            Else If (@Module_Name = 'Attendance Regularization Approve' And (@Flag=2 or @flag=0) AND (@Rpt_Level = 0 or @Final_Approval=1))  --Added By Jaina 02-02-2016
                Begin --Did Some changes by Sumit for Getting email address when final approval in attendance regularization email through approval 28062016
                    print 'm'
                    Insert into #Temp_Emp
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID                        
                End
            ELSE IF (@Module_Name = 'Employee Probation' OR @Module_Name = 'Employee Training') AND (@Flag=2 OR @flag=0)    --Ankit 06042016
                BEGIN
                    INSERT INTO #Temp_To
                    SELECT Work_Email FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE()+1) > GETDATE()
                END
            ELSE IF (@Module_Name = 'GatePass' AND (@Flag=2 OR @flag=0) )
                BEGIN
                
                    INSERT INTO #Temp_Emp
                    SELECT Work_Email FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE()+1) > GETDATE()
                END
            Else If (@Module_Name = 'Employee Increment Application' And @Flag = 2)
                Begin               
                    Insert into #Temp_Emp
                    Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()                    
                        
                End
            Else If (@Module_Name = 'Exit Approval' And @Flag = 2)  --Added by Jaina 21-12-2016
                BEGIN
                    Insert into #Temp_Emp
                        Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE()                                
                End
						--added by mansi start for file
			  Else If (@Module_Name = 'File Application' )  
                Begin
                Insert into #Temp_To
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                
				End
			 Else If (@Module_Name = 'File Approval' )   
                Begin
			    if(@File_status_ID=4 or @File_status_ID=2)
				begin
                Insert into #Temp_To
                            Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() -- And Cmp_ID = @Cmp_ID
                end
				End
			--added by mansi end for file
            --------------------------------------------------------- Prakash Patel 28012015 ----------------------------------------------------------------------
            If (@Module_Name = 'Timesheet Application' Or @Module_Name = 'Timesheet Approval') And @Final_Approval = 0
                Begin
                
                    If @Flag = 1
                        Insert into #Temp_To Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID  and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() And Cmp_ID = @Cmp_ID
                    Else If @Flag = 0
                        Insert into #Temp_CC Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() And Cmp_ID = @Cmp_ID 
                    Else If @Flag = 2
                    Insert into #Temp_Emp Select Work_Email From T0080_EMP_MASTER WITH (NOLOCK) Where Emp_ID = @Emp_ID and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() And Cmp_ID = @Cmp_ID
                End
            -------------------------------------------------------------------------------------------------------------------------------------------------------
        
        
        ---- Pass Responsibility Employee also Sent Email --- Ankit 14072016
        IF EXISTS( SELECT 1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO  WITH (NOLOCK) WHERE CMP_ID = @Cmp_ID AND GETDATE() >= from_date AND GETDATE() <= to_date   )
            BEGIN
                
                INSERT INTO #Temp_To
                SELECT EM.Work_Email FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO MR WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MR.Pass_To_Emp_id = EM.Emp_ID
                WHERE MR.Cmp_id = @Cmp_ID AND ( GETDATE() BETWEEN from_date AND to_date )
                    AND ( MR.Manger_Emp_id IN ( SELECT Emp_ID FROM #Rpt_branch_manager ) OR MR.Manger_Emp_id = @App_Emp_ID )
                
            END
        ----
        --Added by Jaina 11-04-2017 Start
        IF @Module_Name = 'Pass Responsibility'
            BEGIN
                
                INSERT INTO #Temp_To
                SELECT  top 1 EM.Work_Email FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO MR WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MR.Pass_To_Emp_id = EM.Emp_ID
                WHERE MR.Cmp_id = @Cmp_ID AND ( GETDATE() BETWEEN from_date AND to_date )
                    AND ( MR.Manger_Emp_id = @Emp_ID ) order BY MR.From_date desc
                
                                
            END
        
                        
        --Added by Jaina 11-04-2017 End
        --Added by Jaina 24-04-2017 ( If Pass Responsibility on today's date that time when application added that time mail sent to that responsible employee)
        if (@Module_Name='Comp-Off Application' or @Module_Name='Comp-Off Approval') 
        BEgin
            
            IF EXISTS( SELECT 1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND (CONVERT(varchar(11),from_date,120)) = convert(varchar(11),GETDATE(),120) and  convert(varchar(11),to_date,120) >= convert(varchar(11),GETDATE(),120))
            BEGIN
                
                DECLARE @Res_Emp_ID as numeric  = 0
                SELECT @Res_Emp_ID = C.S_Emp_ID FROM T0100_CompOff_Application C WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON
                C.Emp_ID = E.Emp_ID WHERE C.Emp_ID = @Emp_ID
                
                INSERT INTO #Temp_To
                SELECT TOP 1 E.Work_Email FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO R WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)  ON
                    R.Pass_To_Emp_id = E.Emp_ID
                where Manger_Emp_id = @Res_Emp_ID
                and isnull(Emp_Left_Date,GETDATE()+1) > GETDATE() And E.Cmp_ID = @Cmp_ID ORDER BY R.Tran_id DESC
                
            END
        END         
--Added by Jaina 02-08-2018
        if @Module_Name = 'Employee Warning'
            begin
                insert into #Rpt_branch_manager
                SELECT R_Emp_ID FROM  T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN 
                        (select max(Effect_Date) as Effect_Date,emp_id from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK)
                            where ERD1.Effect_Date <= getdate() AND Emp_ID = @Emp_ID
                         GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = ERD.Effect_Date
                where ERD.Emp_ID = @Emp_ID
            
            
                If @Is_Manager_CC = 1  --Added by Jaina 14-11-2018
                    BEGIN
                        insert into #Temp_CC
                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID in (SELECT emp_id from #Rpt_branch_manager)                  
                    END
                ELSE
                    BEGIN                                                                                           
                        insert into #Temp_To
                        Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID in (SELECT emp_id from #Rpt_branch_manager)                  
                    End
            
                INSERT INTO #Temp_To
                SELECT Work_Email FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND ISNULL(Emp_Left_Date,GETDATE()+1) > GETDATE()

            end
            
                -- Added By Nilesh Patel on 21-Jan-2019 -- For Cliantha -- Send Notification Branch Managare
            Declare @Send_Email_Brach_Manager as bit
            Set @Send_Email_Brach_Manager = 0
            if @Module_Name='Birth Day' AND @Send_Email_Brach_Manager = 1
                Begin
                    insert into #Temp_CC
                        Select distinct(Work_Email) 
                            From T0080_EMP_MASTER EM WITH (NOLOCK)
                        Inner Join( 
                                        SELECT Emp_id 
                                            FROM T0095_MANAGERS BM WITH (NOLOCK)
                                        Inner Join
                                        (   SELECT MAX(Effective_Date) as Effe_Date,branch_id
                                                FROM dbo.T0095_MANAGERS WITH (NOLOCK)
                                            WHERE branch_id = @emp_branch AND Effective_Date <= GETDATE()
                                            GRoup by branch_id
                                        ) as Qry ON BM.Effective_Date = Qry.Effe_Date  AND BM.branch_id = Qry.branch_id
                                  ) as Qry_1 ON EM.Emp_ID = Qry_1.Emp_ID
                End

            if @Module_Name='Birth Day'
                BEGIN
                    Select * From #Temp_To
                End
        
            --Added by Nimesh on 09-Dec-2015 (If Receipeint is not supplied)
            IF NOT EXISTS(SELECT 1 FROM #Temp_To) AND @Module_Name <> 'Birth Day'
                Begin
                    insert into #Temp_To
                    Select distinct(Work_Email) From T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @App_Emp_ID or Emp_ID in (SELECT emp_id from #Rpt_branch_manager)
                End
            
			--Added by Jaina 01-07-2020
			if @Module_Name='Exit Application' or @Module_Name ='Exit Approval'
			begin	
					
					--select 11,* from #Temp_CC
					insert into #Temp_CC
					select Work_Email from T0080_EMP_MASTER EM WITH (NOLOCK)
							 where EM.cmp_id=@Cmp_id and exists (select Rpt_Mng_ID from T0300_Emp_Exit_Approval_Level EA WITH (NOLOCK) where EM.Emp_id=EA.Rpt_Mng_ID and Ea.emp_id=@Emp_ID and RPT_Level != @Rpt_Level)
					 --select 11,* from 	#Temp_CC

			end

            if @Module_Name <> 'Birth Day'
                Begin
                    Select distinct(Output_To) + ','  From #Temp_To where Output_To <>  '' for xml path('') 
                End

            Select distinct(Output_CC) + ',' From #Temp_CC where Output_CC <>  '' for xml path('') 
            Select distinct(Output_Emp) + ',' From #Temp_Emp where Output_Emp<> '' for xml path('')
            Select distinct(Output_BCC) + ',' From #Temp_BCC where Output_BCC <> '' for xml path('')
        End
        
    If @EMAIL_NTF_SENT = 0
        Begin       
            Select * From #Temp_To
            Select * From #Temp_CC
        End
        drop TABLE #Temp_To
        drop TABLE #Temp_CC
        drop TABLE #Temp_Emp
        drop TABLE #Temp_BCC
        drop TABLE #Rpt_branch_manager      
        
END



