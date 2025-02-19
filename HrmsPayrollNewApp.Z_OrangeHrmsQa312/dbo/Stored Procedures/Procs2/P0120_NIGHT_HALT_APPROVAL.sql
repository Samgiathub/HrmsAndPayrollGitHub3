  
  
  
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0120_NIGHT_HALT_APPROVAL]     
   @Approval_ID  NUMERIC OUTPUT      
  ,@Application_ID NUMERIC       
  ,@Cmp_ID  NUMERIC      
  ,@Emp_ID  NUMERIC      
  ,@S_Emp_ID NUMERIC      
  ,@FROM_DATE DATETIME      
  ,@To_Date  DATETIME      
  ,@NoOfDays    NUMERIC(18,2)  
  ,@Approved_NoOfDays NUMERIC(18,2)  
  ,@VisitPlace VARCHAR(100)  
  ,@Remarks  VARCHAR(100)  
  ,@Is_Effect_Sal INT  
  ,@Eff_Month NUMERIC  
  ,@Eff_Year NUMERIC  
  ,@Apr_Status VARCHAR(1) = 'A'  
  ,@Login_ID NUMERIC       
  ,@TRAN_TYPE VARCHAR(1)     
  ,@User_Id numeric(18,0) = 0 -- Add By Mukti 05072016  
  ,@IP_Address varchar(30)= '' -- Add By Mukti 05072016  
  ,@AdminAprflag tinyint = 0 -- added by tejas 10062024
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   
 --DECLARE @App_Status CHAR(1)      
 --SET @App_Status  = 'P'  
   
 IF @S_Emp_ID = 0       
    SET @S_Emp_ID = NULL      
   
 DECLARE @Amount NUMERIC (18,2)   
 DECLARE @Calculated_Amount NUMERIC (18,2)  
   
 Declare @Basic_Salary as numeric(18,2)  
 Declare @Increment_Id as numeric(18,0)  
 Declare @other_Amount as Numeric(18,2)  
 Declare @month_Days as numeric(18,2)  
   
 SET @Amount = 0  
 SET @Calculated_Amount = 0   
 set @Basic_Salary = 0  
 set @Increment_Id = 0  
 set @other_Amount = 0  
 set @month_Days = 0  
     
 -- Add By Mukti 05072016(start)  
 declare @OldValue as  varchar(max)  
 Declare @String as varchar(max)  
 set @String=''  
 set @OldValue =''  
 -- Add By Mukti 05072016(end)   
   set @Remarks = dbo.fnc_ReverseHTMLTags(@Remarks)  --added by Ronak 100121  
          
 IF @TRAN_TYPE ='I'  
  BEGIN  
  
  IF (@AdminAprflag = 1)
  BEGIN
  exec P0100_NIGHT_HALT_APPLICATION @Application_ID output,@Cmp_ID,@Emp_ID,@S_Emp_ID,@FROM_DATE,@To_Date,@NoOfDays,@VisitPlace,@Remarks,@Login_ID,@TRAN_TYPE,@User_Id,@IP_Address
  END
  IF exists (select 1 from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_ID and AD_CALCULATE_ON ='Night Halt')  
   BEGIN  
      
		select @month_Days = isnull(No_Of_Month ,0) from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_ID and AD_CALCULATE_ON ='Night Halt'  
      
		IF @month_Days =  0  
		BEGIN  
		 set @month_Days = datediff(day,dateadd(day, 0, dateadd(month, ((@Eff_Year - 2012) * 12) + @Eff_Month - 1, 0)),dateadd(day, 0, dateadd(month, ((@Eff_Year - 2012) * 12) + @Eff_Month, 0)))   
		END  
		select @Basic_Salary = isnull(Basic_Salary,0) ,@Increment_Id=isnull(i.Increment_ID,0)  
     From T0095_Increment I WITH (NOLOCK) inner join       
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)    
     where Increment_Effective_date <= @To_Date      
     and Cmp_ID = @Cmp_ID and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'     
     group by emp_ID) Qry on      
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID      
     Where I.Emp_ID = @Emp_ID   
       
       
		--select @other_Amount = isnull(sum(Ed.E_AD_AMOUNT),0)  from T0050_AD_MASTER AM inner join   
		--(select * from T0100_EMP_EARN_DEDUCTION where EMP_ID = @emp_id and INCREMENT_ID = @increment_id ) ED on Am.AD_ID = Ed.Ad_id     
		--where Ad_Effect_on_Nighthalt =1   
       
		Select @other_Amount = isnull(SUM(Qry1.E_AD_AMOUNT),0) from  
