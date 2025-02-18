using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040AchievementMaster
{
    public decimal AchievementId { get; set; }

    public decimal CmpId { get; set; }

    public string AchievementLevel { get; set; } = null!;

    public int? AchievementSort { get; set; }

    public int? AchievementType { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0040HrmsRangeMaster> T0040HrmsRangeMasters { get; set; } = new List<T0040HrmsRangeMaster>();

    public virtual ICollection<T0050AppraisalUtilitySetting> T0050AppraisalUtilitySettings { get; set; } = new List<T0050AppraisalUtilitySetting>();

    public virtual ICollection<T0052IncrementUtility> T0052IncrementUtilities { get; set; } = new List<T0052IncrementUtility>();
}
