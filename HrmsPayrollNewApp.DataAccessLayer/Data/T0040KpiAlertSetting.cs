using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040KpiAlertSetting
{
    public decimal KpiAlertId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? KpiAlertDay { get; set; }

    public decimal? KpiMonth { get; set; }

    public decimal? KpiAlertNodays { get; set; }

    public int? KpiActive { get; set; }

    public int? KpiType { get; set; }

    public bool? KpiPreference { get; set; }

    public bool? EmpTrainingSuggest { get; set; }

    public bool? AllowEditObjective { get; set; }

    public bool? AllowEmpEditObj { get; set; }

    public int? KpiAlertType { get; set; }

    public bool? AllowEmpIrating { get; set; }

    public bool? AllowEmpFrating { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
