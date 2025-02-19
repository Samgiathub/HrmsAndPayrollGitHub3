CREATE TABLE [dbo].[T0160_late_Approval] (
    [Late_Tran_ID]           NUMERIC (18)    NOT NULL,
    [Cmp_ID]                 NUMERIC (18)    NOT NULL,
    [Emp_ID]                 NUMERIC (18)    NOT NULL,
    [For_Date]               DATETIME        NOT NULL,
    [Total_late]             NUMERIC (18, 2) NULL,
    [Late_Cal_day]           NUMERIC (18, 2) NOT NULL,
    [Leave_ID]               NUMERIC (18)    NOT NULL,
    [Month_Date]             DATETIME        NULL,
    [Approval_Type]          NVARCHAR (10)   CONSTRAINT [DF_T0160_late_Approval_Status] DEFAULT ('L') NOT NULL,
    [Leave_Balance]          NUMERIC (18, 2) CONSTRAINT [DF_T0160_late_Approval_Leave_Balance] DEFAULT ((0)) NULL,
    [Total_Penalty_Days]     NUMERIC (18, 2) CONSTRAINT [DF_T0160_late_Approval_Total_Penalty_Days] DEFAULT ((0)) NULL,
    [Penalty_days_to_Adjust] NUMERIC (18, 2) CONSTRAINT [DF_T0160_late_Approval_Penalty_days_to_Adjust] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0160_late_Approval] PRIMARY KEY CLUSTERED ([Late_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0160_late_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0160_late_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO





CREATE TRIGGER [DBO].[Tri_T0160_late_Approval_UPDATE]
ON [dbo].[T0160_late_Approval] 
FOR UPDATE 
AS
	Declare @Leave_ID	numeric 
	Declare @Emp_ID		numeric 
	Declare @For_Date	Datetime 
	Declare @cmp_ID		numeric 
    Declare @Late_Sal_Dedu_Days numeric(18,2)
	Declare @Last_Leave_Closing numeric(12,1)
	Declare @Leave_Tran_ID	numeric 
	
	
	select @leave_ID = LEave_ID ,@Emp_ID = Emp_ID ,@Late_Sal_Dedu_Days =Late_cal_day
				,@For_Date =For_date ,@Cmp_ID =cmp_ID   From inserted
				
				
				
				declare @old_leave_adj_L_mark numeric(18,2)
				
				select @old_leave_adj_L_mark = leave_adj_L_mark from T0140_LEAVE_TRANSACTION
				where leave_id = @leave_Id and emp_id = @emp_id and for_date = @for_date 
				and Cmp_ID = @Cmp_ID
				
								
				update T0140_LEAVE_TRANSACTION set 
					Leave_Closing = (Leave_Closing + @old_leave_adj_L_mark)  - @Late_Sal_Dedu_Days,
					Leave_adj_L_Mark = @Late_Sal_Dedu_Days 
				where leave_id = @leave_Id and emp_id = @emp_id and for_date = @for_date 
				and Cmp_ID = @Cmp_ID	
						
			/*
				update T0140_LEAVE_TRANSACTION set 
						Leave_Closing = Leave_Closing  - @Late_Sal_Dedu_Days 
				where leave_id = @leave_Id and emp_id = @emp_id and for_date > @for_date 
				and Cmp_ID = @Cmp_ID
			*/
/*Updating Leave Balance After Date*/

DECLARE @Pre_Closing numeric(18,2)  
DECLARE @Leave_Posting numeric(18,2)  
DECLARE @Chg_Tran_Id numeric    
declare @For_Date_Cur datetime

select @Pre_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION  
where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION where for_date <= @For_date  
and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
and Cmp_ID = @Cmp_ID  
and leave_id = @leave_Id and emp_Id = @emp_Id  

 if @Pre_Closing is null  
	set @Pre_Closing = 0  

declare cur1 cursor for   
	Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id   
	and Cmp_ID = @Cmp_ID and for_date > @For_date order by for_date  
open cur1  
fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
	while @@fetch_status = 0  
		begin  

			If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @For_Date_Cur And Leave_Op_Days > 0)  
			Begin  
					Goto E1;  
			End  
			--Select @Leave_Posting = isnull(Leave_Posting,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id  				  
			update dbo.T0140_LEAVE_TRANSACTION set   
			Leave_Opening = @Pre_Closing,  
			Leave_Closing = @Pre_Closing + isnull(Leave_Credit,0) - isnull(Leave_Used,0) - isnull(Leave_Encash_Days,0) - ISNULL(Back_Dated_Leave,0) - Isnull(Half_Payment_Days,0)-Isnull(Leave_Adj_L_mark,0)
			where leave_tran_id = @Chg_Tran_Id  

E1:    
			set @Pre_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id),0)  
				

			fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
		end  
