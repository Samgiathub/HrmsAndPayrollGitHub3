using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052IncrementUtility
{
    public decimal IncrementUtilityId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? Amount { get; set; }

    public decimal? AchivementId { get; set; }

    public decimal? Percentage { get; set; }

    public virtual T0040AchievementMaster? Achivement { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040GradeMaster? Grd { get; set; }

    public virtual T0040BusinessSegment? Segment { get; set; }
}
