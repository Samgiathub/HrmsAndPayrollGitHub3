using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090KpipmsEvalApproval
{
    public decimal TranId { get; set; }

    public decimal? KpipmsId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime? ApprovalDate { get; set; }

    public int? RptLevel { get; set; }

    public int? ApprovalStatus { get; set; }

    public int? KpipmsType { get; set; }

    public string? KpipmsName { get; set; }

    public decimal? KpipmsFinalRating { get; set; }

    public string? KpipmsSupEarlyComment { get; set; }

    public decimal? ManagerScore { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080KpipmsEval? Kpipms { get; set; }

    public virtual ICollection<T0100KpiDevelopmentPlanLevel> T0100KpiDevelopmentPlanLevels { get; set; } = new List<T0100KpiDevelopmentPlanLevel>();

    public virtual ICollection<T0100KpipmsObjectiveLevel> T0100KpipmsObjectiveLevels { get; set; } = new List<T0100KpipmsObjectiveLevel>();

    public virtual ICollection<T0100KpiratingLevel> T0100KpiratingLevels { get; set; } = new List<T0100KpiratingLevel>();
}