close cur1  
deallocate cur1   				
				
				



GO


CREATE TRIGGER [DBO].[Tri_T0160_late_Approval]    
ON [dbo].[T0160_late_Approval]    
FOR INSERT, DELETE      
AS    
        
 Declare @Leave_ID numeric     
 Declare @Emp_ID  numeric     
 Declare @For_Date Datetime     
 Declare @cmp_ID  numeric     
 Declare @Late_Sal_Dedu_Days numeric(18,2)    
 Declare @Last_Leave_Closing numeric(12,2)    
 Declare @Leave_Tran_ID numeric     
     
    
 IF UPDATE (Late_Tran_ID)     
  Begin    
      
     select @leave_ID = LEave_ID ,@Emp_ID = Emp_ID ,@Late_Sal_Dedu_Days = Late_Cal_Day    
      ,@For_Date =For_date ,@Cmp_ID =cmp_ID From inserted     
       

     IF Exists (SELECT isnull(Leave_Tran_ID,0) from T0140_LEAVE_TRANSACTION where For_Date = @For_Date AND Leave_ID = @Leave_ID and emp_Id = @emp_Id)    
      begin    
                      
       Update T0140_LEAVE_TRANSACTION set     
        Leave_Closing = Isnull(Leave_Closing,0) - Isnull(@Late_Sal_Dedu_Days,0),   
        Leave_Adj_L_mark = isnull(@Late_Sal_Dedu_Days,0)  --Leave_Adj_L_mark + @Late_Sal_Dedu_Days    
        --Commented and Added isnull by Sumit 07062016
       where Leave_Id = @Leave_Id and for_date = @For_Date and Cmp_ID = @Cmp_ID    
       and emp_Id = @emp_Id    
    
    
       update T0140_LEAVE_TRANSACTION set     
        Leave_Closing = Isnull(Leave_Closing,0) - Isnull(@Late_Sal_Dedu_Days,0)
       where Leave_Id = @Leave_Id and for_date > @For_Date and Cmp_ID = @Cmp_ID    
       and emp_Id = @emp_Id         
      end    
     else    
      begin    
       declare @Leave_Closing_Last numeric(18,2)    
       --declare @Leave_Tran_ID numeric(18,0)    
       set @Leave_Closing_Last = 0    
       --set @Leave_Tran_ID = 0    
           
       select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) +1 From T0140_LEAVE_TRANSACTION    
          
       SELECT @Leave_Closing_Last = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION   
           where For_Date = (select max(For_Date) from T0140_LEAVE_TRANSACTION where For_Date <=@For_Date   
                             and emp_id = @emp_id and leave_id = @leave_id and cmp_Id = @cmp_Id)   
           AND Leave_ID = @Leave_ID and emp_Id = @emp_Id    
           
       INSERT INTO T0140_LEAVE_TRANSACTION    
        (Leave_Tran_ID ,Cmp_ID, Leave_ID, Emp_ID, For_Date, Leave_Opening, Leave_Credit, Leave_Used, Leave_Closing, Leave_Posting, Leave_Adj_L_Mark, Leave_Cancel,     
        Eff_In_Salary, Leave_Encash_Days, Comoff_Flag)    
       VALUES     (@Leave_Tran_ID,@cmp_id,@Leave_ID ,@Emp_ID,@For_Date,@Leave_Closing_Last,0,0,(isnull(@Leave_Closing_Last,0) - isnull(@Late_Sal_Dedu_Days,0)),NULL,@Late_Sal_Dedu_Days,NULL,NULL,0,0)            
      end    
  End     
      
 Else     
     
  Begin    
       
   Select @leave_ID = LEave_ID ,@Emp_ID = Emp_ID ,@Late_Sal_Dedu_Days = Sum(Late_Cal_Day)    
    ,@For_Date =For_date ,@Cmp_ID =cmp_ID From Deleted  group by  Emp_ID, For_Date,leave_ID,cmp_id
        
        
    Update T0140_LEAVE_TRANSACTION set     
     Leave_Closing = Isnull(Leave_Closing,0)   +  Isnull(Leave_Adj_L_mark,0),    
     Leave_Adj_L_mark  = Isnull(Leave_Adj_L_mark,0) - @Late_Sal_Dedu_Days    
    where leave_id = @leave_Id and emp_id = @emp_id and for_date = @for_date     
    and Cmp_ID = @Cmp_ID     
        
         
    Update T0140_LEAVE_TRANSACTION set     
      Leave_Closing = Isnull(Leave_Closing,0)   +  Isnull(@Late_Sal_Dedu_Days,0)
    where leave_id = @leave_Id and emp_id = @emp_id and for_date > @for_date     
    and Cmp_ID = @Cmp_ID     
        
  End    
    

