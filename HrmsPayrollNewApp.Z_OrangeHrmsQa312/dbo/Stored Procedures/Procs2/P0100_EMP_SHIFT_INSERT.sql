
  
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0100_EMP_SHIFT_INSERT]  
 @EMP_ID   NUMERIC,  
 @CMP_ID   NUMERIC,  
 @SHIFT_ID  NUMERIC,  
 @FOR_DATE  DATETIME,  
 @OLD_JOIN_DATE DATETIME = NULL,  
 @SHIFT_TYPE  TINYINT = 0, --added by chetan 050917 for temprary shift option  
 @FlagforEmpMaster Tinyint = 0 --optional parameter to restrict month lock condition for employee master (added by mehul)

AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   
 DECLARE @SHIFT_TRAN_ID NUMERIC  
   
 DECLARE @FLAG NUMERIC  
 SET @FLAG = 0  
   
 Declare @FirstDefaultShiftDate DateTime  
 SELECT @FirstDefaultShiftDate  = Min(For_Date) FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND SHIFT_TYPE = 0  


if @FlagforEmpMaster = 0 
begin

 IF @FirstDefaultShiftDate = @For_Date AND @SHIFT_TYPE = 1  
  BEGIN  
   Raiserror('@@You cannot modify the Default Shift specified on Date of Joining@@',16,2)  
   return -1  
  END  
 
   IF EXISTS(Select 1 from T0250_MONTHLY_LOCK_INFORMATION where MONTH = month(@For_Date) and YEAR = Year(@For_Date) and Cmp_ID = @Cmp_ID   
		and (Branch_ID = (Select Branch_ID from T0080_EMP_MASTER where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID) or Branch_ID = 0))        
   Begin         
            Raiserror('@@Same Date Month Is Locked@@',16,2)         
			return         
   End     
