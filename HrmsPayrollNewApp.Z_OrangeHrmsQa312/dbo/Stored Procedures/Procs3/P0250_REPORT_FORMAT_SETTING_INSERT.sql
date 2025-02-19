
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0250_REPORT_FORMAT_SETTING_INSERT]
@Exe_Code as numeric(2)=0,
@Transaction_Id as numeric(18,0),
@Cmp_ID as numeric(18,0),
@Module_Name as varchar(50),
@Paper_Value as tinyint,
@Format_Value as tinyint,
@Sorting_No as numeric(18,0) = 0,
@Format_Name as varchar(100) ='' --Mukti 08122015
as

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


			declare @maxid as numeric
			declare @sortno as numeric
		 if @Exe_Code=1
					begin
						--if exists(select Module_Name from T0250_REPORT_FORMAT_SETTING where Cmp_id=@Cmp_ID and Module_Name =@Module_Name and paper_value=@Paper_Value and format_value=@Format_Value)
						if exists(select Module_Name from T0250_REPORT_FORMAT_SETTING WITH (NOLOCK) where Cmp_id=@Cmp_ID and Module_Name =@Module_Name)--Changed by Sumit 22072015
							begin
								
								raiserror('Record Alredy Exists',16,1);
								return
							end
						else if exists(select Module_Name from T0250_REPORT_FORMAT_SETTING WITH (NOLOCK) where Cmp_id=@Cmp_ID and Module_Name =@Module_Name and paper_value=@Paper_Value)
							begin
								
								select @maxid = ISNULL( MAX(Tran_Id),0) + 1 from T0250_REPORT_FORMAT_SETTING WITH (NOLOCK)
								select @sortno = MAX(Sorting_No) + 1 from T0250_REPORT_FORMAT_SETTING WITH (NOLOCK) where Cmp_id=@Cmp_ID and Module_Name =@Module_Name and paper_value=@Paper_Value group by Module_Name,paper_value
								insert into T0250_REPORT_FORMAT_SETTING 
								values(@maxid ,@Cmp_ID,@Module_Name,isnull(@Paper_Value,0),isnull(@Format_Value,0),@sortno,@Format_Name)	
							end
					
						else 
							begin
								
								select @maxid = ISNULL( MAX(Tran_Id),0) + 1 from T0250_REPORT_FORMAT_SETTING WITH (NOLOCK)
								
								insert into T0250_REPORT_FORMAT_SETTING 
								values(@maxid ,@Cmp_ID,@Module_Name,isnull(@Paper_Value,0),isnull(@Format_Value,0),@Sorting_No,@Format_Name)	
							end
					end
			else if @Exe_Code=0
				begin
					if exists(select Module_Name from T0250_REPORT_FORMAT_SETTING WITH (NOLOCK) where Cmp_id=@Cmp_ID and Module_Name =@Module_Name and paper_value=@Paper_Value and format_value=@Format_Value AND Tran_Id <> @Transaction_Id) --Condition added by Nimesh 03-Sep-2015 (Record was not getting updated)
							begin
								raiserror('Record Alredy Exists',16,1);
								return
							end

					update T0250_REPORT_FORMAT_SETTING
					set
					Cmp_id=@Cmp_ID,
					Module_Name=@Module_Name,
					Paper_Value=isnull(@Paper_Value,0),
					Format_Value=isnull(@Format_Value,0),
					Sorting_No=@Sorting_No,
					Format_Name=@Format_Name --Mukti 08122015
					where Tran_Id=@Transaction_Id
				end
			else if @Exe_Code=2
					begin
						
						delete from T0250_REPORT_FORMAT_SETTING where Cmp_id=@Cmp_ID and Tran_Id=@Transaction_Id
					
					End
				
		
return




