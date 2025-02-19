

---28/1/2021 (EDIT BY Yogesh ) 
-- exec [dbo].[SP_Mobile_Canteen_Application_List] 120,14562,'2023-05-01 17:36:41.000','2023-05-30 17:36:41.000'

--exec SP_Mobile_Canteen_Bind_Dropdown 120,14562,'',0,0
CREATE  PROCEDURE [dbo].[SP_Mobile_Canteen_Bind_Dropdown]
	--@Compoff_App_ID numeric(18,0),
	
 @Cmp_Id numeric(9)  
,@Emp_Id numeric(9)   
 ,@App_Type nvarchar(50)
 ,@Canteen_Id numeric(9)   
 ,@Food_Type_Id numeric(9)   
 


 
	

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @StrResult as varchar(50)
--select @Cmp_Id,@Emp_Id,@App_Type,@Canteen_Id,@Food_Type_Id
if @Cmp_Id != 0 and @Emp_Id != 0 and @App_Type='' and  @Canteen_Id=0 and @Food_Type_Id=0
 Begin
 	

	select distinct im.IP_ID as 'Canteen_Id',IM.Device_Name as 'Canteen_Name'  from  T0040_IP_MASTER IM where im.Cmp_Id=@Cmp_Id and Is_Canteen=1 and Is_Active = 1

	set @StrResult='Sucessfull'
	return
 end
 if @Cmp_Id != 0 and @Emp_Id != 0 and @App_Type='Guest' and  @Canteen_Id=0 and @Food_Type_Id=0
 Begin
 	
	
	--select distinct Res_Id as 'Guest_Type_Id',Reason_Name  as 'Guest_Type' from T0040_Reason_Master  RM  left join T0080_CANTEEN_APPLICATION ca on ca.Guest_Type_Id=RM.Res_Id and ca.Cmp_Id=@Cmp_Id --and Ca.Emp_Id=@Emp_Id 
	select distinct Res_Id as 'Guest_Type_Id',Reason_Name  as 'Guest_Type' from T0040_Reason_Master  where [Type]='Canteen' and Isactive=1
	
	set @StrResult='Sucessfull'
	return
	
 end
  if @Cmp_Id != 0 and @Emp_Id != 0 and @App_Type='' and  @Canteen_Id!=0 and @Food_Type_Id=0
 Begin
 
 	
 	--Select distinct CM.Cnt_id as 'Food_Type_Id',Cm.Cnt_Name as 'Food_Type',cm.From_Time,cm.To_Time from T0050_CANTEEN_MASTER CM  inner join T0080_CANTEEN_APPLICATION CA on CM.Cnt_Id=Cm.Cnt_Id and cm.Cmp_Id=@Cmp_Id and Ca.Emp_Id=@Emp_Id 
	--and Ip_Id=@Canteen_Id
	Select distinct CM.Cnt_id as 'Food_Type_Id',Cm.Cnt_Name as 'Food_Type',cm.From_Time,cm.To_Time from T0050_CANTEEN_MASTER CM  where cm.cmp_id=@cmp_id and cm.Ip_Id= @Canteen_Id
	and Is_Active = 1
	set @StrResult='Sucessfull'
	return
	
 end

  if @Cmp_Id != 0 and @Emp_Id != 0 and @App_Type='' and  @Canteen_Id!=0 and @Food_Type_Id!=0
 Begin
 
	If Exists (Select App_Id  from T0080_CANTEEN_APPLICATION WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and Emp_Id = @Emp_Id and Cnt_Id = @Food_Type_Id AND Canteen_Name=@Canteen_Id)     	
		begin
		
		set @StrResult='Reference already exist '
	
		return
		end
		else
		
		begin
		Declare @From_Time as datetime,@To_Time as datetime

		set @From_Time=(select From_Time from T0050_CANTEEN_MASTER where Cnt_Id=@Food_Type_Id and Is_Active = 1)
		set @To_Time=(select To_Time from T0050_CANTEEN_MASTER where Cnt_Id=@Food_Type_Id and Is_Active = 1)
		--select * from T0050_CANTEEN_MASTER
		if (convert(varchar(5), GETDATE(), 108)) between @From_Time and @To_Time
		begin
		select 'Sucessfull'

		--Cast(SUBSTRING(convert(varchar, In_Time, 23),1,10) + ' ' + Shift_St_Time + ':00.000' as Datetime)
		end
		else
		
		begin
		select 'Fail'
		end
		end
end

	
 


	
 




 