/*Updating Leave Balance After Date*/

DECLARE @Pre_Closing numeric(18,2)  
DECLARE @Leave_Posting numeric(18,2)  
DECLARE @Chg_Tran_Id numeric    
declare @For_Date_Cur datetime

select @Pre_Closing = isnull(Leave_Closing,0) from T0140_LEAVE_TRANSACTION  
where for_date = (select max(for_date) from T0140_LEAVE_TRANSACTION where for_date <= @For_date  
and leave_Id = @leave_id and Cmp_ID = @Cmp_ID and emp_Id = @emp_Id)   
and Cmp_ID = @Cmp_ID  
and leave_id = @leave_Id and emp_Id = @emp_Id  

 if @Pre_Closing is null  
	set @Pre_Closing = 0  

declare cur1 cursor for   
	Select leave_tran_id,For_Date from dbo.T0140_LEAVE_TRANSACTION where leave_id = @leave_Id and emp_id = @emp_id   
	and Cmp_ID = @Cmp_ID and for_date > @For_date order by for_date  
open cur1  
fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
	while @@fetch_status = 0  
		begin  

			If exists(Select Leave_Op_Id From T0095_LEAVE_OPENING Where Cmp_ID = @Cmp_ID And Emp_Id = @Emp_Id And Leave_ID = @Leave_Id And For_Date = @For_Date_Cur And Leave_Op_Days > 0)  
			Begin  
					Goto E1;  
			End  
			--Select @Leave_Posting = isnull(Leave_Posting,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id  				  
			update dbo.T0140_LEAVE_TRANSACTION set   
			Leave_Opening = @Pre_Closing,  
			Leave_Closing = @Pre_Closing + isnull(Leave_Credit,0) - isnull(Leave_Used,0) - isnull(Leave_Encash_Days,0) - ISNULL(Back_Dated_Leave,0) - Isnull(Half_Payment_Days,0)-Isnull(Leave_Adj_L_mark,0)
			where leave_tran_id = @Chg_Tran_Id  

E1:    
			set @Pre_Closing = isnull((select isnull(Leave_Closing,0) from dbo.T0140_LEAVE_TRANSACTION where leave_tran_id = @Chg_Tran_Id),0)  
				

			fetch next from cur1 into @Chg_Tran_Id,@For_Date_Cur  
		end  
close cur1  
deallocate cur1      
    
    


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'L - late , E - Early , LE - Late n Early', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'T0160_late_Approval', @level2type = N'COLUMN', @level2name = N'Approval_Type';

