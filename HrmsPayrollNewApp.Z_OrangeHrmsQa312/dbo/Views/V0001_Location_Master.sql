


CREATE VIEW [dbo].[V0001_Location_Master]
As 
select Loc_Id,Loc_name,isnull(Lc.Category_name,'') as Loc_Cat_name from T0001_LOCATION_MASTER LM WITH (NOLOCK)
left join t0040_Loc_Cat_Master LC WITH (NOLOCK) on lm.loc_cat_id=LC.loc_cat_id



