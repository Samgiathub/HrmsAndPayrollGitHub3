



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0230_PF_CHALLAN_DETAIL_SETT]
			@Pf_Challan_ID	numeric(18, 0)
			,@Cmp_ID	numeric(18, 0)
			,@Sr_No	numeric(18, 0) output
			,@Payment_Head	varchar(100)
			,@AC_1	numeric(18, 0)
			,@AC_2	numeric(18, 0)
			,@AC_10	numeric(18, 0)
			,@AC_21	numeric(18, 0)
			,@AC_22	numeric(18, 0)
			,@AC_Total	numeric(18, 0)
			,@tran_type as char
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @tran_type = 'I'
			begin
					If Exists(select Sr_No From T0230_PF_CHALLAN_DETAIL_SETT WITH (NOLOCK) Where Pf_Challan_ID = @Pf_Challan_ID  and UPPER(Payment_Head) = UPPER(@Payment_Head) AND CMP_ID=@CMP_ID )
						begin
							set @Sr_No = 0
							return 
					end
					select @Sr_No = Isnull(max(Sr_No),0) + 1 From T0230_PF_CHALLAN_DETAIL_SETT WITH (NOLOCK)
				
				INSERT INTO T0230_PF_CHALLAN_DETAIL_SETT
				                      (
											Pf_Challan_ID
											,Cmp_ID
											,Sr_No
											,Payment_Head
											,AC_1
											,AC_2
											,AC_10
											,AC_21
											,AC_22
											,AC_Total
				                      )
								VALUES     
								(
											 @Pf_Challan_ID
											,@Cmp_ID
											,@Sr_No
											,@Payment_Head
											,@AC_1
											,@AC_2
											,@AC_10
											,@AC_21
											,@AC_22
											,@AC_Total
								)	
						
			END
			else if @tran_type ='U' 
				begin
								
						UPDATE  T0230_PF_CHALLAN_DETAIL_SETT

						SET        
									Payment_Head =@Payment_Head
									,AC_1=@AC_1
									,AC_2=@AC_2
									,AC_10=@AC_10
									,AC_21=@AC_21
									,AC_22=@AC_22
									,AC_Total=@AC_Total

				         where Pf_Challan_ID = @Pf_Challan_ID and Sr_No=@Sr_No
				end
	
	RETURN