(  
select Case When Qry1.E_AD_AMOUNT IS null Then eed.E_AD_AMOUNT Else Qry1.E_AD_AMOUNT End As E_AD_AMOUNT  
from dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)  
    Inner Join T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID   
    LEFT OUTER JOIN  
    ( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE   
     From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN  
     ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)  
      Where Emp_Id = @Emp_Id  
      And For_date <= @To_Date and Increment_ID=@Increment_Id -- ( INDUCTOTHERM ISSUE ) ADDED BY RAJPUT ON 08012018 REVISED AMOUNT TAKE WRONG  
      Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id   
    ) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                    
   Where INCREMENT_ID = @increment_id And EED.EMP_ID = @Emp_Id And Isnull(AM.Ad_Effect_on_Nighthalt,0) = 1  
   And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'  
  
UNION ALL     
  
SELECT E_Ad_Amount  
  FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN    
   ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)  
    Where Emp_Id  = @Emp_Id And For_date <= @To_Date -- ( INDUCTOTHERM ISSUE ) ADDED BY RAJPUT ON 08012018 REVISED AMOUNT TAKE WRONG  
    Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                     
     INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                       
  WHERE emp_id = @emp_id   
    And Adm.AD_ACTIVE = 1  
    And EEd.ENTRY_TYPE = 'A'  
    And Isnull(ADM.Ad_Effect_on_Nighthalt,0) = 1  
    ) Qry1  
  
       
       
		set @Calculated_Amount = @Basic_Salary + @other_Amount  
		set @Amount =  (@Calculated_Amount /@month_Days) * @Approved_NoOfDays  
       
   END  
    
   SELECT @Approval_ID = ISNULL(MAX(Approval_ID),0) + 1 FROM dbo.T0120_NIGHT_HALT_APPROVAL WITH (NOLOCK)      
     
   IF EXISTS(SELECT 1 FROM T0120_NIGHT_HALT_APPROVAL WITH (NOLOCK) WHERE APPLICATION_ID=@APPLICATION_ID AND EMP_ID=@EMP_ID) -- ADDED BY RAJPUT ON 01022018 FOR APPROVE TIME DUPLICATE ROW WAS INSERTED  
    BEGIN   
      
       SELECT @APPROVAL_ID=APPROVAL_ID FROM T0120_NIGHT_HALT_APPROVAL WITH (NOLOCK) WHERE APPLICATION_ID=@APPLICATION_ID AND EMP_ID=@EMP_ID  
       RETURN   
      
   END  
   
   INSERT INTO dbo.T0120_NIGHT_HALT_APPROVAL      
                            (Approval_ID,Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, FROM_DATE, To_Date,No_Of_Days,Approve_Days,Visit_Place ,Remarks,Is_Effect_Sal,Eff_Month,Eff_Year, App_Status,Amount,Calculated_Amount, Login_ID,System_Date,AdminFlag)      
   VALUES     (@Approval_ID,@Application_ID,@Cmp_ID,@Emp_ID,@S_Emp_ID,@FROM_DATE,@To_Date,@NoOfDays,@Approved_NoOfDays,@VisitPlace,@Remarks,@Is_Effect_Sal,@Eff_Month,@Eff_Year,@Apr_Status,@Amount,@Calculated_Amount,@Login_ID,getdate(),@AdminAprflag)      
     
   UPDATE T0100_NIGHT_HALT_APPLICATION  
   SET  App_Status = @Apr_Status  
   WHERE Application_ID = @Application_ID AND EMP_ID = @Emp_ID     
     
 -- Add By Mukti 05072016(start)  
 exec P9999_Audit_get @table = 'T0120_NIGHT_HALT_APPROVAL' ,@key_column='Approval_ID',@key_Values=@Approval_ID,@String=@String output  
 set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))    
 -- Add By Mukti 05072016(end)      
     
     END  
    ELSE IF @TRAN_TYPE ='U'   
  BEGIN  
  -- Add By Mukti 05072016(start)  
  exec P9999_Audit_get @table='T0120_NIGHT_HALT_APPROVAL' ,@key_column='Approval_ID',@key_Values=@Approval_ID,@String=@String output  
  set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
     -- Add By Mukti 05072016(end)  
      
   if exists (select 1 from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_ID and AD_CALCULATE_ON ='Night Halt')  
   begin  
      
    select @month_Days = isnull(No_Of_Month,0) from T0050_AD_MASTER WITH (NOLOCK) where CMP_ID=@Cmp_ID and AD_CALCULATE_ON ='Night Halt'  
      
    if @month_Days =  0  
    begin  
     set @month_Days = datediff(day,dateadd(day, 0, dateadd(month, ((@Eff_Year - 2012) * 12) + @Eff_Month - 1, 0)),dateadd(day, 0, dateadd(month, ((@Eff_Year - 2012) * 12) + @Eff_Month, 0)))   
    end  
      
    select @Basic_Salary = isnull(Basic_Salary,0) ,@Increment_Id=isnull(i.Increment_ID,0)  
     From T0095_Increment I WITH (NOLOCK) inner join       
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)     
     where Increment_Effective_date <= @To_Date      
     and Cmp_ID = @Cmp_ID and Increment_Type <> 'Transfer' and Increment_Type <> 'Deputation'     
     group by emp_ID) Qry on      
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID      
     Where I.Emp_ID = @Emp_ID   
       
       
     --select @other_Amount = isnull(sum(Ed.E_AD_AMOUNT),0)  from T0050_AD_MASTER AM inner join   
     --(select * from T0100_EMP_EARN_DEDUCTION where EMP_ID = @emp_id and INCREMENT_ID = @increment_id ) ED on Am.AD_ID = Ed.Ad_id     
     --where Ad_Effect_on_Nighthalt =1   
       
           Select @other_Amount = isnull(SUM(Qry1.E_AD_AMOUNT),0) from  
