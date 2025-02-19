
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Tri_T0130_LEAVE_APPROVAL_DETAIL_For_Regular_Leave]
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
@Half_Payment tinyint = 0
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
        
CREATE TABLE #Leave_date  
(   
 for_date datetime  
)
declare @Last_Leave_Closing as numeric(18,2) 
Declare @Leave_Tran_ID as numeric     
Declare @Chg_Tran_Id numeric    
Declare @For_Date_Cur Datetime  
  Declare @Pre_Closing numeric(18,2)  
  Declare @Leave_Posting numeric(18,2)
  
  Declare @Half_Payment_Days Numeric(18,8)
  Set @Half_Payment_Days=0
  
  -- Added by rohit on 21012015 
 Declare @leave_Negative_max_limit as numeric(18,3)
 select @leave_Negative_max_limit = isnull(leave_negative_max_limit,0) from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID=@Leave_Id and Cmp_ID=@Cmp_ID 
 -- Ended By rohit on 21012015
  
  

  If @leave_Id > 0    
   begin  
    if  @Approval_Status = 'A'  
     Begin  
      set @For_Date= @A_From_Date  
       
      select @Last_Leave_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
               where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION WITH (NOLOCK)  
                 where for_date < @For_date  
                and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
                and Cmp_ID = @Cmp_ID  
                and leave_id = @leave_Id and emp_Id = @emp_Id  

           if @Last_Leave_Closing is null   
            set  @Last_Leave_Closing = 0  
            
      insert into #Leave_date (for_date)  
      exec Calculate_Leave_End_Date @Cmp_ID,@Emp_Id,@Leave_Id,@For_Date,@Total_Leave_used,'O',@M_Cancel_WO_HO  

      declare curAsgnLeaveDate cursor for  
       select for_date from #leave_date  
      open curAsgnLeaveDate   
      fetch next from curAsgnLeaveDate into @For_date  
      while @@fetch_status = 0  
		begin  
      --while @For_Date <= @A_To_Date and @Total_leave_used > 0  
      -- Begin  
      
        if @Total_leave_used = 0.5  
        begin            
			if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and Leave_Used=0.5 )  
			begin  
				set @Leave_used = 1              
			end  
			Else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and Leave_Used=0.25)  
			begin  
				set @Leave_used = 0.75              
			end   
			Else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and Leave_Used=0.75 )  
			begin  
	            RAISERROR ('Already leave applied for Date ' , 16, 2)   
		    end   
			else  
			begin  
				set @Leave_used = 0.5  
			end  
		end  
        else if @Total_leave_used = 0.25  
        begin            
			if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and Leave_Used=0.75)  
			begin  
				set @Leave_used = 1              
			end  
			else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and Leave_Used=0.50 )  
			begin  
				set @Leave_used = 0.75              
			end  
			else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and Leave_Used=0.25 )  
			begin  
				set @Leave_used = 0.50              
			end  
			else  
			begin  
				set @Leave_used = 0.25  
			end  
		end  
        else if @Total_leave_used = 0.75  
        begin            
			if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and Leave_Used=0.75 )  
			begin  
				RAISERROR ('Already leave applied for Date ' , 16, 2)              
			end  
			else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and Leave_Used=0.50 )  
			begin  
				RAISERROR ('Already leave applied for Date ' , 16, 2)             
			end  
			else if exists(select Emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Cmp_ID = @Cmp_ID and leave_id = @leave_Id and emp_Id = @emp_Id and for_date=@For_date and Leave_Used=0.25 )  
			begin  
				set @Leave_used = 1  
			end  
			else  
			begin  
				set @Leave_used = 0.75  
			end  
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
			If @Half_Payment = 1 
				Set @Half_Payment_Days = @Leave_Used
			
            set @Total_Leave_Used = @Total_leave_used - @Leave_Used  - @Half_Payment_Days              
            
         end  
         
		 select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
          
         Declare @temp_Leave_Used numeric(18,2)          
          
			--Added by Hardik 16/12/2011  
		select @Last_Leave_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
              where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION WITH (NOLOCK)  
                where for_date < @For_date  
               and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
               and Cmp_ID = @Cmp_ID  
               and leave_id = @leave_Id and emp_Id = @emp_Id  
            
        if exists(select For_date from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where For_date = @For_date and leave_Id = @leave_Id    
          and Cmp_ID = @Cmp_ID and emp_id = @emp_id)  
          begin  
           Select @temp_Leave_Used = Leave_Used from T0140_LEAVE_TRANSACTION WITH (NOLOCK)  
           where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID  
           and emp_Id = @emp_Id  
              Begin  
					--Added condition by hardik 19/12/2014 for Vital Soft, Half payment and full payment
					--If @Half_Payment = 1 
					--	Set @Leave_Used = @Leave_Used * 2 
					
              -- Changed By Ali 25042014 -- Start
			  If @is_backdated_application =  0
				BEGIN
				
				  update T0140_LEAVE_TRANSACTION set  
				   Leave_Used =@Leave_Used 
				   ,Leave_Closing = Leave_Opening + isnull(Leave_Credit,0) - @Leave_Used  - Isnull(Leave_Encash_Days,0) - Isnull(@Half_Payment_Days,0) - ISNULL(CF_Laps_Days,0)
				   ,Half_Payment_Days = @Half_Payment_Days
				  where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID  
				   and emp_Id = @emp_Id  
				   
				END
              ELSe
				BEGIN
					
					 update T0140_LEAVE_TRANSACTION set  
				    Leave_Used = 0
				   ,Back_Dated_Leave = @Leave_Used
				   ,Leave_Closing = Leave_Opening + isnull(Leave_Credit,0) - @Leave_Used - Isnull(Leave_Encash_Days,0) - Isnull(@Half_Payment_Days,0) - ISNULL(CF_Laps_Days,0)
				   ,Half_Payment_Days=@Half_Payment_Days
					where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID  
				   and emp_Id = @emp_Id  
				END
              -- Changed By Ali 25042014 -- Start   
                 
              set @Last_Leave_Closing = (select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Leave_Id = @Leave_Id   
                   and for_date = @For_Date and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)  
              End  
				
           End  
         else  
          begin   
              if isnull(@Last_Leave_Closing,0) = 0 and @Leave_negative_Allow = 0  
               begin   
				
                Raiserror('@@Leave Balance Negative, Negative Not Allowed@@',16,2)  
             return   
               end   
               
                 -- Added by Rohit on 21012015
			 if isnull(@leave_Negative_max_limit,0) <> 0
			 begin
				 if isnull(@Last_Leave_Closing,0) < (@leave_Negative_max_limit * (-1))  and @Leave_negative_Allow = 1   
				   begin   
					Raiserror('@@Leave Balance Negative , Negative Not Allowed beyond max limit@@',16,2)  
					return   
				   end   
			 end
			 -- Ended by rohit on 21012015
           
             IF ISNULL(@is_backdated_application,0) = 0
				BEGIN
					
					insert into T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,  
					Leave_Closing,Leave_Credit,Leave_Tran_ID,Half_Payment_Days)  
					values(@emp_id,@leave_Id,@Cmp_ID,@for_Date,@last_Leave_Closing,@Leave_Used  
					,@last_Leave_Closing - @Leave_Used - @Half_Payment_Days,0,@Leave_Tran_ID,@Half_Payment_Days)                    
				END
			ELSe
				BEGIN
					
					insert into T0140_LEAVE_TRANSACTION(emp_id,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,  
					Leave_Closing,Leave_Credit,Leave_Tran_ID,Back_Dated_Leave,Half_Payment_Days)  
					values(@emp_id,@leave_Id,@Cmp_ID,@for_Date,@last_Leave_Closing,0  
					,@last_Leave_Closing - @Leave_Used - @Half_Payment_Days,0,@Leave_Tran_ID,@Leave_Used,@Half_Payment_Days)                    
				END            
			-- Added By Ali 25042014 -- End
          end  
         
       fetch next from curAsgnLeaveDate into @For_date  
      end  
     close curAsgnLeaveDate  
     deallocate curAsgnLeaveDate   
      
        set @For_Date= @A_From_Date  
                      
        select @Pre_Closing = isnull(Leave_Closing,0),@Leave_Posting = Leave_Posting  -- -Added Leave Posting by Hardik 10/10/2019 for Cliantha as they have issue after reset balance, it will update next dates balances
		from T0140_LEAVE_TRANSACTION WITH (NOLOCK) 
            where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where for_date <= @For_date  
                 and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
             and Cmp_ID = @Cmp_ID  
             and leave_id = @leave_Id and emp_Id = @emp_Id  
                           
         
        if @Pre_Closing is null  
         set @Pre_Closing = 0              
  
         
        declare cur1 cursor for   
         Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK) where leave_id = @leave_Id and emp_id = @emp_id   
         and Cmp_ID = @Cmp_ID and for_date > @For_date order by for_date  
        open cur1  
        fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
        while @@fetch_status = 0  
        begin  
       
         If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @For_Date_Cur And Leave_Op_Days > 0)  
			OR @Leave_Posting IS NOT NULL   --Added by Jaina 16-12-2017
          Begin  
			--Goto c;  --Comment by Jaina 16-12-2017 (After CF Leave balance wrong set) 
			BREAK
          End  
          
         Select @Leave_Posting = Leave_Posting from dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK) where leave_tran_id = @Chg_Tran_Id 
          begin  
            Begin  
  
             update dbo.T0140_LEAVE_TRANSACTION set   
               Leave_Opening = @Pre_Closing,  
               Leave_Closing = @Pre_Closing + isnull(Leave_Credit,0) - isnull(Leave_Used,0) - isnull(Leave_Encash_Days,0) - ISNULL(Back_Dated_Leave,0) - Isnull(Half_Payment_Days,0)- Isnull(CF_Laps_Days,0)
              where leave_tran_id = @Chg_Tran_Id  
          --C:     
    set @Pre_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION WITH (NOLOCK) where leave_tran_id = @Chg_Tran_Id),0)  
            End  
          end                  
          
         fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
        end  
          
        close cur1  
        deallocate cur1          
        if @Leave_negative_Allow = 0   
         begin  
            
          if Exists(select emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID =@emp_ID and Leave_ID =@Leave_ID and For_Date >=@A_To_date and Leave_Closing < 0)  
           begin  
				--select * from T0140_LEAVE_TRANSACTION where Emp_ID =@emp_ID and Leave_ID =@Leave_ID and For_Date >=@A_To_date and Leave_Closing < 0    
              if @Is_Import = 1  
				begin  
					Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_Code,'Leave Balance Negative Not Allowed',NULL,'Insufficient Balance to approve the leave',GetDate(),'Leave Approval','')  
				end  
              else  
				begin  
					
					Raiserror('@@Leave Balance Negative, Negative Not Allowed@@',16,2)  
					return   
				end  
           end   
         end  
          -- Added by Rohit on 21012015
			 if isnull(@leave_Negative_max_limit,0) <> 0 and @Leave_negative_Allow = 1
			 begin
			 
			if Exists(select emp_ID from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID =@emp_ID and Leave_ID =@Leave_ID and For_Date >=@A_To_date and Leave_Closing < (@leave_Negative_max_limit * (-1)))  
			   begin  
		           
				  if @Is_Import = 1  
					begin  
					Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Emp_Code,'Leave Balance Negative Not Allowed',NULL,'Insufficient Balance to approve the leave',GetDate(),'Leave Approval','')  
					end  
					else  
					begin  
					Raiserror('@@Leave Balance Negative, Negative Not Allowed beyond max limit@@',16,2)  
					return   
					end  
				End
			 				
			 end
		-- Ended by rohit on 21012015
	
           
           
      End 
   end  
   --end   
END


