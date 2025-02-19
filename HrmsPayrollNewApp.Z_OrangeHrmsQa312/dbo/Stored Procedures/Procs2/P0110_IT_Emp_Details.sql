

  
  
  
-- =============================================  
-- Author:  <Author,,Zishanali Tailor>  
-- Create date: <Create Date,,10012014>  
-- Description: <Description,,>  
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[P0110_IT_Emp_Details]  
   @Cmp_ID numeric(18,0)  
  ,@Emp_ID numeric(18,0)  
  ,@Financial_Year varchar(50)  
  ,@IT_ID numeric(18,0)  
  ,@Date Datetime = null  
  ,@Amount numeric(18,2) = 0.0  
  ,@Detail_1 varchar(Max) = ''  
  ,@Detail_2 varchar(Max) = ''  
  ,@Detail_3 varchar(Max) = ''  
  ,@Comments varchar(Max) = ''    
  ,@Op as tinyint = 0  
  ,@FileName varchar(200) = ''  
  ,@Tran_Id as numeric(18,0) = 0  
  ,@Child_1 as Numeric(4,0) = 0  
  ,@Child_2 as Numeric(4,0) = 0  
  ,@Medical80DDBType as Numeric(2,0) = 0  
  ,@field_name varchar(200) = ''  
  ,@Is_Compare varchar(50) = ''  --Added by Jaina 10-09-2020  
  ,@BankName	varchar(MAX)=''
