-- =============================================  
-- Author:  <Author,,Ankit>  
-- Create date: <Create Date,,20072016>  
-- Description: <Description,,Increment Application Entry>  
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
  
CREATE PROCEDURE [dbo].[P0100_INCREMENT_APPLICATION]  
  @App_ID     NUMERIC(18, 0) OUTPUT  
 ,@Emp_ID     NUMERIC(18, 0)  
 ,@Cmp_ID     NUMERIC(18, 0)  
 ,@Branch_ID     NUMERIC(18, 0)  
 ,@Cat_ID     NUMERIC(18, 0)  
 ,@Grd_ID     NUMERIC(18, 0)  
 ,@Dept_ID     NUMERIC(18, 0)  
 ,@Desig_Id     NUMERIC(18, 0)  
 ,@Type_ID     NUMERIC(18, 0)  
 ,@Bank_ID     NUMERIC(18, 0)  
 ,@Curr_ID     NUMERIC(18, 0)  
 ,@Wages_Type    VARCHAR(10)  
 ,@Salary_Basis_On   VARCHAR(20)  
 ,@Basic_Salary    NUMERIC(18, 4)  
 ,@Gross_Salary    NUMERIC(18, 4)  
 ,@Increment_Type   VARCHAR(30)  
 ,@Increment_Date   DATETIME OUTPUT  
 ,@Increment_Effective_Date DATETIME   
 ,@Payment_Mode    VARCHAR(20)  
 ,@Inc_Bank_AC_No   VARCHAR(20)  
 ,@Emp_OT     NUMERIC(18, 0)  
 ,@Emp_OT_Min_Limit   VARCHAR(10)  
 ,@Emp_OT_Max_Limit   VARCHAR(10)  
 ,@Increment_Per    NUMERIC(18, 4)  
 ,@Increment_Amount   NUMERIC(18, 4)  
 ,@Pre_Basic_Salary   NUMERIC(18, 4)  
 ,@Pre_Gross_Salary   NUMERIC(18, 4)  
 ,@Increment_Comments  VARCHAR(250)  
 ,@Emp_Late_mark    NUMERIC  
 ,@Emp_Full_PF    NUMERIC  
 ,@Emp_PT     NUMERIC  
 ,@Emp_Fix_Salary   NUMERIC  
 ,@Emp_Late_Limit   VARCHAR(10) = '00:00'  
    ,@Late_Dedu_type   VARCHAR(10)  
    ,@Emp_part_Time    NUMERIC(1,0)  
 ,@Is_Master_Rec    TINYINT = 0 -- Define this parameter in only Insert statement  
 ,@Login_ID     NUMERIC(18) = 0  
 ,@Yearly_Bonus_Amount  NUMERIC(18, 4) = 0  
 ,@Deputation_End_Date  DATETIME = NULL   
 ,@emp_superior    NUMERIC(18,0) = 0  
 ,@Dep_Reminder    TINYINT=1  
 ,@Is_Emp_Master    TINYINT=0  
 ,@CTC      NUMERIC(18, 4) = 0  
 ,@Dep_Amount    NUMERIC(18, 4) = 0  
 ,@Dep_Month     NUMERIC(18,0) = 0  
 ,@Dep_Year     NUMERIC(18,0) = 0  
 ,@Set_Amount    NUMERIC(18, 4) = 0  
 ,@Set_Month     NUMERIC(18,0) = 0  
 ,@Set_Year     NUMERIC(18,0) = 0  
 ,@Emp_Early_mark   NUMERIC(1, 0) = 0 -- Added by Mitesh on 25/08/2011  
 ,@Early_Dedu_Type   VARCHAR(10) = ''  
 ,@Emp_Early_Limit   VARCHAR(10) = '00:00'  
 ,@Emp_Deficit_mark   NUMERIC(1, 0) = 0  
 ,@Deficit_Dedu_Type   VARCHAR(10)  = ''  
 ,@Emp_Deficit_Limit   VARCHAR(10) = ''  
 ,@Center_ID     NUMERIC(18,0) = 0 --'Alpesh 23-Sep-2011  
 ,@Emp_wd_ot_rate   NUMERIC(5,3) = 0  
    ,@Emp_wo_ot_rate   NUMERIC(5,3) = 0  
    ,@Emp_ho_ot_rate   NUMERIC(5,3) = 0  
    ,@Pre_CTC_Salary   NUMERIC(18, 4) = 0  
 ,@Incerment_Amount_gross NUMERIC(18, 4) = 0  
 ,@Incerment_Amount_CTC  NUMERIC(18, 4) = 0  
 ,@Increment_Mode   TINYINT = 0  
 ,@no_of_chlidren   NUMERIC = 0  
    ,@is_metro     TINYINT = 0  
    ,@is_physical    TINYINT = 0  
    ,@Salary_Cycle_id   NUMERIC = 0  
    ,@auto_vpf     NUMERIC(18) = 0  -- Rohit 18072013  
    ,@Segment_ID    NUMERIC = 0  
    ,@Vertical_ID    NUMERIC = 0  
    ,@SubVertical_ID   NUMERIC = 0  
    ,@subBranch_ID    NUMERIC = 0   --Added By Gadriwala 30072013  
    ,@Monthly_Deficit_Adjust_OT_Hrs tinyint =0  --Ankit 25102013  
    ,@Fix_OT_Hour_Rate_WD  numeric(18,3)=0  --Ankit 29102013  
    ,@Fix_OT_Hour_Rate_WO_HO numeric(18,3)=0  --Ankit 29102013  
    ,@Bank_ID_Two    numeric(18, 0) = 0 -- Added by Ali 14112013  
 ,@Payment_Mode_Two   varchar(20) = '' -- Added by Ali 14112013  
 ,@Inc_Bank_AC_No_Two  varchar(20) = '' -- Added by Ali 14112013  
 ,@Bank_Branch_Name   varchar(50) = '' -- Added by Ali 14112013  
 ,@Bank_Branch_Name_Two  varchar(50) = '' -- Added by Ali 14112013  
 ,@Reason_ID     numeric(5,0)=0     -- Added by nilesh patel on 21012016  
 ,@Reason_Name    varchar(200)= '' -- Added by nilesh patel on 21012016  
 ,@App_Emp_ID    Numeric = 0  
 ,@Tran_Type     char(1) = 'I'  
 ,@Customer_Audit   tinyint = 0   --Added by Jaina 03-10-2016  
 ,@Sales_Code    VARCHAR(20) = '' --Added By Ramiz on 08122016  
  ,@Physical_Percent NUMERIC(18,2) = 0 
 ,@Piece_TransSalary TinyInt = 0 --Added By Deepal on 03-06-2021  
 ,@Band_Id numeric(18,0)  = 0 --Added By mansi on 18-08-2021  
  ,@Is_PMGKY TINYINT = 0    --added by mansi 19-08-21
  ,@Is_PFMem TINYINT = 0    --added by mansi 19-08-21
  ,@Remarks Varchar(500) = ''    --added by Mr.Mehul 26-05-22
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 --SET DEADLOCK_PRIORITY NORMAL;  
   
 DECLARE @Allow_Same_Date_Increment TINYINT  --Ankit 17022015  
 SET @Allow_Same_Date_Increment  = 0  
   
 SELECT @Allow_Same_Date_Increment = Isnull(Setting_Value,0)   
 FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID And Setting_Name like 'Allow Same Date Increment'  
  
 IF @Deputation_End_Date = ''    
  SET @Deputation_End_Date  = NULL   
  
 IF @Emp_OT_Max_Limit ='0:' OR @Emp_OT_Max_Limit ='00:' OR @Emp_OT_Max_Limit ='0'OR @Emp_OT_Max_Limit = ''  
  SET @Emp_OT_Max_Limit ='00:00'  
   
 IF @Emp_OT_Min_Limit ='0:' OR @Emp_OT_Min_Limit ='00:' OR @Emp_OT_Min_Limit ='0'OR @Emp_OT_Min_Limit = ''  
  SET @Emp_OT_Min_Limit ='00:00'  
    
 IF @Emp_Late_Limit = '0' OR @Emp_Late_Limit = ''  
  SET @Emp_Late_Limit = '00:00'   
   
 IF @Emp_Early_Limit = '0' OR @Emp_Early_Limit = ''  
  SET @Emp_Early_Limit = '00:00'   
    
 IF @Dept_ID = 0  
  SET @Dept_ID = NULL   
 IF @Desig_Id = 0  
  SET @Desig_Id = NULL   
 IF @Cat_ID = 0  
  SET @Cat_ID = NULL   
 IF @Type_ID = 0  
  SET @Type_ID = NULL  
 IF @Curr_ID = 0  
  SET @Curr_ID = NULL   
 IF @Login_ID =0  
  SET @Login_ID = NULL  
 IF @emp_superior=0  
  SET @emp_superior = NULL  
 IF @Segment_ID = 0  
  SET @Segment_ID = NULL  
 IF @Vertical_ID = 0   
  SET @Vertical_ID = NULL  
 IF @SubVertical_ID = 0   
  SET @SubVertical_ID = NULL  
 IF @subBranch_ID  =0  
  SET @subBranch_ID = NULL  
 IF @Salary_Cycle_id = 0    --Added By Gadriwala Muslim 28092013  
  SET @Salary_Cycle_id = null  
    IF @Reason_Name = ''    -- Added by nilesh patel on 21012016  
  SET @Reason_Name = NULL  
    If @Center_ID = 0     -- Added by Ramiz on 05052016  
  SET @Center_ID = NULL     
    
 DECLARE @PT_Amount   NUMERIC   
 DECLARE @AD_Other_Amount NUMERIC   
 DECLARE @Max_Increment_ID NUMERIC   
 DECLARE @Max_Shift_ID  NUMERIC  
 DECLARE @Current_Date  DATETIME  
 DECLARE @Old_Bank_Id    Numeric(18, 0)   
 DECLARE @Old_Bank_Branch_Name  varchar(50)   
 DECLARE @Old_Bank_ID_Two   numeric(18, 0)   
 DECLARE @Old_Inc_Bank_AC_No_Two  varchar(20)   
 DECLARE @Old_Bank_Branch_Name_Two varchar(50)   
 DECLARE @Old_Payment_Mode_Two  varchar(20)  
   
 set @Old_Bank_Id    = 0   
 set @Old_Bank_Branch_Name  = ''   
 set @Old_Bank_ID_Two   = 0   
 set @Old_Inc_Bank_AC_No_Two  = ''  
 set @Old_Bank_Branch_Name_Two = ''  
   
    
 SELECT @Current_Date = GETDATE()  
 SET @PT_Amount = 0  
 Set @Old_Payment_Mode_Two = ''  
   
 Declare @Temp_Effective_date As Datetime  
 Set @Temp_Effective_date = DATEADD(month,month(@Increment_Effective_Date)-1,DATEADD(year,year(@Increment_Effective_Date)-1900,0))  
   
 IF @Increment_Type <> 'Joining'  
  BEGIN  
   -- This is temparory base. need to added on form side START  
   SELECT  @Emp_Early_mark = Emp_Early_mark, @Late_Dedu_Type = Late_Dedu_Type, @Emp_Late_Limit = Emp_Late_Limit  
     ,@Emp_Early_Limit = Emp_Early_Limit, @Early_Dedu_Type = Early_Dedu_Type , @Emp_wd_ot_rate = Emp_WeekDay_OT_Rate  
     ,@Emp_wo_ot_rate = Emp_WeekOff_OT_Rate, @Emp_ho_ot_rate = Emp_Holiday_OT_Rate   
     ,@Old_Bank_Id = Bank_Id,@Old_Bank_Branch_Name = Bank_Branch_Name,@Old_Bank_ID_Two = Bank_ID_Two  
     ,@Old_Inc_Bank_AC_No_Two = Inc_Bank_AC_No_Two,@Old_Bank_Branch_Name_Two = Bank_Branch_Name_Two,@Old_Payment_Mode_Two = Payment_Mode_Two  
    FROM T0095_INCREMENT i WITH (NOLOCK)  
     INNER JOIN (SELECT MAX(Increment_ID) Increment_ID, Emp_ID FROM T0095_INCREMENT WITH (NOLOCK)  
         WHERE increment_effective_Date <= @Increment_Effective_Date AND emp_ID = @Emp_ID   
         GROUP BY emp_ID  
        ) Q   
     ON i.emp_ID = Q.emp_ID AND i.Increment_ID = q.Increment_ID   
   -- This is temparory base. need to added on form side END  
     
   --For Update Old Bank Detail --Ankit 27062014  
   IF @Bank_ID = 0  
    SET @Bank_ID = @Old_Bank_Id  
   IF @Bank_Branch_Name = ''  
    Set @Bank_Branch_Name = @Old_Bank_Branch_Name  
   IF @Bank_ID_Two = 0  
    SET @Bank_ID_Two = @Old_Bank_ID_Two  
   IF @Inc_Bank_AC_No_Two = ''  
    Set @Inc_Bank_AC_No_Two = @Old_Inc_Bank_AC_No_Two  
   IF  @Bank_Branch_Name_Two = ''  
    Set @Bank_Branch_Name_Two = @Old_Bank_Branch_Name_Two  
   IF @Payment_Mode_Two = ''  
    Set @Payment_Mode_Two = @Old_Payment_Mode_Two    
   --For Update Old Bank Detail --Ankit 27062014   
  END  
   
 IF @Tran_Type = 'I'  
  BEGIN  
   --Change by dpal 12072024 changes in condtion 
   IF ((EXISTS(SELECT App_ID FROM dbo.T0100_INCREMENT_APPLICATION IA WITH (NOLOCK)  
      WHERE Ia.Emp_ID = @Emp_ID AND Ia.Increment_effective_Date= @Increment_effective_Date       
     And App_Status = 'P' ) AND @Allow_Same_Date_Increment = 0) --OR @Allow_Same_Date_Increment = 0   
     )  
    BEGIN  
     RAISERROR('@@Same Date Entry Exists@@',16,2)  
     RETURN  
    END  
  
    
   IF EXISTS(Select 1 from t0080_EMP_MASTER WITH (NOLOCK) where EMP_Id = @EMP_Id and date_of_join = @Increment_effective_Date)  
    BEGIN  
     RAISERROR('@@Not Allow Increment Application on Joining Date@@',16,2)  
     RETURN  
    END  
     
   SELECT @App_ID = ISNULL(MAX(App_ID),0) + 1 FROM dbo.T0100_INCREMENT_APPLICATION WITH (NOLOCK)   
     
  
    INSERT INTO dbo.T0100_INCREMENT_APPLICATION  
    (App_ID,Emp_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,TYPE_ID,Bank_ID,Curr_ID,Wages_Type,Salary_Basis_On,Basic_Salary,Gross_Salary,Increment_Type,Increment_Date,Increment_Effective_Date,Payment_Mode,Inc_Bank_AC_No,Emp_OT,Emp_OT_Min_Limit,Emp_OT_Max_Limit,Increment_Per,Increment_Amount,Pre_Basic_Salary,Pre_Gross_Salary,Increment_Comments,Emp_Late_mark,Emp_Full_PF,  
     Emp_PT,Emp_Fix_Salary,Emp_Part_Time,Late_Dedu_Type,Emp_Late_Limit,Emp_PT_Amount,Is_Master_Rec,Login_ID,System_Date,Yearly_Bonus_Amount,Deputation_End_Date,CTC,Emp_Early_mark,Early_Dedu_Type,Emp_Early_Limit,Emp_Deficit_mark,Deficit_Dedu_Type,Emp_Deficit_Limit,Center_ID, Emp_WeekDay_OT_Rate, Emp_WeekOff_OT_Rate, Emp_Holiday_OT_Rate, Pre_CTC_Salary ,Incerment_Amount_gross,  
     Incerment_Amount_CTC,Increment_Mode,Emp_Childran,Is_Metro_City,is_physical,salDate_id,Emp_Auto_Vpf,Segment_ID,Vertical_ID,SubVertical_ID,SubBranch_ID,Monthly_Deficit_Adjust_OT_Hrs,Fix_OT_Hour_Rate_WD,Fix_OT_Hour_Rate_WO_HO,Bank_ID_Two,Payment_Mode_Two,Bank_Branch_Name,Bank_Branch_Name_Two,Inc_Bank_AC_No_Two,Reason_ID,Reason_Name,App_Status,Customer_Audit,Sales_Code,Is_Piece_Trans_Salary,Band_Id,Is_Pradhan_Mantri,Is_1time_PF_Member,Remarks)  
   VALUES (@App_ID,@Emp_ID,@Cmp_ID,@Branch_ID,@Cat_ID,@Grd_ID,@Dept_ID,@Desig_Id,@Type_ID,@Bank_ID,@Curr_ID,@Wages_Type,@Salary_Basis_On,@Basic_Salary,@Gross_Salary,@Increment_Type,@Increment_Date,@Increment_Effective_Date,@Payment_Mode,@Inc_Bank_AC_No,@Emp_OT,@Emp_OT_Min_Limit,@Emp_OT_Max_Limit,@Increment_Per,@Increment_Amount,@Pre_Basic_Salary,@Pre_Gross_Salary,@Increment_Comments,@Emp_Late_mark,@Emp_Full_PF,  
     @Emp_PT,@Emp_Fix_Salary,@Emp_part_Time,@Late_Dedu_type,@Emp_Late_Limit,@PT_Amount,@Is_Master_Rec,@Login_ID,GETDATE(),@Yearly_Bonus_Amount,@Deputation_End_Date,@CTC,@Emp_Early_mark,@Early_Dedu_Type,@Emp_Early_Limit,@Emp_Deficit_mark,@Deficit_Dedu_Type
,@Emp_Deficit_Limit,@Center_ID,@Emp_wd_ot_rate,@Emp_wo_ot_rate,@Emp_ho_ot_rate, @Pre_CTC_Salary ,@Incerment_Amount_gross,  
     @Incerment_Amount_CTC,@Increment_Mode,@no_of_chlidren ,@is_metro ,@is_physical,@Salary_Cycle_id,@auto_vpf,@Segment_ID,@Vertical_ID,@SubVertical_ID,@subBranch_ID,@Monthly_Deficit_Adjust_OT_Hrs,@Fix_OT_Hour_Rate_WD,@Fix_OT_Hour_Rate_WO_HO,@Bank_ID_Two,
@Payment_Mode_Two,@Bank_Branch_Name,@Bank_Branch_Name_Two,@Inc_Bank_AC_No_Two,@Reason_ID,@Reason_Name,'P',@Customer_Audit , @Sales_Code,@Piece_TransSalary,@Band_Id,@Is_PMGKY,@Is_PFMem,@Remarks)   --Chnage By Jaina 03-10-2016 -- Ramiz Added Sales_Code on 08122016  
      
     
  END  
 ELSE IF @Tran_Type = 'U'  
  BEGIN    
  
   select @App_ID  
   IF EXISTS (SELECT 1 FROM dbo.T0100_INCREMENT_APPLICATION WITH (NOLOCK) WHERE App_ID =@App_ID)  
    BEGIN  
       
     UPDATE dbo.T0100_INCREMENT_APPLICATION  
     SET  Branch_ID = @Branch_ID, Cat_ID = @Cat_ID, Grd_ID = @Grd_ID, Dept_ID = @Dept_ID,   
       Desig_Id = @Desig_Id, TYPE_ID = @Type_ID, Bank_ID = @Bank_ID, Curr_ID = @Curr_ID, Wages_Type = @Wages_Type,   
       Salary_Basis_On = @Salary_Basis_On, Basic_Salary = @Basic_Salary, Gross_Salary = @Gross_Salary, Increment_Type = @Increment_Type,   
       Increment_Date = @Increment_Date, Increment_Effective_Date = @Increment_Effective_Date, Payment_Mode = @Payment_Mode,   
       Inc_Bank_AC_No = @Inc_Bank_Ac_no, Increment_Per =@Increment_Per, Increment_Amount =@Increment_Amount, Pre_Basic_Salary =@Pre_Basic_Salary, Pre_Gross_Salary =@Pre_Gross_Salary,   
       Increment_Comments =@Increment_Comments ,Emp_OT =@Emp_OT,Emp_OT_Min_Limit = @Emp_OT_Min_Limit,Emp_OT_Max_Limit = @Emp_OT_Max_Limit,  
       Emp_Late_mark=@Emp_Late_mark,Emp_Full_PF=@Emp_Full_PF,Emp_PT=@Emp_PT,Emp_Fix_Salary=@Emp_Fix_Salary,  
       Emp_PT_Amount = @PT_Amount,Emp_Late_Limit =@Emp_Late_Limit,Late_Dedu_type =@Late_Dedu_type,Emp_part_Time=@Emp_part_Time,  
       Login_ID = @Login_ID,System_Date =GETDATE(),Yearly_Bonus_Amount=@Yearly_Bonus_Amount,Deputation_End_Date=@Deputation_End_Date,Is_Deputation_Reminder=@Dep_Reminder,  
       CTC = @CTC,  
       Emp_Early_mark=@Emp_Early_mark,Early_Dedu_Type=@Early_Dedu_Type,Emp_Early_Limit=@Emp_Early_Limit,  
       Emp_Deficit_mark=@Emp_Deficit_mark,Deficit_Dedu_Type=@Deficit_Dedu_Type ,Emp_Deficit_Limit=@Emp_Deficit_Limit,  
       Center_ID=@Center_ID,  
       Emp_WeekDay_OT_Rate = @Emp_wd_ot_rate, Emp_WeekOff_OT_Rate = @Emp_wo_ot_rate, Emp_Holiday_OT_Rate = @Emp_ho_ot_rate,  
       Pre_CTC_Salary = @Pre_CTC_Salary ,Incerment_Amount_gross = @Incerment_Amount_gross,Incerment_Amount_CTC = @Incerment_Amount_CTC,Increment_Mode = @Increment_Mode  
       ,Emp_Childran = @no_of_chlidren , Is_Metro_City = @is_metro , is_physical = @is_physical  
       ,salDate_id = @Salary_Cycle_id,Emp_Auto_Vpf=@Auto_Vpf -- rohit 18072013  
       ,Segment_ID = @Segment_ID ,Vertical_ID = @Vertical_ID,SubVertical_ID = @SubVertical_ID,subbranch_ID = @subBranch_ID -- Added By Gadriwala Muslim 24072013  
       ,Monthly_Deficit_Adjust_OT_Hrs=@Monthly_Deficit_Adjust_OT_Hrs  
       ,Fix_OT_Hour_Rate_WD=@Fix_OT_Hour_Rate_WD  
       ,Fix_OT_Hour_Rate_WO_HO=@Fix_OT_Hour_Rate_WO_HO  
       ,Bank_ID_Two = @Bank_ID_Two       -- Added By Ali 14112013  
       ,Payment_Mode_Two = @Payment_Mode_Two     -- Added By Ali 14112013  
       ,Inc_Bank_AC_No_Two = @Inc_Bank_AC_No_Two    -- Added By Ali 14112013  
       ,Bank_Branch_Name = @Bank_Branch_Name     -- Added By Ali 14112013  
       ,Bank_Branch_Name_Two = @Bank_Branch_Name_Two   -- Added By Ali 14112013  
       ,@Reason_ID = Reason_ID        -- Added By Nilesh Patel 21012016  
       ,@Reason_Name = Reason_Name       -- Added By Nilesh Patel 21012016  
       ,Customer_Audit = @Customer_Audit   --Added By Jaina 03-10-2016  
       ,Sales_Code = @Sales_Code --Added By Ramiz on 08122016  
       ,Is_Piece_Trans_Salary = @Piece_TransSalary  
	   ,Band_Id=@Band_Id
	   ,Is_Pradhan_Mantri = @Is_PMGKY    
         ,Is_1time_PF_Member= @Is_PFMem   
		 ,Remarks= @Remarks   --Added by Mr.Mehul 26052022
      WHERE App_ID = @App_ID  AND Emp_ID = @Emp_ID  
             
          
    END   
  END  
 ELSE IF @Tran_Type = 'D'  
  BEGIN  
   DECLARE @Tran_ID NUMERIC  
   DECLARE @Delete_Flag NUMERIC  
   SET @Tran_ID = 0  
   SET @Delete_Flag = 0  
	
	if exists(Select 1 from T0100_INCREMENT_APPLICATION where App_ID = @App_ID and App_Status = 'P')
	begin
		DELETE FROM T0100_INCREMENT_APPLICATION WHERE App_ID = @App_ID
	end	

	IF EXISTS( SELECT 1 FROM T0095_INCREMENT WITH (NOLOCK) WHERE Increment_App_ID = @App_ID )  
    BEGIN  
     DECLARE @IncId NUMERIC  
           
     SELECT @IncId = Increment_ID,@Emp_ID = Emp_ID FROM T0095_INCREMENT WITH (NOLOCK) WHERE Increment_App_ID = @App_ID  
       
     --Declare @Increment_eff_Date Datetime  
     --Declare @Max_Increment_eff_Date Datetime   
     
     --Select @Max_Increment_ID = I.Increment_ID , @Max_Increment_eff_Date = Increment_Effective_Date   
     --   From T0095_Increment I WITH (NOLOCK) inner join  
     --   (select Max(Increment_ID)Increment_ID ,Emp_ID From T0095_Increment WITH (NOLOCK) where Emp_ID=@Emp_ID group by emp_ID)Q on  
     --   i.Emp_ID= q.Emp_ID  and i.Increment_ID =q.Increment_ID  
  
     --IF EXISTS( SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND Increment_ID = @IncId)  
     -- BEGIN         
     --  RAISERROR('@@Salary Entry Exists@@',16,2)  
     --  RETURN  
     -- END  
       
     --EXEC P0095_INCREMENT_DELETE @Increment_ID = @IncId,@Emp_ID = @Emp_ID,@Cmp_ID = @Cmp_ID, @Flag = 'Increment Application'  
      --  select @App_ID,@Emp_ID
     DELETE FROM T0100_INCREMENT_APPLICATION WHERE App_ID = @App_ID  
     DELETE FROM T0115_INCREMENT_APP_EARN_DEDUCTION_LEVEL WHERE App_ID = @App_ID AND Emp_ID = @Emp_ID  
     DELETE FROM T0115_INCREMENT_APPROVAL_LEVEL WHERE App_ID = @App_ID AND Emp_ID = @Emp_ID  
       

       
     SET @Delete_Flag = 1  
    END  
   ELSE  
    BEGIN  
       
	  
     SELECT @Tran_ID = Tran_ID,@Emp_ID = Emp_ID FROM T0115_INCREMENT_APPROVAL_LEVEL WITH (NOLOCK) WHERE App_ID = @App_ID   
      AND Rpt_Level = ( SELECT Max(Rpt_Level) FROM T0115_INCREMENT_APPROVAL_LEVEL WITH (NOLOCK) WHERE App_ID = @App_ID )  
            
     IF @Tran_ID <> 0  
      BEGIN  
       DELETE FROM T0115_INCREMENT_APP_EARN_DEDUCTION_LEVEL WHERE Tran_ID_Level = @Tran_ID AND Emp_ID = @Emp_ID  
       --DELETE FROM T0115_INCREMENT_APPROVAL_LEVEL WHERE Tran_ID = @Tran_ID AND Emp_ID = @Emp_ID  
       DELETE FROM T0115_INCREMENT_APPROVAL_LEVEL WHERE App_ID = @App_Id AND Emp_ID = @Emp_ID  
         
  
       SET @Delete_Flag = 1  
      END  
       
            
     --IF @Tran_ID <> 0  
     -- BEGIN  
     --  --DELETE FROM T0115_INCREMENT_APP_EARN_DEDUCTION_LEVEL WHERE Tran_ID_Level = @Tran_ID AND Emp_ID = @Emp_ID  
     --  --DELETE FROM T0115_INCREMENT_APPROVAL_LEVEL WHERE Tran_ID = @Tran_ID AND Emp_ID = @Emp_ID  
         
     --  SET @Delete_Flag = 1  
     --  RAISERROR('@@ Reference Exists in Increment Approval @@',16,2)  
     --  RETURN  
         
         
     -- END  
    END   
     
   UPDATE T0100_INCREMENT_APPLICATION SET App_Status = 'P' WHERE App_ID = @App_ID   
     
   IF @Delete_Flag = 0  
    BEGIN  
     DELETE FROM T0100_INCREMENT_APP_EARN_DEDUCTION WHERE App_ID = @App_ID-- AND Emp_ID = @Emp_ID  
     DELETE FROM T0100_INCREMENT_APPLICATION WHERE App_ID = @App_ID --AND Emp_ID = @Emp_ID  
    END  
  END  
  
RETURN
