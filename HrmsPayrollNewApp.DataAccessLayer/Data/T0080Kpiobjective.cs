using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080Kpiobjective
{
    public decimal KpiobjId { get; set; }

    public decimal CmpId { get; set; }

    public decimal KpiAttId { get; set; }

    public string? Objective { get; set; }

    public decimal EmpId { get; set; }

    public decimal CreatedById { get; set; }

    public string? AddByFlag { get; set; }

    public string? ApproveStatus { get; set; }

    public string? VerificationStatus { get; set; }

    public decimal? EmpKpiId { get; set; }

    public string? Metric { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpKpi? EmpKpi { get; set; }

    public virtual T0040EmpKpiMaster KpiAtt { get; set; } = null!;

    public virtual ICollection<T0090KpipmsObjective> T0090KpipmsObjectives { get; set; } = new List<T0090KpipmsObjective>();

    public virtual ICollection<T0100KpipmsObjectiveLevel> T0100KpipmsObjectiveLevels { get; set; } = new List<T0100KpipmsObjectiveLevel>();
}
