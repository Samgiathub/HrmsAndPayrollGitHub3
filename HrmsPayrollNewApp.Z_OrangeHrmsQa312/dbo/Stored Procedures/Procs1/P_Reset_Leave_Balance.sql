
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Reset_Leave_Balance]
@Cmp_ID as numeric(18,0),
@Leave_id as numeric(18,0),
@emp_id as numeric(18,0),
@For_Date as datetime,
@CF_To_Date as datetime,
@LEAVE_RESET  Bit Output  --Added By Jimit 18042019
as
begin
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
--set @For_Date = dateadd(dd,1,@CF_To_Date)

declare @Type_id as numeric(18,0)
Declare @increment_id as numeric(18,0)
Declare @Duration as varchar(100)
declare @Reset_Months as numeric(18,0)
Declare @Reset_Month_String nvarchar(500)
Declare @CF_Effective_Date datetime
Declare @bln_Flag as varchar(3) 
Declare @Leave_Tran_ID as numeric(18,0)
declare @Leave_Closing as numeric(18,2)
declare @Default_Short_Name as varchar(50)
Declare @Month_End_Date as datetime
Declare @Date as datetime


set @Type_id = 0
Set @increment_id = 0
Set @Duration =''
Set @Reset_Months = 0
Set @Reset_Month_String = ''
Set @CF_Effective_Date = null
Set @bln_Flag ='NO'
Set @Leave_Tran_ID = 0
Set @Leave_Closing = 0
Set @Default_Short_Name = ''

set @Month_End_Date = @CF_To_Date
set @Default_Short_Name = ''

SET @LEAVE_RESET =0

select top 1 @increment_id =increment_id, @Type_id = type_id  from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=@emp_id order by increment_id desc 

select @Default_Short_Name = Default_Short_Name  from T0040_LEAVE_MASTER WITH (NOLOCK) where Leave_ID=@Leave_id

--select * from T0050_CF_EMP_TYPE_DETAIL where Cmp_ID = @Cmp_ID and Leave_ID = @Leave_id

select @Duration = CET.Duration, @Reset_Months=cet.Reset_Months, @CF_Effective_Date= cet.Effective_Date, @Reset_Month_String=Reset_Month_String 
from T0050_CF_EMP_TYPE_DETAIL CET WITH (NOLOCK) 
inner join 
(select MAX(Effective_Date) as effective_date,Leave_ID,TYPE_ID from T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK) where Leave_ID = @Leave_id and TYPE_ID = @Type_id 
group by Leave_ID,TYPE_ID) as CETD 
on CET.Leave_ID = CETD.Leave_ID and  CET.type_id = CETD.Type_ID and CET.Effective_Date= CETD.effective_date 
where CET.Leave_ID = @Leave_id and CET.Type_ID = @Type_id


