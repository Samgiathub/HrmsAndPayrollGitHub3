


CREATE View [dbo].[V0040_File_Type_Master]
As 
select F_TypeID,TypeTitle,isnull(TypeCode,'') as TypeCode,Cmp_ID
,isnull(File_Type_Number,'')as File_Type_Number,isnull(Created_By,'')as Created_By,
--,isnull(File_type_Start_Date,'')as File_type_Start_Date
format(File_type_Start_Date,'dd/MM/yyyy')as File_type_Start_Date,
format(File_type_End_Date,'dd/MM/yyyy')as File_type_End_Date
--,isnull(File_type_End_Date,'')as File_type_End_Date---added 09_08_22
,isnull(Is_Active,0)as IsActive
from T0040_File_Type_Master
--where Is_Active=1--commented on 30-08-22