AS  
BEGIN  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 Declare @Tr_id as numeric(18,0)  
 Set @Tr_id = 0  
   
 IF @Op = 0 -- 0 For HRA  
 BEGIN  
  Declare @MaxTranId as numeric(18,0)  
  Set @MaxTranId = 0  
    
  IF not exists(Select Tran_ID From T0110_IT_Emp_Details WITH (NOLOCK) where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND IT_ID = @IT_ID AND ISNULL(Date,'') = '' AND Amount = 0.00)  
   BEGIN  

     -- Insert   
    select @MaxTranId = Isnull(max(Tran_ID),0) + 1 From dbo.T0110_IT_Emp_Details WITH (NOLOCK)  
    INSERT INTO T0110_IT_Emp_Details (Tran_ID,Cmp_ID,Emp_ID,Financial_Year,IT_ID,[Date],System_Date,Change_Date,Amount,Detail_1,Detail_2,Detail_3,Comments,Is_Compare_flag,BankName)  
    VALUES (@MaxTranId,@Cmp_ID,@Emp_ID,@Financial_Year,@IT_ID,@Date,GETDATE(),GETDATE(),@Amount,@Detail_1,@Detail_2,@Detail_3,@Comments,@Is_Compare,@BankName)  
   END  
  ELSE    
   BEGIN 

     -- Update  
    IF ISNULL(@Detail_1,'') <> '' AND ISNULL(@Detail_2,'') <> '' And ISNULL(@Detail_3,'') <> ''  
     BEGIN      
      Set @Tr_id = (Select Tran_ID From T0110_IT_Emp_Details WITH (NOLOCK) where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND IT_ID = @IT_ID AND ISNULL(Date,'') = '' AND Amount = 0.00)  
      Update T0110_IT_Emp_Details   
      SET Detail_1 = @Detail_1,  
       Detail_2 = @Detail_2,  
       Detail_3 = @Detail_3,  
       Comments = @Comments ,
	   BankName= @BankName
      where Tran_ID = @Tr_id  
     END  
    ELSE  
     BEGIN  
      Set @Tr_id = (Select Tran_ID From T0110_IT_Emp_Details WITH (NOLOCK) where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND IT_ID = @IT_ID AND ISNULL(Date,'') = '' AND Amount = 0.00)   
      Delete from T0110_IT_Emp_Details where Tran_ID = @Tr_id  
     END  
   END  
 END  
   
 IF @Op = 1 -- For Other Doc  
 BEGIN  
   
    -- Insert   
    select @MaxTranId = Isnull(max(Tran_ID),0) + 1 From dbo.T0110_IT_Emp_Details WITH (NOLOCK)  
    INSERT INTO T0110_IT_Emp_Details (Tran_ID,Cmp_ID,Emp_ID,Financial_Year,IT_ID,[Date],System_Date,Change_Date,Amount,Detail_1,Detail_2,Detail_3,Comments,[FileName],Is_Compare_Flag,BankName)  
    VALUES (@MaxTranId,@Cmp_ID,@Emp_ID,@Financial_Year,@IT_ID,@Date,GETDATE(),GETDATE(),@Amount,@Detail_1,@Detail_2,@Detail_3,@Comments,@FileName,@Is_Compare,@BankName)  
    
  --IF not exists(Select Tran_ID From T0110_IT_Emp_Details where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND Detail_1 = @Detail_1)  
  -- BEGIN  
  --   -- Insert   
  --  select @MaxTranId = Isnull(max(Tran_ID),0) + 1 From dbo.T0110_IT_Emp_Details  
  --  INSERT INTO T0110_IT_Emp_Details (Tran_ID,Cmp_ID,Emp_ID,Financial_Year,IT_ID,[Date],System_Date,Change_Date,Amount,Detail_1,Detail_2,Detail_3,Comments,[FileName])  
  --  VALUES (@MaxTranId,@Cmp_ID,@Emp_ID,@Financial_Year,@IT_ID,@Date,GETDATE(),GETDATE(),@Amount,@Detail_1,@Detail_2,@Detail_3,@Comments,@FileName)  
  -- END  
  --ELSE    
  -- BEGIN  
  --   -- Update  
  --  Set @Tr_id = (Select Tran_ID From T0110_IT_Emp_Details where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND Detail_1 = @Detail_1)  
         
  --  Update T0110_IT_Emp_Details   
  --  SET [FileName] = @FileName  
  --  where Tran_ID = @Tr_id  
  --END  
 END  
   
 IF @Op = 2 -- For Add Details  
 BEGIN  
     
   select @MaxTranId = Isnull(max(Tran_ID),0) + 1 From dbo.T0110_IT_Emp_Details WITH (NOLOCK)  
   INSERT INTO T0110_IT_Emp_Details (Tran_ID,Cmp_ID,Emp_ID,Financial_Year,IT_ID,[Date],System_Date,Change_Date,Amount,Detail_1,Detail_2,Detail_3,Comments,FileName,Is_Compare_Flag,BankName)  
   VALUES (@MaxTranId,@Cmp_ID,@Emp_ID,@Financial_Year,@IT_ID,@Date,GETDATE(),GETDATE(),@Amount,@Detail_1,@Detail_2,@Detail_3,@Comments,@FileName,@Is_Compare,@BankName)  
 END  
   
 IF  @Op = 3 -- For Add HL  
 BEGIN  
  IF not exists(Select Tran_ID From T0110_IT_Emp_Details WITH (NOLOCK) where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND IT_ID = @IT_ID AND Amount = 0.00)  
   BEGIN  
     -- Insert   
    select @MaxTranId = Isnull(max(Tran_ID),0) + 1 From dbo.T0110_IT_Emp_Details WITH (NOLOCK)  
    INSERT INTO T0110_IT_Emp_Details (Tran_ID,Cmp_ID,Emp_ID,Financial_Year,IT_ID,[Date],System_Date,Change_Date,Amount,Detail_1,Detail_2,Detail_3,Comments,Is_Compare_Flag,BankName)  
    VALUES (@MaxTranId,@Cmp_ID,@Emp_ID,@Financial_Year,@IT_ID,@Date,GETDATE(),GETDATE(),@Amount,@Detail_1,@Detail_2,@Detail_3,@Comments,@Is_Compare,@BankName)  
   END  
  ELSE    
   BEGIN  
     -- Update  
    Set @Tr_id = (Select Tran_ID From T0110_IT_Emp_Details WITH (NOLOCK) where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND IT_ID = @IT_ID AND Amount = 0.00)      
    Update T0110_IT_Emp_Details   
    SET [Date] = @Date,  
     Detail_1 = @Detail_1,  
     Detail_2 = @Detail_2,  
     Comments = @Comments,
	 BankName =@BankName
    where Tran_ID = @Tr_id  
   END  
 END  
  
 IF @Op = 4 --For Add Hostel Allowance Nilesh Patel on 14052019  
    Begin  
   IF not exists(Select Tran_ID From T0110_IT_Emp_Details WITH (NOLOCK) where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND IT_ID = @IT_ID)  
   BEGIN  
     -- Insert   
    select @MaxTranId = Isnull(max(Tran_ID),0) + 1 From dbo.T0110_IT_Emp_Details WITH (NOLOCK)  
    INSERT INTO T0110_IT_Emp_Details (Tran_ID,Cmp_ID,Emp_ID,Financial_Year,IT_ID,[Date],System_Date,Change_Date,Amount,Detail_1,Detail_2,Detail_3,Comments,Child_1,Child_2,Is_Compare_Flag,BankName)  
    VALUES (@MaxTranId,@Cmp_ID,@Emp_ID,@Financial_Year,@IT_ID,@Date,GETDATE(),GETDATE(),0,'','','','',@Child_1,@Child_2,@Is_Compare,@BankName)  
   END  
  ELSE    
   BEGIN  
     -- Update  
    Set @Tr_id = (Select Tran_ID From T0110_IT_Emp_Details WITH (NOLOCK) where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND IT_ID = @IT_ID AND Amount = 0.00)      
    Update T0110_IT_Emp_Details   
    SET   
      Child_1 = @Child_1,  
      Child_2 = @Child_2  
    where Tran_ID = @Tr_id  
   END  
    End  
      
   IF @Op = 5 --For Add Medical Expenss under 80DDB Nilesh Patel on 06062019  
    Begin  
   IF not exists(Select Tran_ID From T0110_IT_Emp_Details WITH (NOLOCK) where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND IT_ID = @IT_ID)  
   BEGIN  
     -- Insert   
    select @MaxTranId = Isnull(max(Tran_ID),0) + 1 From dbo.T0110_IT_Emp_Details WITH (NOLOCK)  
    INSERT INTO T0110_IT_Emp_Details (Tran_ID,Cmp_ID,Emp_ID,Financial_Year,IT_ID,[Date],System_Date,Change_Date,Amount,Detail_1,Detail_2,Detail_3,Comments,Child_1,Child_2,Medical80DDBType,Is_Compare_Flag,BankName)  
    VALUES (@MaxTranId,@Cmp_ID,@Emp_ID,@Financial_Year,@IT_ID,@Date,GETDATE(),GETDATE(),0,'','','','',0,0,@Medical80DDBType,@Is_Compare,@BankName)  
   END  
  ELSE    
   BEGIN  
    Set @Tr_id = (Select Tran_ID From T0110_IT_Emp_Details WITH (NOLOCK) where Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID AND Financial_Year = @Financial_Year AND IT_ID = @IT_ID AND Amount = 0.00)      
    Update T0110_IT_Emp_Details   
    SET Medical80DDBType = @Medical80DDBType  
    where Tran_ID = @Tr_id  
   END  
    End  
   
  IF @Op = 6 --For Let-Out Krushna   
    BEGIN  
   select @MaxTranId = Isnull(max(Tran_ID),0) + 1 From dbo.T0110_IT_Emp_Details WITH (NOLOCK)  
   INSERT INTO T0110_IT_Emp_Details (Tran_ID,Cmp_ID,Emp_ID,Financial_Year,IT_ID,[Date],System_Date,Change_Date,Amount,field_name,Is_Compare_Flag,BankName)  
   VALUES (@MaxTranId,@Cmp_ID,@Emp_ID,@Financial_Year,@IT_ID,@Date,GETDATE(),GETDATE(),@Amount,@field_name,@Is_Compare,@BankName)  
  END  
END  
  
  
