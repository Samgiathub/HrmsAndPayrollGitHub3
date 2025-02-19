  
  
-- =============================================  
-- Author:  Gadriwala Muslim   
-- Create date: <05/09/2014>  
-- Description: <Store Procedure for CompOff Leave of Tri_T0130_LEAVE_APPROVAL_DETAIL >  
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
-- =============================================  
CREATE PROCEDURE [dbo].[SP_Tri_T0130_LEAVE_APPROVAL_DETAIL_For_CompOff_Leave]  
 @Cmp_ID numeric,  
 @Emp_Id numeric,  
 @Emp_Code numeric(18,0),  
 @Leave_Approval_Id numeric,  
 @Approval_Status varchar(1),  
 @Leave_Id numeric,  
 @For_Date datetime,  
 @Leave_Used numeric(18,2),  
 @Leave_Asign_As varchar(20),  
 @Total_Leave_used numeric(18,2),  
 @A_From_Date datetime,  
 @A_To_date datetime,  
 @Is_Import int,  
 @M_Cancel_WO_HO tinyint,  
 @Half_Leave_Date datetime,  
 @Leave_negative_Allow tinyint,  
 @Leave_Paid_Unpaid varchar(1),  
 @Apply_Hourly numeric,  
 @is_backdated_application numeric,  
 @Leave_CompOFf_Dates varchar(max),  
 @Leave_Short_Name varchar(25) = 'COMP' --Added by Sumit on 29092016  