(  
select Case When Qry1.E_AD_AMOUNT IS null Then eed.E_AD_AMOUNT Else Qry1.E_AD_AMOUNT End As E_AD_AMOUNT  
from dbo.T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK)  
    Inner Join T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = Am.AD_ID And EED.CMP_ID = Am.CMP_ID   
    LEFT OUTER JOIN  
    ( Select EEDR.EMP_ID, EEDR.AD_Id, EEDR.For_Date, EEDR.E_AD_Amount,EEDR.E_AD_PERCENTAGE,EEDR.ENTRY_TYPE   
     From T0110_EMP_Earn_Deduction_Revised EEDR WITH (NOLOCK) INNER JOIN  
     ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)  
      Where Emp_Id = @Emp_Id  
      And For_date <= @To_Date  
      Group by Ad_Id )Qry on Eedr.For_Date = Qry.For_Date And Eedr.Ad_Id = Qry.Ad_Id   
    ) Qry1 on eed.AD_ID = qry1.ad_Id And EEd.EMP_ID = Qry1.EMP_ID                    
   Where INCREMENT_ID = @increment_id And EED.EMP_ID = @Emp_Id And Isnull(AM.Ad_Effect_on_Nighthalt,0) = 1  
   And Case When Qry1.ENTRY_TYPE IS null Then '' Else Qry1.ENTRY_TYPE End <> 'D'  
  
UNION ALL     
  
