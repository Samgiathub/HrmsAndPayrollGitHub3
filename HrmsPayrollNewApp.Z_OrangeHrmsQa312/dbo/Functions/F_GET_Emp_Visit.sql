
---10/3/2021 (EDIT BY MEHUL ) (Scaler-valued function WITH NOLOCK)---
CREATE FUNCTION [dbo].[F_GET_Emp_Visit] 
	(
		@Cmp_Id as numeric,
		@travel_Approval_id as numeric,
		@flag as tinyint=0 --0 for Getting Detail from Travel Approval
	)
RETURNS Varchar(max)
AS
begin
		Declare @emp_visit Varchar(max)
		Declare @Place_Of_Visit as varchar(100)
		Declare @From_Date as varchar(100)
		Declare @To_Date as Varchar(100)
		Declare @Temp as varchar(200)
		set @emp_visit = ''
		
	
		
		if (@flag=0)
				Begin
				
				
						if (select count(*) from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL WITH (NOLOCK) where cmp_id = @Cmp_Id and Travel_Application_Id=@travel_Approval_id )=0
						begin
								
								Declare CusrVisit cursor for		               
								
								select Place_Of_Visit, convert(varchar(11),From_Date,106) as From_Date,convert(varchar(11),To_Date,106) as To_date  from T0130_TRAVEL_APPROVAL_DETAIL TAD WITH (NOLOCK)
								inner join T0120_TRAVEL_APPROVAL TA WITH (NOLOCK) on TA.Travel_Approval_ID=TAD.Travel_Approval_ID --and TA.Emp_ID=TAD.Emp_ID
								 where TAD.cmp_id = @Cmp_Id and TA.Travel_Application_ID=@travel_Approval_id 
						end
						else
						begin
							Declare CusrVisit cursor for		               
							
									select distinct Place_Of_Visit, convert(varchar(11),From_Date,106) as From_Date,convert(varchar(11),To_Date,106) as To_date  from T0115_TRAVEL_APPROVAL_DETAIL_LEVEL WITH (NOLOCK)
									
									 where cmp_id = @Cmp_Id and Travel_Application_Id=@travel_Approval_id 
						end	
							
							
					
				End
		Else
			Begin
				Declare CusrVisit cursor for
				select Place_Of_Visit, convert(varchar(11),From_Date,106) as From_Date,convert(varchar(11),To_Date,106) as To_date  from T0110_TRAVEL_APPLICATION_DETAIL WITH (NOLOCK) where cmp_id = @Cmp_Id and Travel_App_ID=@travel_Approval_id 
				
			End		
		Open CusrVisit
		Fetch next from CusrVisit into @Place_Of_Visit,@From_Date,@To_Date
		While @@fetch_status = 0                    
		Begin   
	
		set @emp_visit = @emp_visit + 'Visit Place : ' + @Place_Of_Visit + ' -' + ' ' + 'Travel Date : ' + @from_Date + ' to ' + @to_Date + '</br>'
		

		fetch next from CusrVisit  into  @Place_Of_Visit,@From_Date,@To_Date
		end
		close CusrVisit                     
		deallocate CusrVisit 
--return @flag
		RETURN @emp_visit
end