AS  
  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 BEGIN  
    
    
  CREATE table #Leave_date    
  (     
   for_date datetime    
  )  
  -- Added by Gadriwala Muslim 03092014 - Start  
  Create Table #Leave_CompOff_Approved  
  (  
   --Leave_Date datetime,  
   Leave_Date varchar(50),-- Update datatype from datetime to Varchar(50) by yogesh  on 07122023
   Leave_Period numeric(18,2)  
  )  
  
  -- Added by Gadriwala Muslim 03092014 - End   
  declare @Last_Leave_Closing as numeric(18,2)   
  Declare @Leave_Tran_ID as numeric       
  Declare @Chg_Tran_Id numeric      
  Declare @For_Date_Cur Datetime    
  Declare @Pre_Closing numeric(18,2)    
  Declare @Leave_Posting numeric(18,2)  
  
  If @leave_Id > 0      
   begin    
    if  @Approval_Status = 'A'    
     Begin    
      set @For_Date= @A_From_Date    
        
        
      insert into #Leave_date (for_date)    
      exec Calculate_Leave_End_Date @Cmp_ID,@Emp_Id,@Leave_Id,@For_Date,@Total_Leave_used,'O',@M_Cancel_WO_HO    
        
      declare curAsgnLeaveDate cursor for    
      select for_date from #leave_date    
        
      open curAsgnLeaveDate     
      fetch next from curAsgnLeaveDate into @For_date    
      while @@fetch_status = 0    
       begin    
        if @Total_leave_used = 0.5    
         begin              
          if @For_Date = @Half_Leave_Date  
           SET @Leave_used = 0.5  
          --Comment by Jaina 20-01-2017 ( When same date 2 leave take as 0.5 day that time wrong leave used count.)  
          --if exists(select Emp_ID from T0140_LEAVE_TRANSACTION where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and  CompOff_Used = 0.5 )    
          --begin    
          -- set @Leave_used = 1              
          -- --set @Leave_used = 0.5  jaina  
          --end    
          --Else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and  CompOff_Used = 0.25 )    
          --begin    
          -- set @Leave_used = 0.75                
          --end     
          --Else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and CompOff_Used = 0.75 )    
          if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and CompOff_Used = 0.75 )    
           begin    
            RAISERROR ('Already leave applied for Date ' , 16, 2)     
           end     
          --else    
          --begin    
          -- set @Leave_used = 0.5    
          --end    
         end    
        else if @Total_leave_used = 0.25    
         begin              
          --Comment by Jaina 20-01-2017   
          --if exists(select Emp_ID from T0140_LEAVE_TRANSACTION where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and  CompOff_Used = 0.75 )    
          --begin    
          -- set @Leave_used = 1              
          --end    
          --else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and  CompOff_Used = 0.50  )    
          --begin    
          -- set @Leave_used = 0.75                
          --end    
          --else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and CompOff_Used = 0.25 )    
          --begin    
          -- set @Leave_used = 0.50                
          --end    
          --else    
          --begin    
          -- set @Leave_used = 0.25    
          --end    
          if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and CompOff_Used = 1 )    
           begin    
            RAISERROR ('Already leave applied for Date ' , 16, 2)     
           end   
         end    
        else if @Total_leave_used = 0.75    
         begin              
          if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and CompOff_Used = 0.75 )    
           begin    
            RAISERROR ('Already leave applied for Date ' , 16, 2)                
           end    
          else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and  CompOff_Used = 0.50  )    
           begin    
            RAISERROR ('Already leave applied for Date ' , 16, 2)               
           end    
          --Comment by Jaina 20-01-2017   
          --else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and  CompOff_Used = 0.25  )    
          --begin    
          -- set @Leave_used = 1    
          --end    
          --else    
          --begin    
          -- set @Leave_used = 0.75    
          --end    
         end    
        else    
         begin    
          If @For_Date = @Half_Leave_Date    
           Begin    
            set @Leave_used = 0.5    
           End    
          Else    
           Begin    
            if @Apply_Hourly = 0  
             set @Leave_used = 1    
            else  
             set @Leave_Used = @Total_Leave_used  
           End         
          set @Total_Leave_Used = @Total_leave_used - @Leave_Used                   
          end    
            
          
         select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK)   
            
         Declare @temp_Leave_Used numeric(18,2)            
              
        if exists(select For_date from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where For_date = @For_date and leave_Id = @leave_Id      
            and Cmp_ID = @Cmp_ID and emp_id = @emp_id)    
         begin    
          Select @temp_Leave_Used = CompOff_Used   
          from T0140_LEAVE_TRANSACTION WITH (NOLOCK)     
          where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID    
            and emp_Id = @emp_Id    
          Begin    
           If @is_backdated_application =  0  
            BEGIN  
             UPDATE T0140_LEAVE_TRANSACTION   
             SET  CompOff_Used = CompOff_Used + @Leave_Used    
             WHERE Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID  and emp_Id = @emp_Id    
            END  
           ELSE  
            BEGIN  
             UPDATE T0140_LEAVE_TRANSACTION   
             SET  CompOff_Used = 0,Back_Dated_Leave =  Back_Dated_Leave + @Leave_Used   
             WHERE Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id    
            END  
          End    
      
       End    
      else    
       begin     
            
         IF ISNULL(@is_backdated_application,0) = 0  
         BEGIN  
       
          insert into T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,CompOff_used,Leave_Tran_ID,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing)    
          values(@emp_id,@leave_Id,@Cmp_ID,@for_Date,@Leave_Used,@Leave_Tran_ID,0,0,0,0)                      
         END  
        ELSe  
         BEGIN  
       
          insert into T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,CompOff_used,Leave_Tran_ID,Back_Dated_Leave,Leave_Opening,Leave_Credit,Leave_Used,Leave_Closing)    
          values(@emp_id,@leave_Id,@Cmp_ID,@for_Date,0,@Leave_Tran_ID,@Leave_Used,0,0,0,0)                      
         END              
       end    
           
      fetch next from curAsgnLeaveDate into @For_date    
     end    
    CLOSE curAsgnLeaveDate    
    DEALLOCATE curAsgnLeaveDate     
  
    -- Gadriwala Muslim Added 03092014 - Start    
        
    Insert into #Leave_CompOff_Approved(Leave_date,Leave_Period)  
    select  Left(DATA,CHARINDEX(';',DATA)-1),SUBSTRING(DATA,CHARINDEX(';',DATA)+1,10)   
    from dbo.SPlit(@Leave_CompOFf_Dates,'#') where Data <> ''  
    
   
    if @Leave_Short_Name = 'COPH'  
       BEGIN  
        UPDATE T0140_LEAVE_TRANSACTION   
      SET  COMPOFF_DEBIT = COMPOFF_DEBIT + LA.LEAVE_PERIOD,  
        COMPOFF_BALANCE = COMPOFF_BALANCE - LA.LEAVE_PERIOD   
      FROM T0140_LEAVE_TRANSACTION GOT   
        INNER JOIN #LEAVE_COMPOFF_APPROVED LA ON LEAVE_DATE = FOR_DATE  
        INNER JOIN T0040_LEAVE_MASTER LM ON LM.LEAVE_ID = GOT.LEAVE_ID AND ISNULL(LM.DEFAULT_SHORT_NAME,'') = 'COPH'  
      WHERE GOT.EMP_ID = @EMP_ID AND GOT.CMP_ID = @CMP_ID AND COMOFF_FLAG = 1 AND (GOT.COMPOFF_CREDIT > 0 OR GOT.COMPOFF_DEBIT > 0 OR GOT.COMPOFF_BALANCE > 0 )  
       END  
      if @Leave_Short_Name = 'COND'  
       begin  
         UPDATE T0140_LEAVE_TRANSACTION SET COMPOFF_DEBIT = COMPOFF_DEBIT + LA.LEAVE_PERIOD,  
      COMPOFF_BALANCE = COMPOFF_BALANCE - LA.LEAVE_PERIOD FROM T0140_LEAVE_TRANSACTION GOT   
      INNER JOIN #LEAVE_COMPOFF_APPROVED LA ON LEAVE_DATE = FOR_DATE  
      INNER JOIN T0040_LEAVE_MASTER LM ON LM.LEAVE_ID = GOT.LEAVE_ID AND ISNULL(LM.DEFAULT_SHORT_NAME,'') = 'COND'  
      WHERE GOT.EMP_ID = @EMP_ID AND GOT.CMP_ID = @CMP_ID AND COMOFF_FLAG = 1  
       end  
      else  
       begin  
        print 'aaa'  
      Update T0140_LEAVE_TRANSACTION set CompOff_Debit = Compoff_Debit + LA.Leave_Period,  
      CompOff_balance = CompOff_balance - LA.Leave_Period from T0140_LEAVE_TRANSACTION GOT   
      inner join #Leave_CompOff_Approved LA on Leave_Date = For_Date  
      inner join T0040_LEAVE_MASTER LM on LM.Leave_ID = GOT.Leave_ID and isnull(LM.Default_Short_Name,'') = 'COMP'  
      --Where GOT.Emp_ID = @Emp_Id and GOT.Cmp_ID = @cmp_ID   
      Where GOT.Emp_ID = @Emp_Id and GOT.Cmp_ID = @cmp_ID and Comoff_Flag = 1  
      --Leave_ID = (select Leave_ID from T0040_LEAVE_MASTER where Default_Short_Name = 'COMP' and Cmp_ID = @Cmp_ID) and Comoff_Flag = 1  
     end   
      
             
   END   
   END    
   --end     
END  
  