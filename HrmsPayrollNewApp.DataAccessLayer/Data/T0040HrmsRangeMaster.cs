using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsRangeMaster
{
    public decimal RangeId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? RangeFrom { get; set; }

    public decimal? RangeTo { get; set; }

    public int? RangeType { get; set; }

    public string? RangeLevel { get; set; }

    public string? RangeDept { get; set; }

    public string? RangeGrade { get; set; }

    public decimal? RangePid { get; set; }

    public decimal? RangePercentAllocate { get; set; }

    public decimal? RangeAchievementId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0040AchievementMaster? RangeAchievement { get; set; }
}
