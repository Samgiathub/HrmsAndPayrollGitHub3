


-- Created by rohit For insert default Column
-- Created Date :- 12052017
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Default_Column_insert]
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @column_master Table(Column_value  varchar(200),Column_name varchar(500))
	
	insert into @column_master(Column_value,Column_name) VALUES ('Alpha_Emp_Code','Emp_Code')
	insert into @column_master(Column_value,Column_name) VALUES ('Emp_full_Name','Emp full Name')
	insert into @column_master(Column_value,Column_name) VALUES ('Branch_Name','Branch Name')
	insert into @column_master(Column_value,Column_name) VALUES ('Grd_Name','Grd Name')
	insert into @column_master(Column_value,Column_name) VALUES ('Shift_name','Shift name')
	insert into @column_master(Column_value,Column_name) VALUES ('dept_name','Department name')
	insert into @column_master(Column_value,Column_name) VALUES ('Type_Name','Type Name')
	insert into @column_master(Column_value,Column_name) VALUES ('Desig_Name','Designation Name')
	insert into @column_master(Column_value,Column_name) VALUES ('for_Date','Date')
	insert into @column_master(Column_value,Column_name) VALUES ('In_Time','In Time')
	insert into @column_master(Column_value,Column_name) VALUES ('Out_Time','Out Time')
	insert into @column_master(Column_value,Column_name) VALUES ('Duration','Duration')
	insert into @column_master(Column_value,Column_name) VALUES ('P_Days','Present Days')
	insert into @column_master(Column_value,Column_name) VALUES ('Late_In','Late In')
	insert into @column_master(Column_value,Column_name) VALUES ('Late_Out','Late Out')
	insert into @column_master(Column_value,Column_name) VALUES ('Early_In','Early In')
	insert into @column_master(Column_value,Column_name) VALUES ('Early_Out','Early Out')
	insert into @column_master(Column_value,Column_name) VALUES ('Leave','Leave')
	insert into @column_master(Column_value,Column_name) VALUES ('Shift_Dur','Shift Dur')
	insert into @column_master(Column_value,Column_name) VALUES ('Total_work','Total work')
	insert into @column_master(Column_value,Column_name) VALUES ('Less_Work','Less Work')
	insert into @column_master(Column_value,Column_name) VALUES ('More_Work','More Work')
	insert into @column_master(Column_value,Column_name) VALUES ('Reason','Reason')
	insert into @column_master(Column_value,Column_name) VALUES ('Other_Reason','Other Reason')
	insert into @column_master(Column_value,Column_name) VALUES ('AB_LEAVE','Status')
	insert into @column_master(Column_value,Column_name) VALUES ('Late_In_Sec','Late In Sec')
	insert into @column_master(Column_value,Column_name) VALUES ('Late_In_count','Late In count')
	insert into @column_master(Column_value,Column_name) VALUES ('Early_Out_Count','Early Out Count')
	insert into @column_master(Column_value,Column_name) VALUES ('Shift_St_Datetime','Shift Start Datetime')
	insert into @column_master(Column_value,Column_name) VALUES ('Shift_en_Datetime','Shift End Datetime')
	insert into @column_master(Column_value,Column_name) VALUES ('Leave_Reason','Leave Reason')
	insert into @column_master(Column_value,Column_name) VALUES ('Inout_Reason','Inout Reason')
	insert into @column_master(Column_value,Column_name) VALUES ('CMP_NAME','CMP NAME')
	insert into @column_master(Column_value,Column_name) VALUES ('CMP_ADDRESS','CMP ADDRESS')
	insert into @column_master(Column_value,Column_name) VALUES ('On_Date','On Date')
	
		DECLARE @Column_value varchar(200),
				@Column_name varchar(500)

		DECLARE C_Master CURSOR FOR SELECT Column_value,Column_name FROM @column_master
		OPEN C_Master
		FETCH NEXT FROM C_Master INTO @Column_value,@Column_name
		WHILE @@FETCH_STATUS = 0
		BEGIN

			DECLARE @CNT as int
			SET @CNT = 0	
			SET @CNT = (Select COUNT(*) from column_master WHERE UPPER(Column_value) = UPPER(@Column_value))
			IF @CNT = 0
			BEGIN
			   INSERT INTO column_master (Column_value,Column_name) VALUES (@Column_value,@Column_name)
		   END
		   FETCH NEXT FROM C_Master INTO @Column_value,@Column_name
		END

		CLOSE C_Master
		DEALLOCATE C_Master
	
end
