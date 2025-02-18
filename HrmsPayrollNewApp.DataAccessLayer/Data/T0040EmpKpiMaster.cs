using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040EmpKpiMaster
{
    public decimal KpiAttId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal EmpKpiId { get; set; }

    public decimal? EmpId { get; set; }

    public string? Kpi { get; set; }

    public decimal? Weightage { get; set; }

    public decimal SubKpiid { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0080EmpKpi EmpKpi { get; set; } = null!;

    public virtual T0080SubKpiMaster SubKpi { get; set; } = null!;

    public virtual ICollection<T0080Kpiobjective> T0080Kpiobjectives { get; set; } = new List<T0080Kpiobjective>();

    public virtual ICollection<T0100KpiobjectivesLevel> T0100KpiobjectivesLevels { get; set; } = new List<T0100KpiobjectivesLevel>();
}