SELECT E_Ad_Amount  
  FROM dbo.T0110_EMP_EARN_DEDUCTION_REVISED EED WITH (NOLOCK) INNER JOIN    
   ( Select Max(For_Date) For_Date, Ad_Id From T0110_EMP_Earn_Deduction_Revised WITH (NOLOCK)  
    Where Emp_Id  = @Emp_Id And For_date <= @To_Date  
    Group by Ad_Id )Qry on EED.For_Date = Qry.For_Date And EED.Ad_Id = Qry.Ad_Id                     
     INNER JOIN dbo.T0050_AD_MASTER ADM WITH (NOLOCK) ON EEd.AD_ID = ADM.AD_ID                       
  WHERE emp_id = @emp_id   
    And Adm.AD_ACTIVE = 1  
    And EEd.ENTRY_TYPE = 'A'  
    And Isnull(ADM.AD_EFFECT_ON_LEAVE,0) = 1  
    ) Qry1  
  
       
     set @Calculated_Amount = @Basic_Salary + @other_Amount  
     set @Amount =  (@Calculated_Amount /@month_Days) * @Approved_NoOfDays  
       
   end  
    
     
   UPDATE  dbo.T0120_NIGHT_HALT_APPROVAL      
   SET     S_Emp_ID = @S_Emp_ID,FROM_DATE = @FROM_DATE, To_Date = @To_Date,No_Of_Days = @NoOfDays,Approve_days  = @Approved_NoOfDays,  
     Visit_Place = @VisitPlace,Remarks = @Remarks,Is_Effect_Sal = @Is_Effect_Sal,Eff_Month = @Eff_Month,Eff_Year = @Eff_Year,  
     Amount = @Amount , Calculated_Amount = @Calculated_Amount,App_Status = @Apr_Status,  
     Login_ID = @Login_ID, System_Date = GETDATE() , AdminFlag = @AdminAprflag 
   WHERE Approval_ID = @Approval_ID  
     
   UPDATE T0100_NIGHT_HALT_APPLICATION  
   SET  App_Status = @Apr_Status  
   WHERE Application_ID = @Application_ID AND EMP_ID = @Emp_ID  
     
 -- Add By Mukti 05072016(start)  
  exec P9999_Audit_get @table = 'T0120_NIGHT_HALT_APPROVAL' ,@key_column='Approval_ID',@key_Values=@Approval_ID,@String=@String output  
  set @OldValue = @OldValue + 'New Value' + '#' + cast(@String as varchar(max))  
   -- Add By Mukti 05072016(end)        
  END  
 ELSE IF @TRAN_TYPE ='D'   
  BEGIN  
     
   IF @Emp_ID = 0 AND @Approval_ID = 0  
    BEGIN  
     DELETE FROM T0100_NIGHT_HALT_APPLICATION WHERE Application_ID = @Application_ID  
    END  
      
  select @Eff_Month=eff_month,@Eff_Year=Eff_Year,@Emp_ID=emp_id from T0120_NIGHT_HALT_APPROVAL WITH (NOLOCK) where Approval_ID = @Approval_ID AND Application_ID = @Application_ID  
      
   if  exists (select 1 from T0200_MONTHLY_SALARY WITH (NOLOCK) where month(Month_End_Date) = @Eff_Month and YEAR(month_end_date) = @Eff_Year and Emp_ID =@Emp_ID )  
    begin  
    raiserror('@@Salary Exist for Employee@@',16,2)  
     return -1  
    end  
     
  -- Add By Mukti 05072016(start)  
  exec P9999_Audit_get @table='T0120_NIGHT_HALT_APPROVAL' ,@key_column='Approval_ID',@key_Values=@Approval_ID,@String=@String output  
  set @OldValue = @OldValue + 'old Value' + '#' + cast(@String as varchar(max))  
    -- Add By Mukti 05072016(end)  
      
   DELETE FROM dbo.T0120_NIGHT_HALT_APPROVAL where Approval_ID = @Approval_ID AND Application_ID = @Application_ID  
   IF @AdminAprflag = 1
	BEGIN
	DELETE FROM T0100_NIGHT_HALT_APPLICATION WHERE Application_ID = @Application_ID  
	END
   
   UPDATE T0100_NIGHT_HALT_APPLICATION  
   SET  App_Status = 'P'  
   WHERE Application_ID = @Application_ID  
     
      
  END  
 exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Night Halt Approval',@OldValue,@Emp_ID,@User_Id,@IP_Address,1  
RETURN  
  