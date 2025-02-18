using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040KpiMaster
{
    public decimal KpiId { get; set; }

    public decimal CmpId { get; set; }

    public string? BranchId { get; set; }

    public string? Kpi { get; set; }

    public decimal? Weightage { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? CategoryId { get; set; }

    public string? DesignationId { get; set; }

    public bool? Active { get; set; }

    public virtual T0030CategoryMaster? Category { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0080SubKpiMaster> T0080SubKpiMasters { get; set; } = new List<T0080SubKpiMaster>();

    public virtual ICollection<T0090SubKpiMasterLevel> T0090SubKpiMasterLevels { get; set; } = new List<T0090SubKpiMasterLevel>();

    public virtual ICollection<T0115BalanceScoreCardSettingDetailsLevel> T0115BalanceScoreCardSettingDetailsLevels { get; set; } = new List<T0115BalanceScoreCardSettingDetailsLevel>();
}
