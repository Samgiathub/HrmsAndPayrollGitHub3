using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080SubKpiMaster
{
    public decimal SubKpiid { get; set; }

    public decimal KpiId { get; set; }

    public decimal? EmpId { get; set; }

    public string SubKpi { get; set; } = null!;

    public decimal? Weightage { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpKpiId { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0080EmpKpi? EmpKpi { get; set; }

    public virtual T0040KpiMaster Kpi { get; set; } = null!;

    public virtual ICollection<T0040EmpKpiMaster> T0040EmpKpiMasters { get; set; } = new List<T0040EmpKpiMaster>();

    public virtual ICollection<T0080Kpirating> T0080Kpiratings { get; set; } = new List<T0080Kpirating>();

    public virtual ICollection<T0100EmpKpiMasterLevel> T0100EmpKpiMasterLevels { get; set; } = new List<T0100EmpKpiMasterLevel>();

    public virtual ICollection<T0100KpiratingLevel> T0100KpiratingLevels { get; set; } = new List<T0100KpiratingLevel>();
}