end
 --IF EXISTS(Select 1 from T0200_MONTHLY_SALARY where month(Month_St_Date) = month(@For_Date) and Year(Month_St_Date) = Year(@For_Date) and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID)        
 -- And @Shift_type=1      
 --   Begin        
 --    Raiserror('@@This Months Salary Exists.So You Can not Change Shift.@@',16,2)        
 --    return -1        
 --   End        
	
 --  Else If Exists(Select 1 from T0200_MONTHLY_SALARY where month(Month_St_Date) = month(@For_Date) and Year(Month_St_Date) = Year(@For_Date) and Cmp_ID = @Cmp_ID and Emp_ID = @Emp_ID) And @Shift_type=0        
 --   Begin        
 --    Raiserror('@@This Months Salary Exists.So You Can not Change Shift.@@',16,2)        
 --    return -1        
 --   End   
   
 SELECT @SHIFT_TRAN_ID = ISNULL(MAX(SHIFT_TRAN_ID),0) + 1 FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)  
   
 IF ISNULL(@OLD_JOIN_DATE,'') <> ''  
  BEGIN  
   IF EXISTS(SELECT EMP_ID FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND FOR_DATE = @OLD_JOIN_DATE )  
    BEGIN  
    --select * from T0100_EMP_SHIFT_DETAIL where FOR_DATE = @OLD_JOIN_DATE and EMP_ID = @EMP_ID  
    --IF (@for_Date <> @OLD_JOIN_DATE ) --Added this condition by Sumit for Update date of Joining on 13062016  
    -- Begin  
	
      UPDATE T0100_EMP_SHIFT_DETAIL  
       SET SHIFT_ID = @SHIFT_ID   
        ,FOR_DATE =  @FOR_DATE --CASE WHEN @for_Date <> @OLD_JOIN_DATE THEN @FOR_DATE ELSE FOR_Date END --'Commented by Sumit with Discussion with Ramiz and Hardik Bhai Case of Shift is Change Automatically during Employee Update on 10052016'  
        ,Shift_Type = @SHIFT_TYPE   
      WHERE EMP_ID = @EMP_ID AND FOR_DATE = @OLD_JOIN_DATE  
     --End   
	
    END  
	
   ELSE IF EXISTS(SELECT EMP_ID FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND FOR_DATE = @FOR_DATE )  
    BEGIN  
     UPDATE    T0100_EMP_SHIFT_DETAIL  
     SET       Shift_ID = @Shift_ID  
     ,Shift_Type = @SHIFT_TYPE   
     WHERE   EMP_ID = @EMP_ID AND FOR_DATE = @FOR_DATE   
    END  
   ELSE  
    BEGIN  
     INSERT INTO T0100_EMP_SHIFT_DETAIL  
            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date,Shift_Type )  
     VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date, @SHIFT_TYPE )  
     SET @FLAG = 1  
    END   
  END  
 ELSE IF EXISTS(SELECT EMP_ID FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) WHERE EMP_ID = @EMP_ID AND FOR_DATE = @FOR_DATE )  
  BEGIN  
   UPDATE    T0100_EMP_SHIFT_DETAIL  
   SET       Shift_ID = @Shift_ID  
   ,Shift_Type = @SHIFT_TYPE   
   WHERE   EMP_ID = @EMP_ID AND FOR_DATE = @FOR_DATE   
   
  END 
 
 ELSE  
  BEGIN  
   INSERT INTO T0100_EMP_SHIFT_DETAIL  
          (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date,Shift_Type)  
   VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date,@Shift_type)  
   SET @FLAG = 1  
  END  
    
 IF @FLAG = 1 -- Added For Send SMS if Employee Shift change Nilesh Patel on 19022018  
  BEGIN  
   DECLARE @SMS_EMP_NAME VARCHAR(200)  
   SET @SMS_EMP_NAME = ''  
     
   SELECT @SMS_EMP_NAME = Emp_First_Name FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE CMP_ID = @CMP_ID AND EMP_ID = @EMP_ID  
     
   DECLARE @SHIFT_NAME VARCHAR(200)  
   SET @SHIFT_NAME = ''  
     
   SELECT @SHIFT_NAME = SHIFT_NAME FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE SHIFT_ID = @SHIFT_ID AND CMP_ID = @CMP_ID   
     
   DECLARE @SMS_OLD_SHIFT_ID NUMERIC  
   SET @SMS_OLD_SHIFT_ID = 0  
            
   DECLARE @SMS_OLD_SHIFT_NAME VARCHAR(100)  
   SET @SMS_OLD_SHIFT_NAME = ''  
            
   SELECT @SMS_OLD_SHIFT_ID =SHIFT_ID   
    FROM T0100_EMP_SHIFT_DETAIL I1 WITH (NOLOCK)  
   INNER JOIN(  
       SELECT MAX(FOR_DATE)FOR_DATE,EMP_ID   
        FROM T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)  
       WHERE EMP_ID=@EMP_ID AND SHIFT_TYPE=0 AND FOR_DATE < @FOR_DATE  
       GROUP BY EMP_ID ,SHIFT_TYPE  
       )I2 ON I1.EMP_ID= I2.EMP_ID  AND I1.FOR_DATE =I2.FOR_DATE  
                
   SELECT @SMS_OLD_SHIFT_NAME = SHIFT_NAME FROM T0040_SHIFT_MASTER WITH (NOLOCK) WHERE SHIFT_ID = @SMS_OLD_SHIFT_ID  
    
   DECLARE @SMS_TEXT VARCHAR(MAX)  
   SET @SMS_TEXT = ''  
   SET @SMS_TEXT = 'Dear ' + @SMS_EMP_NAME + ', your shift ' + @SMS_OLD_SHIFT_NAME + ' is change temporary from ' + CONVERT(VARCHAR(11), @FOR_DATE, 103) + ' and new shift is ' + ISNULL(@SHIFT_NAME,'') + ' Regards, Team - HR'   
     
   EXEC P0100_SMS_TRANSCATION 0,@CMP_ID,@EMP_ID,'Shift change',@SMS_TEXT  
  END  
    
 RETURN  
  
  
  
  