if CHARINDEX('#', @Reset_Month_String) <> 1 AND LEN(@Reset_Month_String) > 0
	SET @Reset_Month_String = '#' + @Reset_Month_String  + '#'

	SELECT @Leave_Closing = LEAVE_CLOSING FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN    
			  (
					SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION  WITH (NOLOCK) 
					WHERE EMP_ID = @EMP_ID AND FOR_DATE <= @Month_End_Date GROUP BY EMP_ID,LEAVE_ID) Q 
					ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND LT.FOR_DATE = Q.FOR_DATE Inner join
				T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID = LT.Leave_ID and isnull(LM.Default_Short_Name,'') <> 'COMP'      
			where Lt.LeavE_ID =@LEave_ID   

	If @Leave_Closing is null
				set @Leave_Closing = 0

	
	

	If @Duration = 'Yearly'
	Begin
		
		if isnull(@Reset_Months,0) > 0 
			begin
							
							If @Reset_Months <= 12
								Begin
								
									If CHARINDEX('#' + cast(month(@For_Date) as varchar) + '#',@Reset_Month_String) > 0
										begin
											if exists(Select Leave_Tran_Id from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID and isnull(LM.Default_Short_Name,'') <> 'COMP'  where Emp_ID=@Emp_Id and LT.Leave_ID=@Leave_ID and For_Date=@Month_End_Date )
												begin
													Select @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date
													
													Update T0140_LEAVE_TRANSACTION set
														--Leave_Opening = 0,
														Leave_Closing = 0,
														Leave_Posting = @Leave_Closing
													where Leave_Tran_ID = @Leave_Tran_ID 
												end
											else
												begin												
													If @Default_Short_Name <> 'COMP' 
														begin
														
															Select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) + 1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK)
													
															Insert into T0140_LEAVE_TRANSACTION(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
															values(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_End_Date,@Leave_Closing,0,0,0,@Leave_Closing)
														end
												end
											
											
										end
								End
							Else
								Begin
								
									--Hardik 18/09/2012 for Reset Year checking (added new SP)
									Set @bln_Flag = 'NO'
									Exec SP_CHECK_LEAVE_RESET_YEAR @For_Date, @CF_Effective_Date, @Reset_Months,@bln_Flag Output, @Date Output
									--If @Reset_Months = MONTH(@For_Date) and YEAR(DATEADD(m,@Reset_Months,@Month_End_Date)) = YEAR(@For_Date)
									--If @Reset_Month_String = MONTH(@For_Date) and @bln_Flag = 'YES'
									If CHARINDEX('#' + cast(month(@For_Date) as varchar) + '#',@Reset_Month_String) > 0 and @bln_Flag = 'YES'									 
										Begin
											--if exists(Select Leave_Tran_Id from T0140_LEAVE_TRANSACTION where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=DATEADD(m,@Reset_Months,@Month_End_Date))
											if exists(Select Leave_Tran_Id from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID and isnull(LM.Default_Short_Name,'') <> 'COMP' where Emp_ID=@Emp_Id and LT.Leave_ID=@Leave_ID and For_Date= @Month_End_Date)
												begin
													Select @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date = @Month_End_Date
													
													Update T0140_LEAVE_TRANSACTION set
														--Leave_Opening = 0,
														Leave_Closing = 0,
														Leave_Posting = @Leave_Closing
													where Leave_Tran_ID = @Leave_Tran_ID 
												end
											else
												begin
													If @Default_Short_Name <> 'COMP'
														begin
																					
															Select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) + 1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK)
													
															Insert into T0140_LEAVE_TRANSACTION(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
																values(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_End_Date,@Leave_Closing,0,0,0,@Leave_Closing)
														end	
												end
										End
								End  
								---- End ----
				SET @LEAVE_RESET =  1

			End
						
	END

	else
	begin
	
		if isnull(@Reset_Months,0) > 0 
		begin
		
			If @Reset_Months <= 12
				Begin
				
				--print 'Start'
				--Added by Jaina 14-11-2017
				--if not exists (select 1 from dbo.Split(@Reset_Month_String,'#') as d where d.data = month(@CF_To_Date))
				--BEGIN
				--	SET @Reset_Month_String='0'
				--END
				--select @Reset_Month_String
				--If CHARINDEX(cast(month(@For_Date) as varchar),@Reset_Month_String) > 0
				If CHARINDEX('#' + cast(month(@CF_To_Date) as varchar) + '#',@Reset_Month_String) > 0  --Change by Jaina 14-11-2017
						begin
								print @Reset_Months
									if exists(Select Leave_Tran_Id from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date)
										begin					
											Select @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date=@Month_End_Date
										
											Update T0140_LEAVE_TRANSACTION set
												--Leave_Opening = 0,
												Leave_Closing = 0,
												--Leave_Posting = @Leave_Closing
												Leave_Posting = ((Leave_Opening ) - ( isnull(Leave_Used,0) + isnull(Leave_Adj_L_Mark,0) + isnull(Leave_Encash_Days,0)))  --Added by Jaina 22-02-2018
											where Leave_Tran_ID = @Leave_Tran_ID 
										end
									else
										begin	
										
											Select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) + 1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK)
											
											Insert into T0140_LEAVE_TRANSACTION(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
											values(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_End_Date,@Leave_Closing,0,0,0,@Leave_Closing)
										end
								end
						--End
				Else
					Begin
							
							Set @bln_Flag = 'NO'
							Exec SP_CHECK_LEAVE_RESET_YEAR @For_Date, @CF_Effective_Date, @Reset_Months,@bln_Flag Output, @Date Output
							
							--If @Reset_Month_String = MONTH(@For_Date) and @bln_Flag = 'YES'
							If CHARINDEX('#' + CAST(MONTH(@For_Date) AS VARCHAR(50))+ '#',@Reset_Month_String)> 0 and @bln_Flag = 'YES'
								Begin
									if exists(Select Leave_Tran_Id from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date= @Month_End_Date)
										begin
											Select @Leave_Tran_ID = Leave_Tran_Id, @Leave_Closing = Leave_Closing from T0140_LEAVE_TRANSACTION WITH (NOLOCK) where Emp_ID=@Emp_Id and Leave_ID=@Leave_ID and For_Date = @Month_End_Date
											
											Update T0140_LEAVE_TRANSACTION set
												Leave_Closing = 0,
												Leave_Posting = @Leave_Closing
											where Leave_Tran_ID = @Leave_Tran_ID 
										end
									else
										begin
									
											Select @Leave_Tran_ID = Isnull(max(Leave_Tran_ID),0) + 1 From T0140_LEAVE_TRANSACTION WITH (NOLOCK)
											Insert into T0140_LEAVE_TRANSACTION(Leave_Tran_ID,Emp_ID,Leave_Id,Cmp_ID,For_Date,Leave_Opening,Leave_Used,Leave_Closing,Leave_Credit,Leave_Posting)
											values(@Leave_Tran_ID,@Emp_Id,@Leave_ID,@Cmp_ID,@Month_End_Date,@Leave_Closing,0,0,0,@Leave_Closing)
										end
								End
						End  

			End

				SET @LEAVE_RESET =  1
			end
			
		end
	
	return
end
