




CREATE View [dbo].[V0040_Griev_Category_Master]
As 

select G_CategoryID,CategoryTitle,isnull(CategoryCode,'') as CategoryCode,Cmp_ID from T0040_Griev_Category_Master
where Is_Active=1

